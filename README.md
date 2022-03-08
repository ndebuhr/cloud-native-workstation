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
[![Pgweb](images/pgweb.png "Pgweb")](https://sosedoff.github.io/pgweb/)
[![Apache Guacamole](images/guacamole.png "Apache Guacamole")](https://guacamole.apache.org/)
[![Jupyter](images/jupyter.png "Jupyter")](https://jupyter.org/)
[![Selenium](images/selenium.png "Selenium")](https://www.selenium.dev/)
[![SonarQube](images/sonarqube.png "SonarQube")](https://www.sonarqube.org/)
[![Kanboard](images/kanboard.png "Kanboard")](https://kanboard.org/)
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
- [Provisioning (Optional)](#provisioning-optional)
- [Configure `kubectl`](#configure-kubectl)
- [Prepare SSL](#prepare-ssl)
    - [Certbot with Google Cloud Platform DNS](#certbot-with-google-cloud-platform-dns)
    - [Certbot with Cloudflare DNS](#certbot-with-cloudflare-dns)
    - [Certbot with Route 53 (AWS) DNS](#certbot-with-route-53-aws-dns)
    - [Bring your own SSL certificate](#bring-your-own-ssl-certificate)
- [Build (Optional)](#build-optional)
- [Configuration](#configuration)
    - [Domain](#domain)
    - [Certbot](#certbot)
    - [Resource requests](#resource-requests)
    - [GPU capabilities](#gpu-capabilities)
    - [VM types](#vm-types)
- [Installation](#installation)
    - [Workstation prerequisites installation](#workstation-prerequisites-installation)
    - [CRDs installation](#crds-installation)
    - [Workstation installation](#workstation-installation)
- [Usage](#usage)
- [Deprovisioning](#deprovisioning)
    - [Helm uninstall](#helm-uninstall)
    - [Terraform destory](#terraform-destroy)
- [Contributing](#contributing)
- [License](#license)

## Repository preparation

Pull the repository submodules with the following commands
```
git submodule init
git submodule update
```

## Provisioning (Optional)

### Google Kubernetes Service

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
1. Navigate to the desired provisioning directory - either [provision/gke](provision/gke) or [provision/gke-with-gpu](provision/gke-with-gpu).  The [gke](provision/gke) specification creates a "normal" cluster with a single node pool.  The [gke-with-gpu](provision/gke-with-gpu) specification adds Nvidia T4 GPU capabilities to the Jupyter component, for AI/ML/GPU workloads.  If you do not want to enable the Jupyter component, or want it but for non-AI/ML/GPU workloads, then use the [gke](provision/gke) specification.  The [gke](provision/gke) specification is recommended for most users.  Once you've navigated to the desired infrastructure specification directory, provision with:
    1. Using the default zone (us-central1-a) and cluster name (cloud-native-workstation):
        ```
        terraform init
        terraform apply
        ```
        Or, with a custom zone or custom cluster name:
        ```
        terraform init
        terraform apply -var compute_zone=YOUR_REGION -var cluster_name=YOUR_CLUSTER_NAME
        ```
1. Return to the repository root directory
    ```bash
    cd ../..
    ```

### Elastic Kubernetes Service (AWS)

If you would like to provision a new Kubernetes cluster on Elastic Kubernetes Service to run your workstation, follow the steps below.
1. Create a Cloud Native Workstation policy in Amazon Web Services with the following permissions:
    1. iam:CreateRole
    1. iam:GetRole
    1. iam:ListRolePolicies
    1. iam:ListAttachedRolePolicies
    1. iam:ListInstanceProfilesForRole
    1. iam:DeleteRole
    1. iam:AttachRolePolicy
    1. iam:DetachRolePolicy
    1. logs:CreateLogGroup
    1. logs:PutRetentionPolicy
    1. logs:DescribeLogGroups
    1. logs:ListTagsLogGroup
    1. logs:DeleteLogGroup
    1. ec2:*
    1. eks:*
    1. autoscaling:CreateLaunchConfiguration
    1. autoscaling:DescribeLaunchConfigurations
    1. autoscaling:CreateAutoScalingGroup
    1. autoscaling:DescribeAutoScalingGroups
    1. autoscaling:DescribeScalingActivities
    1. autoscaling:SuspendProcesses
    1. autoscaling:UpdateAutoScalingGroup
    1. autoscaling:*
    1. cloudformation:ListStacks
1. Create a new user and assign the Cloud Native Workstation and IAMFullAccess policies
1. Create a key and set the AWS authentication environment variables
    ```bash
    export AWS_ACCESS_KEY_ID=YOURVALUEHERE
    export AWS_SECRET_ACCESS_KEY=YOURVALUEHERE
    ```
1. Navigate to the [EKS provisioning directory](provision/eks), then provision with:
    ```
    terraform init
    terraform apply
    ```
1. Note the output values for efs_fs_id and efs_role_arn, as you will need them later
1. Return to the repository root directory
    ```bash
    cd ../..
    ```

## Configure `kubectl`

### Google Kubernetes Engine

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

### Elastic Kubernetes Service (AWS)

```bash
aws eks update-kubeconfig --region us-east-1 --name cloud-native-workstation
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
Later, during the installation, be sure `certbot.enabled` is `true` and `certbot.type` is `google` in the Helm values

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
Later, during the installation, be sure `certbot.enabled` is `true` and `certbot.type` is `cloudflare` in the Helm values

### Certbot with Route 53 (AWS) DNS

1. In AWS, create a Route 53 DNS zone for your domain
1. In your domain name registrar, ensure the domain nameservers are set to the values from AWS
1. In AWS, create a Cloud Native Workstation Certbot user with the following permissions:
    1. route53:ListHostedZones
    1. route53:GetChange
    1. route53:ChangeResourceRecordSets

Create a credentials file called `config`, with the following contents.  Use the Access Key ID and Secret Access Key for the account that you just setup.
```
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

Add this file to Kubernetes as a secret:
```bash
kubectl create secret generic aws-config --from-file config
```
Later, during the installation, be sure `certbot.enabled` is `true` and `certbot.type` is `aws` in the Helm values

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

Later, during the helm installation, be sure `certbot.enabled` is `false`.

## Build (Optional)

If you do not want to use the public Docker Hub images, you need to build the docker images for components you are interested in.  For security, the Keycloak image is always required.

```
# Set the REPO environment variable to the image repository
REPO=us.gcr.io/my-project/my-repo  # for example
```
```
# Build and push images
cd build
docker build --tag $REPO/cloud-native-workstation-code-server:latest ./code-server
docker build --tag $REPO/cloud-native-workstation-initializers:latest ./initializers
docker build --tag $REPO/cloud-native-workstation-jupyter:latest ./jupyter
docker build --tag $REPO/cloud-native-workstation-pgweb:latest ./pgweb
docker push $REPO/cloud-native-workstation-code-server:latest
docker push $REPO/cloud-native-workstation-initializers:latest
docker push $REPO/cloud-native-workstation-jupyter:latest
docker push $REPO/cloud-native-workstation-pgweb:latest
cd ..
```

## Configuration
Configure [helm values](deploy/values.yaml), based on the instructions below.

### Domain

Set the `domain` value, based on the domain that you would like to run your workstation on.

### Certbot
The `certbot.email` should be configured if you are using the Certbot option for TLS certificates.

### Resource requests

For portability to low-resource environments like minikube, resource requests are zeroed for all components.  This is just the default configuration.

### GPU capabilities

If you provisioned the cluster using the [gke-with-gpu](provision/gke-with-gpu) specification, ensure `jupyter.enabled` is `true`, set `jupyter.gpu.enabled` to `true`, and uncomment the two `nvidia.com/gpu: 1` resource specification lines.

### VM types

For GKE installations using the [gke-beta provisioning specification](provision/gke-beta) (or similar), workloads can be configured to run on any combination of standard, spot, and/or preemptive VMs.  If multiple VM types are enabled, no scheduling preference will be given to any one option.  Any workload ran without node selectors or node affinities will be scheduled on standard VMs.

## Installation

_If you have already installed a workstation on the cluster, create a namespace for the new workstation, set kubeconfig to use that new namespace, [prepare an SSL certificate](#prepare-ssl), and skip to the [workstation installation step](#workstation-installation)._

![Installation Architecture](images/installation-architecture.png "Installation Architecture")

### Workstation prerequisites installation

The following commands install the Nginx Ingress Controller, Open Policy Agent Gatekeeper, and Keycloak CRDs.  If you would like the ability (but not the obligation) to use EFS-backed persistent volume claims on Elastic Kubernetes Serice (AWS), update the [cluster preparation chart values](prepare/chart/values.yaml) before running the Helm install.  Specifically, set `aws-efs-csi-driver.enabled` to `true`, `aws-efs-csi-driver.controller.serviceAccount.annotations.eks.amazonaws.com/role-arn` to the provisioning output value that you noted earlier, and `aws-efs-csi-driver.storageClasses[0].parameters.fileSystemId` to the provisioning output value that you noted earlier.
```bash
cd prepare/chart
helm dependency update
helm install workstation-prerequisites . -n kube-system
cd ../..
```

### CRDs installation

Constraint templates provide policy-based workstation controls and security.  If you choose not to install these constraint templates, ensure `policies.enabled` is set to `false` in the [helm values](deploy/values.yaml).  Install with:
```bash
kubectl apply -f prepare/crds/constraint-templates.yaml --wait
```

### Workstation installation

Install the workstation on the Kubernetes cluster with Helm:
```bash
cd deploy
helm dependency update
helm install workstation .
cd ..
```

Create a DNS entry (A record) that points `*.YOURDOMAIN` to the Load Balancer External IP created during the Helm installation.  If using EKS, the A record should be an alias to the AWS ELB domain.  To see the installed services, including this Load Balancer, run:
```bash
kubectl get service workstation-prerequisites-ingress-nginx-controller \
    -n kube-system \
    -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,EXTERNAL-IP:.status.loadBalancer.ingress[0].ip,EXTERNAL-HOSTNAME:.status.loadBalancer.ingress[0].hostname
```
The domain must resolve before the components will work (access by IP only is not possible).

Note that workstation creation can take a few minutes.  The DNS propagation is particularly time consuming.

## Usage

Access the components that you've enabled in the Helm values (after authenticating with the Keycloak proxy):

* code.YOUR_DOMAIN for Code Server IDE
* code-dev-server.YOUR_DOMAIN for a development web server
    * e.g. `hugo serve -D --bind=0.0.0.0 --baseUrl=code-dev-server.YOUR_DOMAIN --appendPort=false` in Code Server
* pgweb.YOUR_DOMAIN for Pgweb
* selenium-hub.YOUR_DOMAIN for Selenium Grid hub
* selenium-chrome.YOUR_DOMAIN for Selenium node (Chrome)
* selenium-firefox.YOUR_DOMAIN for Selenium node (Firefox)
* selenium-edge.YOUR_DOMAIN for Selenium node (Edge)
* jupyter.YOUR_DOMAIN for Jupyter data science notebook
* sonarqube.YOUR_DOMAIN for SonarQube
* guacamole.YOUR_DOMAIN/guacamole/ for Apache Guacamole (default login guacadmin:guacadmin)
* kanboard.YOUR_DOMAIN for Kanboard (default login admin:admin)
* prometheus.YOUR_DOMAIN for Prometheus monitoring
* grafana.YOUR_DOMAIN for Grafana visualization
* keycloak.YOUR_DOMAIN for Keycloak administration

## Deprovisioning

### Helm uninstall

Uninstall both helm charts with:
```bash
helm uninstall workstation --wait
helm uninstall workstation-prerequisites --namespace kube-system --wait
```

### Terraform destroy

If a Terraform [provisioning specification](provision/) was used to create the cloud resources, navigate to the provisioning directory and delete with:
```bash
terraform destroy
```

## Contributing

If you fork this project and add something cool, please let me know or contribute it back.

### Development

[Skaffold](https://skaffold.dev/) is the recommended tool for developing Cloud Native Workstation.  A [configuration for development on Google Cloud Platform](skaffold.yaml) is provided for reference.  A service account key is required to leverage the required Google Cloud Platform services (e.g., create a `build.json`, and use it for `GOOGLE_APPLICATION_CREDENTIALS`).
```bash
export GOOGLE_PROJECT={YOUR PROJECT}
export GOOGLE_APPLICATION_CREDENTIALS=build.json
cp skaffold.dev.yaml skaffold.yaml
sed -i "s|CODE_IMAGE|us.gcr.io/$GOOGLE_PROJECT/cloud-native-workstation/code|g" skaffold.yaml
sed -i "s|INITIALIZERS_IMAGE|us.gcr.io/$GOOGLE_PROJECT/cloud-native-workstation/initializers|g" skaffold.yaml
sed -i "s|JUPYTER_IMAGE|us.gcr.io/$GOOGLE_PROJECT/cloud-native-workstation/jupyter|g" skaffold.yaml
sed -i "s|PGWEB_IMAGE|us.gcr.io/$GOOGLE_PROJECT/cloud-native-workstation/pgweb|g" skaffold.yaml
skaffold dev
```

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE](LICENSE)