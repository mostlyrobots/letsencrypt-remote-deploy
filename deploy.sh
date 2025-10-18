#!/bin/bash

# Configuration
TARGET_HOST="10.0.0.1"
TARGET_PORT="443"  # HTTPS service port to check certificate
SSH_PORT="22"      # SSH port for deployment
CERT_DOMAIN="yourdomain.example.com"
TARGET_CERT_PATH="/data/unifi-core/config/unifi-core.crt"
TARGET_KEY_PATH="/data/unifi-core/config/unifi-core.key"
SSH_KEY_FILE="${HOME}/.ssh/id_rsa"
CERT_EMAIL="admin@example.com"
RENEW_DAYS="30"

# Read SSH key
SSH_KEY=$(cat ${SSH_KEY_FILE})

# Build image
docker build -t certbot-auto .

# Run container
docker run --rm \
    -p 80:80 \
    -e TARGET_HOST="${TARGET_HOST}" \
    -e TARGET_PORT="${TARGET_PORT}" \
    -e SSH_PORT="${SSH_PORT}" \
    -e CERT_DOMAIN="${CERT_DOMAIN}" \
    -e TARGET_CERT_PATH="${TARGET_CERT_PATH}" \
    -e TARGET_KEY_PATH="${TARGET_KEY_PATH}" \
    -e SSH_KEY="${SSH_KEY}" \
    -e CERT_EMAIL="${CERT_EMAIL}" \
    -e RENEW_DAYS="${RENEW_DAYS}" \
    certbot-auto
