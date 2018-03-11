FROM debian:stretch
# FROM buildpack-deps:jessie

ENV PSK defaultpsk

RUN \
  # Install packages
  apt-get update && \
  apt-get -y install bash netcat strongswan less vim kmod

# Copy in the IPsec configuration
COPY ipsec.conf /etc/ipsec.conf
COPY strongswan.conf /etc/strongswan.conf

WORKDIR /root
CMD \
  # Start IPsec
  ipsec start & \
  # Put pre-shared key into ipsec.secrets
  echo ": PSK \"$PSK\"" > /etc/ipsec.secrets & \
  bash

