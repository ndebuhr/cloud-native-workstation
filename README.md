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

1. Put your ssl cert (e.g. mydomain.crt) and key (e.g. mydomain.key) in [docker/ssl](docker/ssl).  Remove example.crt and example.key.
1. Build the docker images for components you are interested in.  For networking and security, the HAProxy and Keycloak images are always required.
   ```
   cd docker
   docker build --file DockerfileHaproxy --tag YOUR_REPO/haproxy:latest .
   docker push YOUR_REPO/haproxy:latest
   cd ..
   ```
   (Repeat for all Dockerfiles)
1. Terraform install

   (Configure variables.tf in the terraform directory, then...)
   ```
   cd terraform
   terraform init
   terraform apply .
   cd ...
   ```
1. Configure the Google Cloud Platform cli and Google Kubernetes Engine kubeconfig
    ```
    gcloud init
    gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE
    ```
1. Helm install

    (Set your own values)
    ```
    cd helm ..
    helm install . --generate-name --namespace YOUR_NAMESPACE \
        --set user=workstation \
        --set passwd=M@inz! \
        --set domain=example.com \
        --set clientSecret=CHANGEME \
        --set encryptionKey=CHANGEME \
        --set tensorflow-notebook.jupyter.password=M@inz! \
        --set docker.registry=us.gcr.io/my-project/my-repo
    ```
   1. You can use the following to generate the Helm values above for Keycloak client secret and encryption key
      ```
      WS_CLIENT_SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
      WS_ENCRYPTION_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)
      ```
1. Create a DNS entry to point your domain to the Google Cloud Platform LoadBalancerIP (part of the helm installation).  The domain must resolve before the components will work (access by IP only is not possible).

[https://docs.docker.com/engine/reference/commandline/build/](https://docs.docker.com/engine/reference/commandline/build/)

[https://www.terraform.io/docs/commands/index.html](https://www.terraform.io/docs/commands/index.html)

[https://cloud.google.com/sdk/gcloud/reference/](https://cloud.google.com/sdk/gcloud/reference/)

[https://helm.sh/docs/intro/using_helm/](https://helm.sh/docs/intro/using_helm/)

## Usage

If you included all default components in the Helm install, then you can access them (after authenticating with the Keycloak proxy) at:
* YOUR_DOMAIN:3000 for Theia IDE
* YOUR_DOMAIN:8080 for Keycloak administration
* YOUR_DOMAIN:8888 for Jupyter notebooks
* YOUR_DOMAIN:6006 for Tensorboard
* YOUR_DOMAIN:1313 for Development web server (e.g. `hugo serve -D --bind 0.0.0.0 --baseUrl YOUR_DOMAIN` in Theia)
* YOUR_DOMAIN:3003 for HackMD markup notes
* YOUR_DOMAIN:6901 for Kdenlive video editor
* YOUR_DOMAIN:8090 for Kdenlive audio stream

## Contributing

If you fork this and add something cool, please let me know or contribute it back.

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE.md](LICENSE.md)