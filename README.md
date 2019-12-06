# Cloud-Native Workstation _(cloud-native-workstation)_

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> A set of development and prototyping tools that can be useful in some cloud-native-centric projects

## Background

The components in this project are tailored towards my work - you'll need additions, revisions, and deletions to adapt the system to your needs.  The existing systems are geared towards:
1. Prototyping cloud-native systems
1. Developing simple microservices (golang) and landing pages (HUGO)
1. Analyzing data - especially REST API extraction/loading and analysis/transformation with Python
1. Provisioning infrastructure with Terraform
1. Managing Google Cloud Platform workloads
1. Handling Helm charts and Kubernetes resources
The provisioning and components in this repository are setup to run on Google Kubernetes Engine, but folks should find the system reasonably easy to adapt to other Kubernetes environments.

## Install

1. Create an "ssl" subdirectory within the "docker" directory, and put the ssl cert (.crt) and key (.key) there
1. Build the docker images for components you are interested in.  For networking and security, the HAProxy and Keycloak images are always required.
   ```
   cd docker
   docker build --file DockerfileHaproxy --tag YOUR_REPO/haproxy:latest .
   docker push YOUR_REPO/haproxy:latest
   cd ..
   ```
   (Repeat for all Dockerfiles)
1. Terraform install
   ```
   cd terraform
   terraform init
   terraform apply . \
        -var 'gcp_project=YOUR_PROJECT' \
        -var 'gcp_service_account_key_filepath=PATH_TO_YOUR_GCP_JSON_KEY'
   cd ...
   ```
1. Configure the Google Cloud Platform cli and Google Kubernetes Engine kubeconfig
    ```
    gcloud init
    gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE
    ```
1. Helm install
    (configure values.yaml in the helm directory)
    ```
    cd helm ..
    helm install . \
        --generate-name \
        --namespace YOUR_NAMESPACE \
        --set domain=YOUR_DOMAIN \
        --set clientSecret=YOUR_KEYCLOAK_CLIENT_SECRET \
        --set encryptionKey=YOUR_KEYCLOAK_ENCRYPTION_KEY \
        --set passwd=YOUR_DESIRED_PASSWORD \
        --set tensorflow-notebook.jupyter.password=YOUR_DESIRED_PASSWORD
    ```
   1. You can use the following to generate the Helm values above for Keycloak client secret and encryption key
      ```
      WS_CLIENT_SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
      WS_ENCRYPTION_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)
      ```
1. Create a DNS entry to point your domain to the Google Cloud Platform LoadBalancerIP (part of the helm installation).  The domain must resolve before the components will work (access by IP only is not possible).

[https://docs.docker.com/engine/reference/commandline/build/](https://docs.docker.com/engine/reference/commandline/build/)
[https://www.terraform.io/docs/commands/index.html](https://www.terraform.io/docs/commands/index.html)

## Usage

If you included all default components in the Helm install, then you can access them (after authenticating with the Keycloak proxy) at:
* YOUR_DOMAIN:3000 for Theia IDE
* YOUR_DOMAIN:8080 for Keycloak administration
* YOUR_DOMAIN:8888 for Jupyter notebooks
* YOUR_DOMAIN:6006 for Tensorboard
* YOUR_DOMAIN:1313 for Development Web Server (e.g. `hugo serve -D --bind 0.0.0.0 --baseUrl YOUR_DOMAIN` in Theia)

## Contributing

If you fork this and add something cool, please let me know or contribute it back.

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE.md](LICENSE.md)