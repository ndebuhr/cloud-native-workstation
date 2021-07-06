# Cloud-Native Workstation _(cloud-native-workstation)_

[![Build Workflow](https://github.com/ndebuhr/cloud-native-workstation/workflows/build/badge.svg)](https://github.com/ndebuhr/sim/actions)
[![Deploy Workflow](https://github.com/ndebuhr/cloud-native-workstation/workflows/deploy/badge.svg)](https://github.com/ndebuhr/sim/actions)
[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=cloud-native-workstation&metric=alert_status)](https://sonarcloud.io/dashboard?id=cloud-native-workstation)
[![Readme Standard](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![MIT License](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> A set of development and prototyping tools that can be useful in some cloud-native-centric projects

The components in this project are tailored towards cloud-native application development, delivery, and administration.  Specific use cases include:
1. Prototyping cloud-native systems
1. Developing microservices and microsites
1. Analyzing data - especially ETL processes with Python and REST APIs
1. Provisioning cloud infrastructure with Terraform
1. Managing Google Cloud Platform workloads
1. Handling Helm charts and Kubernetes resources

My own use and testing is with Google Kubernetes Engine, but folks should find the system reasonably easy to adapt to other Kubernetes environments.

## Table of Contents

- [Provisioning (Optional)](#provisioning-(optional))
- [Configure `kubectl`](#configure-`kubectl`)
- [Prepare SSL](#prepare-ssl)
    - [Certbot with Google Cloud Platform DNS](#certbot-with-google-cloud-platform-dns)
    - [Certbot with Cloudflare DNS](#certbot-with-cloudflare-dns)
    - [Bring your own SSL certificate](#bring-your-own-ssl-certificate)
- [Build (Optional)](#build-(optional))
- [Configuration](#configuration)
    - [Docker Registry](#docker-registry)
    - [Keycloak](#keycloak)
    - [Domain](#domain)
    - [Certbot](#certbot)
- [Installation](#installation)
    - [Update `vm.max_map_count` (Optional)](#update-`vm.max_map_count`-(optional))
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Provisioning (Optional)

If you would like to provision a Kubernetes cluster on Google Kubernetes Engine to run your workstation:
1. Create a Cloud Native Workstation role in Google Cloud Platform with the following permissions:
    1. compute.instanceGroupManagers.get
    1. container.clusters.create
    1. container.clusters.delete
    1. container.clusters.get
    1. container.clusters.update
    1. container.operations.get
1. Create a new service account and assign the Cloud Native Workstation and Service Account User roles
1. Generate a service account key
1. Set the GCP authentication environment variable `export GOOGLE_APPLICATION_CREDENTIALS=YOUR_KEY_FILE.json`
1. Set the GCP project environment variable `export GOOGLE_PROJECT=YOUR_PROJECT`
1. Provision:
    1. With the default zone (us-central1-a) and cluster name (cloud-native-workstation):
        ```
        cd terraform
        terraform init
        terraform apply
        cd ..
        ```
    1. With a custom zone or custom cluster name:
        ```
        cd terraform
        terraform init
        terraform apply -var gcp_zone=YOUR_REGION -var gke_cluster_name=YOUR_CLUSTER_NAME
        cd ..
        ```

## Configure `kubectl`

If using Google Kubernetes Engine, execute the commands below.  If you [ran provisioning with the default GCP zone and cluster name](#provisioning-(optional)), then use `cloud-native-workstation` as the cluster name and `us-central1-a` as the cluster zone.  Other cloud vendors should provide a similar cli and commands, for configuring `kubectl`.
```
gcloud init
gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE
```

## Prepare SSL

Secure SSL setup is required.  There are two options for SSL certificates:
1. Automated SSL certificate generation using Let's Encrypt, Certbot, and the DNS01 challenge with Google Cloud DNS
1. Bring your own certificate

### Certbot with Google Cloud Platform DNS

1. In Google Cloud Platform, create a Cloud DNS zone for your domain
1. In your domain name registrar, ensure the domain nameservers are set to the values from Google
1. In Google Cloud Platform, create a Cloud Native Workstation Certbot role with the following permissions:
    1. dns.changes.create
    1. dns.changes.get
    1. dns.managedZones.list
    1. dns.resourceRecordSets.create
    1. dns.resourceRecordSets.delete
    1. dns.resourceRecordSets.list
    1. dns.resourceRecordSets.update
1. Create a new service account and assign the Cloud Native Workstation Certbot role

Generate a json key file for the service account and add it to Kubernetes as a secret.  Rename the file to `google.json`, then add it to Kubernetes as a secret:
```bash
kubectl create secret generic google-json --from-file google.json
```
Later, during the installation, be sure `certbot` is `enabled: true` and `certbot.type` is `google` in the Helm values

### Certbot with Cloudflare DNS

Create a Cloudflare API token with `Zone:DNS:Edit` permissions for only the zones you need certificates for.  Create a `cloudflare.ini` file using this format, and your specific API token:
```
# Cloudflare API token used by Certbot
dns_cloudflare_api_token = YOUR_TOKEN
```

Once you have created the `cloudflare.ini` file, run:
```bash
kubectl create secret generic cloudflare-ini --from-file cloudflare.ini
```
Later, during the installation, be sure `certbot` is `enabled: true` and `certbot.type` is `cloudflare` in the Helm values

### Bring your own SSL certificate

Create an `ssl.pem`, as a concatenation of the cert and private key files.  If you need a self-signed certificate, run the following bash commands:
```
openssl req -x509 \
    -newkey rsa:2048 \
    -days 3650 \
    -nodes \
    -out example.crt \
    -keyout example.key
```

```
cat example.crt example.key > ssl.pem
rm example.crt example.key
```

Load this up as a generic Kubernetes secret:

```bash
kubectl create secret generic ssl-pem --from-file ssl.pem
```

Later, during the helm installation, be sure `certbot` is `enabled: false`.

## Build (Optional)

If you do not want to use the public Docker Hub images, you need to build the docker images for components you are interested in.  For security, the Keycloak image is always required.

```
# Set the REPO environment variable to the image repository
REPO=us.gcr.io/my-project/my-repo  # for example
```
```
# Build and push images
cd docker
docker build --file DockerfileCodeServer --tag $REPO/cloud-native-workstation-code-server:latest .
docker build --file DockerfileKeycloakSeeding --tag $REPO/cloud-native-workstation-keycloak-seeding:latest .
docker build --file DockerfileNovnc --tag $REPO/cloud-native-workstation-novnc:latest .
docker push $REPO/cloud-native-workstation-code-server:latest
docker push $REPO/cloud-native-workstation-keycloak-seeding:latest
docker push $REPO/cloud-native-workstation-novnc:latest
cd ..
```

## Configuration
Configure [helm values](helm/values.yaml), based on the instructions below.

### Docker Registry
Configure the `docker.registry` and `docker.tag` Helm values if you are not using the public Docker Hub images.

### Keycloak
```
# Generate a client secret and encryption key for keycloak (or provide your own)

# To generate a value for the Keycloak client secret
head /dev/urandom | tr -dc A-Za-z0-9 | head -c32
# To generate a value for the Keycloak encryption key
head /dev/urandom | tr -dc A-Za-z0-9 | head -c16
```
Use these for the `keycloak.clientSecret` and `keycloak.encryptionKey` Helm values - replacing the defaults for security.

### Domain

Set the `domain` value, based on the domain that you would like to run your workstation on.

### Certbot
The `certbot.email` should be configured if you are using the Certbot option for TLS certificates.

## Installation

Install the workstation on the Kubernetes cluster with Helm:
```
cd helm
helm dependency update
helm install . --generate-name
cd ..
```

Create a DNS entry to point your domain to the Load Balancer External IP created during the Helm installation.  To see the installed services, including this Load Balancer, run:
```
kubectl get services
```
The domain must resolve before the components will work (access by IP only is not possible).

Note that workstation creation can take a few minutes.  The DNS propagation is particularly time consuming.

### Update `vm.max_map_count` (Optional)

If your work requires monitoring a large number of files (e.g., continually running a development server as you work on a large application), then you may want to bump vm.max_map_count on the Kubernetes nodes.
```
kubectl apply -f kubernetes/node-max-map-count.yaml
```

## Usage

Access the components that you've enabled in the Helm values (after authenticating with the Keycloak proxy):

* YOUR_DOMAIN:1313 for Development web server
    * e.g. `hugo serve -D --bind 0.0.0.0 --baseUrl YOUR_DOMAIN` in Code Server
* YOUR_DOMAIN:3000 for Code Server IDE
* YOUR_DOMAIN:4444 for Selenium Grid hub
* YOUR_DOMAIN:6080 for Ubuntu+Chrome Selenium node
* YOUR_DOMAIN:8080 for Keycloak administration
* YOUR_DOMAIN:8888 for Jupyter data science notebook
* YOUR_DOMAIN:9000 for SonarQube
* YOUR_DOMAIN:8081 for Apache Guacamole (default login guacadmin:guacadmin)

## Contributing

If you fork this and add something cool, please let me know or contribute it back.

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE](LICENSE)