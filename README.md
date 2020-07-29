# Cloud-Native Workstation _(cloud-native-workstation)_

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> A set of development and prototyping tools that can be useful in some cloud-native-centric projects

## Background

The components in this project are tailored towards my work - you'll need additions, revisions, and deletions to adapt the system to your needs.  The existing systems are geared towards:
1. Prototyping cloud-native systems
1. Developing simple microservices (golang) and landing pages (HUGO)
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
Later, during the helm installation, be sure `certbot` is `enabled: true`

### Bring your own SSL certificate

Create an `ssl.pem`, as a concatenation of the cert and private key files.  Load this up as a Kubernetes secret:
```bash
kubectl create secret generic ssl-pem --from-file ssl.pem
```
Later, during the helm installation, be sure `certbot` is `enabled: false`

## Build

Build the docker images for components you are interested in.  For security, the Keycloak image is always required.

```
# Set the REPO environment variable to the image repository
REPO=us.gcr.io/my-project/my-repo  # for example
```
```
# Build and push images
cd docker
docker build --file DockerfileCodeServer --tag $REPO/code:latest .
docker build --file DockerfileKdenlive --tag $REPO/kdenlive:latest .
docker build --file DockerfileKeycloakSeeding --tag $REPO/keycloak-seeding:latest .
docker build --file DockerfileNovnc --tag $REPO/novnc:latest .
docker push $REPO/code:latest
docker push $REPO/kdenlive:latest
docker push $REPO/keycloak-seeding:latest
docker push $REPO/novnc:latest
cd ..
```

## Install
Configure [helm values](helm/values.yaml), then:
```
# Generate a client secret and encryption key for keycloak (or provide your own)
WS_CLIENT_SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
WS_ENCRYPTION_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)
# Set the domain name for the workstation - this should match the SSL certificate
DOMAIN=example.com
# Provide an email - this is only required if you are using the certbot option for SSL
EMAIL=admin@example.com
```
```
cd helm
helm dependency update
helm install . --generate-name \
    --set domain=$DOMAIN  \
    --set clientSecret=$WS_CLIENT_SECRET \
    --set encryptionKey=$WS_ENCRYPTION_KEY \
    --set docker.registry=$REPO \
    --set certbot.email=$EMAIL
```
Create a DNS entry to point your domain to the Load Balancer created during the Helm installation.  The domain must resolve before the components will work (access by IP only is not possible).

Note that workstation creation can take a few minutes.  The DNS propagation is particularly time consuming.

## Usage

Access the components you've enabled in the Helm values (after authenticating with the Keycloak proxy):

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