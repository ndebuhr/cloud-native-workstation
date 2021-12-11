FROM debian:10-slim

USER root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends \
        curl \
        jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 seeder

USER 1000