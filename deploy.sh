#!/bin/bash

# Load configuration
if [ ! -f config.rc ]; then
    echo "Error: config.rc not found. Copy config.rc.example to config.rc and edit."
    exit 1
fi
source config.rc

# Read SSH key
SSH_KEY=$(cat ${SSH_KEY_FILE})

# Build image
docker build -t letsencrypt-remote-deploy .

# Run container
docker run --rm \
    -p ${PUBLISHED_PORT}:80 \
    -e TARGET_HOST="${TARGET_HOST}" \
    -e TARGET_PORT="${TARGET_PORT}" \
    -e SSH_PORT="${SSH_PORT}" \
    -e CERT_DOMAIN="${CERT_DOMAIN}" \
    -e TARGET_CERT_PATH="${TARGET_CERT_PATH}" \
    -e TARGET_KEY_PATH="${TARGET_KEY_PATH}" \
    -e SSH_KEY="${SSH_KEY}" \
    -e CERT_EMAIL="${CERT_EMAIL}" \
    -e RENEW_DAYS="${RENEW_DAYS}" \
    -e RELOAD_CMD="${RELOAD_CMD}" \
    letsencrypt-remote-deploy
