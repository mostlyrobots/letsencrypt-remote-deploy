#!/bin/bash
set -e

# Required environment variables
: "${TARGET_HOST?Required: TARGET_HOST}"
: "${TARGET_PORT?Required: TARGET_PORT}"
: "${CERT_DOMAIN?Required: CERT_DOMAIN}"
: "${TARGET_CERT_PATH?Required: TARGET_CERT_PATH}"
: "${TARGET_KEY_PATH?Required: TARGET_KEY_PATH}"
: "${SSH_KEY?Required: SSH_KEY}"

RENEW_DAYS=${RENEW_DAYS:-30}
SSH_USER=${SSH_USER:-root}
SSH_PORT=${SSH_PORT:-22}

echo "=== Certbot Auto-Renew Container ==="
echo "Target: ${TARGET_HOST}:${TARGET_PORT}"
echo "Domain: ${CERT_DOMAIN}"
echo "Checking certificate expiry..."

# Setup SSH
mkdir -p ~/.ssh
echo "${SSH_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-keyscan -p ${SSH_PORT} ${TARGET_HOST} >> ~/.ssh/known_hosts 2>/dev/null

# Check current certificate expiry via service port
CERT_VALID=$(echo | openssl s_client -connect ${TARGET_HOST}:${TARGET_PORT} -servername ${CERT_DOMAIN} 2>/dev/null | \
    openssl x509 -noout -checkend $((RENEW_DAYS * 86400)) && echo 'valid' || echo 'expired')

if [ "$CERT_VALID" = "valid" ]; then
    echo "Certificate is still valid for more than ${RENEW_DAYS} days. Exiting."
    exit 0
fi

echo "Certificate needs renewal. Starting certbot..."

# Run certbot standalone
certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email ${CERT_EMAIL:-admin@${CERT_DOMAIN}} \
    --domain ${CERT_DOMAIN} \
    --preferred-challenges http

echo "Certificate obtained. Deploying to target..."

# Deploy certificate
scp -i ~/.ssh/id_rsa -P ${SSH_PORT} \
    /etc/letsencrypt/live/${CERT_DOMAIN}/fullchain.pem \
    ${SSH_USER}@${TARGET_HOST}:${TARGET_CERT_PATH}

scp -i ~/.ssh/id_rsa -P ${SSH_PORT} \
    /etc/letsencrypt/live/${CERT_DOMAIN}/privkey.pem \
    ${SSH_USER}@${TARGET_HOST}:${TARGET_KEY_PATH}

# Reload nginx
echo "Reloading nginx on target..."
ssh -i ~/.ssh/id_rsa -p ${SSH_PORT} ${SSH_USER}@${TARGET_HOST} \
    "systemctl reload nginx"

echo "=== Certificate renewal complete ==="
