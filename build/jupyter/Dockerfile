FROM jupyter/datascience-notebook:notebook-6.4.6

USER root

# install apt packages
RUN apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends \
        cmake \
        gnupg \
        libboost-all-dev \
        libpq-dev \
        lsb-release \
        openvpn \
        pkg-config \
        postgresql \
        poppler-utils \
        zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jovyan

RUN chown -R jovyan:users /home/jovyan/work

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/nvidia/lib64
ENV PATH=${PATH}:/usr/local/nvidia/bin