FROM debian:latest

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends bash curl iputils-ping jq && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*