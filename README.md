# Let's Encrypt Remote Deploy

Automated Let's Encrypt certificate renewal and deployment to remote servers via Docker container.

Originally created for Ubiquiti Cloud Gateway (UCG) certificate management, but applicable to any remote service requiring automated certificate deployment.

## Prerequisites

1. Port forwarding configured: External port 80 → Container host's PUBLISHED_PORT
2. Domain DNS pointing to your public IP
3. SSH key-based authentication to target server

## Configuration

Copy the example config and edit with your settings:

```bash
cp config.rc.example config.rc
# Edit config.rc with your values
```

Configuration options:

- `TARGET_HOST`: Target server IP/hostname
- `TARGET_PORT`: HTTPS service port to check certificate (default: 443)
- `SSH_PORT`: SSH port for deployment (default: 22)
- `PUBLISHED_PORT`: Host port to expose for ACME challenge (default: 80)
- `CERT_DOMAIN`: Your domain name
- `TARGET_CERT_PATH`: Certificate path on target server
- `TARGET_KEY_PATH`: Private key path on target server
- `SSH_KEY_FILE`: Path to SSH private key
- `CERT_EMAIL`: Email for Let's Encrypt notifications
- `RENEW_DAYS`: Days before expiry to renew (default: 30)
- `RELOAD_CMD`: Command to reload service after deployment (optional, e.g., `systemctl reload nginx`)

## Usage

```bash
# Copy and edit configuration
cp config.rc.example config.rc
# Edit config.rc with your domain, email, paths, etc.

# Make deploy script executable
chmod +x deploy.sh

# Run certificate renewal
./deploy.sh
```

## Automation

Add to crontab to run weekly:

```bash
0 2 * * 0 cd /path/to/letsencrypt-remote-deploy && ./deploy.sh >> /var/log/certbot-renew.log 2>&1
```

## How It Works

1. Container connects to TARGET_HOST:TARGET_PORT (HTTPS) and checks certificate expiry
2. If renewal needed (< RENEW_DAYS remaining), runs certbot standalone on port 80
3. Obtains certificate via HTTP-01 challenge
4. Copies certificate and key to target server via SCP
5. Executes RELOAD_CMD on target server (if configured)
6. Container exits

## Example: Ubiquiti Cloud Gateway

For UCG deployment, use these paths:

```bash
TARGET_CERT_PATH="/data/unifi-core/config/unifi-core.crt"
TARGET_KEY_PATH="/data/unifi-core/config/unifi-core.key"
RELOAD_CMD="systemctl reload nginx"
```

## Notes

- Container only runs when needed (checks expiry first)
- Requires port 80 to be forwarded to PUBLISHED_PORT during execution
- RELOAD_CMD is optional - leave empty if no service reload needed
- Certificate deployment is idempotent and safe to run repeatedly
