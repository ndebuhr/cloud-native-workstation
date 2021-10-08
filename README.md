<div align="center">
	<img src="https://raw.githubusercontent.com/ndebuhr/cloud-native-workstation/master/images/cnw.png" width="200" height="200">
	<h1>Cloud-Native Workstation</h1>
  <p>A set of development and prototyping tools that can be useful in some cloud-native-centric projects</p>
  <br>
</div>

[![Build Workflow](https://github.com/ndebuhr/cloud-native-workstation/workflows/build/badge.svg)](https://github.com/ndebuhr/sim/actions)
[![Deploy Workflow](https://github.com/ndebuhr/cloud-native-workstation/workflows/deploy/badge.svg)](https://github.com/ndebuhr/sim/actions)
[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=cloud-native-workstation&metric=alert_status)](https://sonarcloud.io/dashboard?id=cloud-native-workstation)
[![Readme Standard](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![MIT License](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The components in this project are tailored towards cloud-native application development, delivery, and administration.  Specific use cases include:
1. Prototyping cloud-native systems
1. Developing microservices and microsites
1. Analyzing data - especially ETL processes with Python and REST APIs
1. Provisioning cloud infrastructure with Terraform
1. Managing Google Cloud Platform workloads
1. Handling Helm charts and Kubernetes resources
1. Working on data science notebooks (including AI/ML)

Relevant technologies include:

[![Code Server](images/code-server.png "Code Server")](https://github.com/cdr/code-server)
[![Apache Guacamole](images/guacamole.png "Apache Guacamole")](https://guacamole.apache.org/)
[![Jupyter](images/jupyter.png "Jupyter")](https://jupyter.org/)
[![Selenium](images/selenium.png "Selenium")](https://www.selenium.dev/)
[![SonarQube](images/sonarqube.png "SonarQube")](https://www.sonarqube.org/)
[![Keycloak](images/keycloak.png "Keycloak")](https://www.keycloak.org/)
[![Prometheus](images/prometheus.png "Prometheus")](https://prometheus.io/)
[![Grafana](images/grafana.png "Grafana")](https://grafana.com/)
[![Terraform](images/terraform.png "Terraform")](https://www.terraform.io/)
[![Helm](images/helm.png "Helm")](https://helm.sh/)
[![Kubernetes](images/kubernetes.png "Kubernetes")](https://kubernetes.io/)
[![Docker](images/docker.png "Docker")](https://www.docker.com/)
[![Certbot](images/certbot.png "Certbot")](https://certbot.eff.org/)
[![Open Policy Agent](images/open-policy-agent.png "Open Policy Agent")](https://www.openpolicyagent.org/)
[![OAuth2 Proxy](images/oauth2-proxy.png "OAuth2 Proxy")](https://oauth2-proxy.github.io/oauth2-proxy/)
[![Nginx](images/nginx.png "Nginx")](https://www.nginx.com/)

My own use and testing is with Google Kubernetes Engine, but folks should find the system reasonably easy to adapt to other Kubernetes environments.

![Architecture Diagram](images/architecture.png "Architecture Diagram")

## Table of Contents

- [Repository preparation](#repository-preparation)
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
    - [Resource requests](#resource-requests)
- [Installation](#installation)
    - [Workstation prerequisites installation](#workstation-prerequisites-installation)
    - [CRDs installation](#crds-installation)
    - [Workstation installation](#workstation-installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Repository preparation

Pull the repository submodules with the following commands
```
git submodule init
git submodule update
```

## Provisioning (Optional)

If you would like to provision a new Kubernetes cluster on Google Kubernetes Engine to run your workstation, follow the steps below.
1. Create a Cloud Native Workstation role in Google Cloud Platform with the following permissions:
    1. compute.instanceGroupManagers.get
    1. container.clusters.create
    1. container.clusters.delete
    1. container.clusters.get
    1. container.clusters.update
    1. container.operations.get
1. Create a new service account and assign the Cloud Native Workstation and Service Account User roles
1. Generate a service account key
1. Set the GCP authentication environment variable
    ```bash
    export GOOGLE_APPLICATION_CREDENTIALS=YOUR_KEY_FILE.json
    ```
1. Set the GCP project environment variable
    ```bash
    export GOOGLE_PROJECT=YOUR_PROJECT
    ```
1. Navigate to the desired provisioning directory - either [terraform/gke](terraform/gke) or [terraform/gke-with-gpu](terraform/gke-with-gpu).  The [gke](terraform/gke) specification creates a "normal" cluster with a single node pool.  The [gke-with-gpu](terraform/gke-with-gpu) specification adds Nvidia T4 GPU capabilities to the Jupyter component, for AI/ML/GPU workloads.  If you do not want to enable the Jupyter component, or want it but for non-AI/ML/GPU workloads, then use the [gke](terraform/gke) specification.  The [gke](terraform/gke) specification is recommended for most users.  Once you've navigated to the desired infrastructure specification directory, provision with:
    1. Using the default zone (us-central1-a) and cluster name (cloud-native-workstation):
        ```
        terraform init
        terraform apply
        ```
        Or, with a custom zone or custom cluster name:
        ```
        terraform init
        terraform apply -var gcp_zone=YOUR_REGION -var gke_cluster_name=YOUR_CLUSTER_NAME
        ```
1. Return to the repository root directory
    ```bash
    cd ../..
    ```

## Configure `kubectl`

If using Google Kubernetes Engine, execute the commands below.  If you [ran provisioning with the default GCP zone and cluster name](#provisioning-(optional)), then use `cloud-native-workstation` as the cluster name and `us-central1-a` as the cluster zone.  Other cloud vendors should provide a similar cli and commands for configuring `kubectl`, if you are not using Google Kubernetes Engine.
```
gcloud init
gcloud container clusters get-credentials cloud-native-workstation --zone us-central1-a
```

Next, create a namespace and configure `kubectl` to use that namespace:
```bash
kubectl create namespace cloud-native-workstation
kubectl config set-context --current --namespace cloud-native-workstation
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

Create cert and private key files.  If you need a self-signed certificate, run the following bash commands:
```
openssl req -x509 \
    -newkey rsa:2048 \
    -days 3650 \
    -nodes \
    -out example.crt \
    -keyout example.key
```

Load this up as a TLS Kubernetes secret:
```bash
kubectl create secret tls workstation-tls \
    --cert=example.crt \
    --key=example.key
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
docker build --file DockerfileInitializers --tag $REPO/cloud-native-workstation-initializers:latest .
docker build --file DockerfileNovnc --tag $REPO/cloud-native-workstation-novnc:latest .
docker build --file DockerfileJupyter --tag $REPO/cloud-native-workstation-jupyter:latest .
docker push $REPO/cloud-native-workstation-code-server:latest
docker push $REPO/cloud-native-workstation-initializers:latest
docker push $REPO/cloud-native-workstation-novnc:latest
docker push $REPO/cloud-native-workstation-jupyter:latest
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
Use these for the `keycloak.clientSecret` and `keycloak.cookieSecret` Helm values - replacing the defaults for security.

### Domain

Set the `domain` value, based on the domain that you would like to run your workstation on.

### Certbot
The `certbot.email` should be configured if you are using the Certbot option for TLS certificates.

### Resource requests

For portability to low-resource environments like minikube, resource requests are zeroed for all components.  This is just the default configuration.  For production environments, set resource requests equal to approximately one-half of the resource limits.

### GPU capabilities

If you provisioned the cluster using the [gke-with-gpu](terraform/gke-with-gpu) specification, ensure `jupyter.enabled` is `true`, set `jupyter.gpu.enabled` to `true`, and uncomment the two `nvidia.com/gpu: 1` resource specification lines.

## Installation

![Installation Architecture](images/installation-architecture.png "Installation Architecture")

### Workstation prerequisites installation

The following commands install the Nginx Ingress Controller and Open Policy Agent Gatekeeper.
```bash
cd helm-prerequisites
helm dependency update
helm install workstation-prerequisites .
cd ..
```

### CRDs installation

The Keycloak operator underpins OAuth2/OIDC systems.  Install with:
```bash
./keycloak/crds.sh
```

Constraint templates provide policy-based workstation controls and security.  Install with:
```bash
./opa/crds.sh
```

### Workstation installation

Install the workstation on the Kubernetes cluster with Helm:
```bash
cd helm
helm dependency update
helm install workstation .
cd ..
```

Create a DNS entry to point your domain to the Load Balancer External IP created during the Helm installation.  To see the installed services, including this Load Balancer, run:
```bash
kubectl get service workstation-prerequisites-ingress-nginx-controller \
    -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,EXTERNAL-IP:.status.loadBalancer.ingress[0].ip
```
The domain must resolve before the components will work (access by IP only is not possible).

Note that workstation creation can take a few minutes.  The DNS propagation is particularly time consuming.

## Usage

Access the components that you've enabled in the Helm values (after authenticating with the Keycloak proxy):

* hugo.YOUR_DOMAIN for a Hugo development web server
    * e.g. `hugo serve -D --bind 0.0.0.0 --baseUrl hugo.YOUR_DOMAIN --appendPort false` in Code Server
* code.YOUR_DOMAIN for Code Server IDE
* selenium.YOUR_DOMAIN for Selenium Grid hub
* novnc.YOUR_DOMAIN for Ubuntu+Chrome Selenium node
* keycloak.YOUR_DOMAIN for Keycloak administration
* jupyter.YOUR_DOMAIN for Jupyter data science notebook
* sonarqube.YOUR_DOMAIN for SonarQube
* guacamole.YOUR_DOMAIN/guacamole/ for Apache Guacamole (default login guacadmin:guacadmin)
* prometheus.YOUR_DOMAIN for Prometheus monitoring
* grafana.YOUR_DOMAIN for Grafana visualization

## Contributing

If you fork this and add something cool, please let me know or contribute it back.

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE](LICENSE)