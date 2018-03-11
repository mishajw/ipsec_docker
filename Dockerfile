FROM debian:stretch

# Install packages
RUN \
  apt-get update && \
  apt-get -y install bash netcat strongswan kmod

# Copy in the IPsec configuration
COPY ipsec.conf /etc/ipsec.conf
COPY strongswan.conf /etc/strongswan.conf

# Either "psk" or "cert"
ARG AUTH_MODE
ENV AUTH_MODE ${AUTH_MODE}

# Variables for setting where to load keys from
ARG KEY_FILE
ARG CERT_FILE
ENV KEY_FILE ${KEY_FILE}

# Variables for our IP and other container's IP
ARG OUR_IP
ARG THEIR_IP

# Variable for setting pre-shared key
ENV PSK default-psk

# Change variables in configurations
RUN \
  sed -i "s/OUR_IP/${OUR_IP}/g" /etc/ipsec.conf && \
  sed -i "s/THEIR_IP/${THEIR_IP}/g" /etc/ipsec.conf

# Copy in keys
COPY ${KEY_FILE} /etc/ipsec.d/private/key.pem
COPY ${CERT_FILE} /etc/ipsec.d/certs/cert.pem

CMD \
  # Start IPsec
  ipsec start && \
  # We have to sleep to wait for `ipsec` to start before running `ipsec up ...`
  sleep 1 && \
  # Set up the connection
  if [ "${AUTH_MODE}" = "psk" ]; then \
    echo ": PSK \"${PSK}\"" > /etc/ipsec.secrets && \
    ipsec rereadsecrets && \
    ipsec up psk-conn; \
  elif [ "${AUTH_MODE}" = "cert" ]; then \
    echo ": RSA /etc/ipsec.d/private/key.pem" > /etc/ipsec.secrets && \
    ipsec rereadsecrets && \
    ipsec up cert-conn; \
  fi && \
  bash

