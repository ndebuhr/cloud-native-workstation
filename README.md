# Cloud-Native Workstation _(cloud-native-workstation)_

![Release Workflow](https://github.com/ndebuhr/cloud-native-workstation/workflows/release%20workflow/badge.svg)
[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=cloud-native-workstation&metric=alert_status)](https://sonarcloud.io/dashboard?id=cloud-native-workstation)
[![Readme Standard](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![MIT License](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> A set of development and prototyping tools that can be useful in some cloud-native-centric projects

## Background

The components in this project are tailored towards cloud-native application development, delivery, and administration.  Specific use cases include:
1. Prototyping cloud-native systems
1. Developing microservices and microsites
1. Analyzing data - especially ETL processes with Python and REST APIs
1. Provisioning cloud infrastructure with Terraform
1. Managing Google Cloud Platform workloads
1. Handling Helm charts and Kubernetes resources

My own use and testing is with Google Kubernetes Engine, but folks should find the system reasonably easy to adapt to other Kubernetes environments.

## Provisioning (Optional)

If you would like to provision a Kubernetes cluster on Google Kubernetes Engine to run your workstation:
1. Configure the [variables.tf](terraform/variables.tf) in the terraform directory
2.
    ```
    cd terraform
    terraform init
    terraform apply .
    cd ..
    ```

## Configure `kubectl`

If using Google Kubernetes Engine, execute the commands below.  Replace YOUR_CLUSTER and YOUR_ZONE with values [from your Terraform provisioning](terraform/variables.tf) or from your existing target cluster.  Other cloud vendors should provide a similar cli and commands.
```
gcloud init
gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE
```

## Prepare SSL

Secure SSL setup is required.  There are two options for SSL certificates:
1. Automated SSL certificate generation using Let's Encrypt, Certbot, and the DNS01 challenge with Google Cloud DNS
1. Bring your own certificate

### Certbot with Let's Encrypt and DNS01 Challenge
Create a Google Cloud Platform service account with the following permissions:
1. dns.changes.create
1. dns.changes.get
1. dns.managedZones.list
1. dns.resourceRecordSets.create
1. dns.resourceRecordSets.delete
1. dns.resourceRecordSets.list
1. dns.resourceRecordSets.update

Generate a json key file for the service account and add it to Kubernetes as a secret.  The file name must be exactly `google.json`.
```bash
kubectl create secret generic google-json --from-file google.json
```
Later, during the installation, be sure `certbot` is `enabled: true` in the Helm values

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
docker build --file DockerfileKdenlive --tag $REPO/cloud-native-workstation-kdenlive:latest .
docker build --file DockerfileKeycloakSeeding --tag $REPO/cloud-native-workstation-keycloak-seeding:latest .
docker build --file DockerfileNovnc --tag $REPO/cloud-native-workstation-novnc:latest .
docker push $REPO/cloud-native-workstation-code-server:latest
docker push $REPO/cloud-native-workstation-kdenlive:latest
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
```

Create a DNS entry to point your domain to the Load Balancer IP created during the Helm installation.  To see the installed services, including this Load Balancer, run:
```
kubectl get services
```
The domain must resolve before the components will work (access by IP only is not possible).

Note that workstation creation can take a few minutes.  The DNS propagation is particularly time consuming.

## Usage

Access the components that you've enabled in the Helm values (after authenticating with the Keycloak proxy):

* YOUR_DOMAIN:1313 for Development web server
    * e.g. `hugo serve -D --bind 0.0.0.0 --baseUrl YOUR_DOMAIN` in Code Server
* YOUR_DOMAIN:3000 for Code Server IDE
* YOUR_DOMAIN:3003 for HackMD markup notes
* YOUR_DOMAIN:4444 for Selenium Grid hub
* YOUR_DOMAIN:6080 for Ubuntu+Chrome Selenium node
* YOUR_DOMAIN:6901 for Kdenlive video editor
* YOUR_DOMAIN:8080 for Keycloak administration
* YOUR_DOMAIN:8090 for Kdenlive audio stream
* YOUR_DOMAIN:8888 for Jupyter data science notebook
* YOUR_DOMAIN:9000 for SonarQube
* YOUR_DOMAIN:8081 for Apache Guacamole (default login guacadmin:guacadmin)

## Contributing

If you fork this and add something cool, please let me know or contribute it back.

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE.md](LICENSE.md)