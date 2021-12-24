FROM codercom/code-server:3.12.0

USER root
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-c"]

# install apt packages
RUN apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends \
        apt-transport-https \
        bash-completion \
        build-essential \
        dnsutils \
        file \
        gnupg \
        jq \
        jsonnet \
        lcdf-typetools \
        libssl-dev \
        lldb \
        lsb-release \
        iputils-ping \
        nmap \
        nodejs \
        npm \
        openjdk-11-jdk \
        openvpn \
        pkg-config \
        python3 \
        python3-pip \
        ruby-dev \
        software-properties-common \
        texlive-latex-base \
        texlive-xetex \
        unzip \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install Docker using apt (docker daemon runs in sidecar)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    usermod -aG docker coder

# Install gcloud cli
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends google-cloud-sdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# install kubectl, kubeadm, and kubelet
RUN RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)" && \
    curl -L --remote-name-all "https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}" && \
    install kubeadm /usr/local/bin/ && \
    install kubelet /usr/local/bin/ && \
    install kubectl /usr/local/bin/

# install hugo extended
RUN curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | \
    grep "browser_download_url" | grep "hugo_extended" | grep "Linux-64bit.tar.gz" | \
    cut -d : -f 2,3 | tr -d \" | \
    wget -qi - && \
    tar xfvz hugo*.tar.gz hugo && \
    install hugo /usr/local/bin/

# install terraform
RUN wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip && \
    unzip terraform_1.0.11_linux_amd64.zip && \
    install terraform /usr/local/bin/

# install helm
RUN wget https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz && \
    tar xfvz helm-v3.7.1-linux-amd64.tar.gz linux-amd64/helm && \
    install linux-amd64/helm /usr/local/bin/

# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# install saml2aws
RUN wget https://github.com/Versent/saml2aws/releases/download/v2.33.0/saml2aws_2.33.0_linux_amd64.tar.gz && \
    tar -xvzf saml2aws_2.33.0_linux_amd64.tar.gz && \
    mv saml2aws /usr/local/bin

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
WORKDIR /root/.cargo/bin
RUN find . -type f -exec install {} /usr/local/bin/ \; && \
    cargo install --git https://github.com/rustwasm/wasm-pack.git

# install golang
RUN wget https://golang.org/dl/go1.17.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz

USER coder

WORKDIR /home/coder

# bash completion - kubernetes and helm
RUN echo "source /etc/bash_completion" >> ~/.bashrc && \
    echo "source <(kubectl completion bash)" >> ~/.bashrc && \
    echo "source <(helm completion bash)" >> ~/.bashrc

# install code-server extensions
RUN code-server --install-extension bungcip.better-toml && \
    code-server --install-extension rust-lang.rust && \
    code-server --install-extension james-yu.latex-workshop && \
    code-server --install-extension redhat.vscode-yaml && \
    code-server --install-extension tsandall.opa && \
    code-server --install-extension hashicorp.terraform