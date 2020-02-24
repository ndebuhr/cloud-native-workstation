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

## Install

1. Put your ssl cert (e.g. mydomain.crt) and key (e.g. mydomain.key) in [docker/ssl](docker/ssl).
1. Build the docker images for components you are interested in.  For networking and security, the HAProxy and Keycloak images are always required.
   ```
   # Set the REPO environment variable to the image repository
   REPO=us.gcr.io/my-project/my-repo  # for example
   ```
   ```
   # Build and push images
   cd docker
   docker build --file DockerfileHaproxy --tag $REPO/haproxy:latest .
   docker build --file DockerfileCodeServer --tag $REPO/code:latest .
   docker build --file DockerfileKdenlive --tag $REPO/kdenlive:latest .
   docker build --file DockerfileKeycloakSeeding --tag $REPO/keycloak-seeding:latest .
   docker push $REPO/haproxy:latest
   docker push $REPO/code:latest
   docker push $REPO/kdenlive:latest
   docker push $REPO/keycloak-seeding:latest
   cd ..
   ```
1. Provision with Terraform

   (Configure [variables.tf](terraform/variables.tf) in the terraform directory, then...)
   ```
   cd terraform
   terraform init
   terraform apply .
   cd ..
   ```
1. Configure the gcloud cli and kubeconfig
    ```
    gcloud init
    gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE
    ```
1. Install with Helm

    (Set your own values)
    ```
    cd helm
    helm dependency update
    helm install . --generate-name --namespace YOUR_NAMESPACE \
        --set user=workstation \
        --set passwd=M@inz! \
        --set domain=example.com \
        --set clientSecret=CHANGEME \
        --set encryptionKey=CHANGEME \
        --set hackmd.postgresql.postgresPassword=M@inz! \
        --set tensorflow-notebook.jupyter.password=M@inz! \
        --set docker.registry=$REPO
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

Access the components you've enabled in the Helm values (after authenticating with the Keycloak proxy):
* YOUR_DOMAIN:3000 for Code Server IDE
* YOUR_DOMAIN:8080 for Keycloak administration
* YOUR_DOMAIN:8888 for Jupyter notebooks
* YOUR_DOMAIN:6006 for Tensorboard
* YOUR_DOMAIN:1313 for Development web server (e.g. `hugo serve -D --bind 0.0.0.0 --baseUrl YOUR_DOMAIN` in Code Server)
* YOUR_DOMAIN:3003 for HackMD markup notes
* YOUR_DOMAIN:6901 for Kdenlive video editor
* YOUR_DOMAIN:8090 for Kdenlive audio stream

## Contributing

If you fork this and add something cool, please let me know or contribute it back.

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).

See license in [LICENSE.md](LICENSE.md)