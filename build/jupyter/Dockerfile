FROM jupyter/datascience-notebook:notebook-6.4.3

USER root

# install apt packages
RUN apt-get update -qqy && \
    apt-get install -qqy \
        cmake \
        libboost-all-dev \
        libpq-dev \
        pkg-config \
        poppler-utils

USER jovyan

RUN chown -R jovyan:users /home/jovyan/work

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/nvidia/lib64
ENV PATH=${PATH}:/usr/local/nvidia/bin