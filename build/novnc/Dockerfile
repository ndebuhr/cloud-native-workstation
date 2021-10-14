FROM python:3-bullseye

USER root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qqy && \
    apt-get install -qqy git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install numpy

RUN git clone https://github.com/novnc/novnc /opt/novnc
