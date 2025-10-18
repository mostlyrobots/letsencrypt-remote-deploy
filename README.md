# Certbot Auto-Renew Docker Container

Automated Let's Encrypt certificate renewal and deployment for Ubiquiti Cloud Gateway.

## Prerequisites

1. Port forwarding configured on UCG: External port 80 → This container's host PUBLISHED_PORT
2. Domain DNS pointing to your public IP
3. SSH access to UCG with key-based authentication

## Configuration

Copy the example config and edit with your settings:

```bash
cp config.rc.example config.rc
# Edit config.rc with your values
```

Configuration options:

- `TARGET_HOST`: UCG IP address (default: 10.0.0.1)
- `TARGET_PORT`: HTTPS service port to check certificate (default: 443)
- `SSH_PORT`: SSH port for deployment (default: 22)
- `PUBLISHED_PORT`: Host port to expose for ACME challenge (default: 80)
- `CERT_DOMAIN`: Your domain name
- `TARGET_CERT_PATH`: Certificate path on UCG (default: /data/unifi-core/config/unifi-core.crt)
- `TARGET_KEY_PATH`: Key path on UCG (default: /data/unifi-core/config/unifi-core.key)
- `SSH_KEY_FILE`: Path to SSH private key
- `CERT_EMAIL`: Email for Let's Encrypt notifications
- `RENEW_DAYS`: Days before expiry to renew (default: 30)

## Usage

```bash
# Copy and edit configuration
cp config.rc.example config.rc
# Edit config.rc with your domain, email, etc.

# Make deploy script executable
chmod +x deploy.sh

# Run certificate renewal
./deploy.sh
```

## Automation

Add to crontab to run weekly:

```bash
0 2 * * 0 cd /path/to/docker-certbot && ./deploy.sh >> /var/log/certbot-renew.log 2>&1
```

## How It Works

1. Container connects to TARGET_HOST:TARGET_PORT (HTTPS) and checks certificate expiry
2. If renewal needed (< RENEW_DAYS remaining), runs certbot standalone on port 80
3. Obtains certificate via HTTP-01 challenge
4. Copies certificate and key to UCG via SCP (SSH port 22)
5. Reloads nginx on UCG
6. Container exits

## Notes

- Container only runs when needed (checks expiry first)
- Requires port 80 to be forwarded to PUBLISHED_PORT during execution
- Certificate persists on UCG at /data/unifi-core/config/
