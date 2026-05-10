---
name: self-hosted-webapps
description: "Deploy Python web apps as systemd services behind nginx with custom domains and SSL."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nginx, systemd, reverse-proxy, ssl, certbot, web-deployment, devops]
    related_skills: [hermes-agent]
---

# Self-Hosted Web Apps

Deploy Python web applications as systemd-managed services behind an nginx reverse proxy with custom domain, password auth, and Let's Encrypt SSL.

Target pattern: web app listens on `127.0.0.1:<port>`, nginx proxies `<your.domain>:443` → `127.0.0.1:<port>`. The web app never binds to a public interface directly.

---

## 1. Anatomy of a deployment

```
/var/www/yourapp/        # App source (alternative: ~/yourapp/)
/etc/nginx/sites-available/yourapp   # nginx config
/etc/nginx/sites-enabled/yourapp     # symlink
/etc/systemd/system/yourapp.service  # systemd unit
~/.config/yourapp.env                # Environment variables (secrets, port, host)
/var/log/yourapp/        # Logs (optional)
```

---

## 2. Setup checklist

| Step | What | Command |
|------|------|---------|
| 1 | Install nginx | `sudo apt-get install -y nginx` |
| 2 | Install certbot | `sudo apt-get install -y certbot python3-certbot-nginx` |
| 3 | Create app directory | `git clone <repo> ~/myapp` |
| 4 | Create env config | `touch ~/.config/myapp.env` (chmod 600 if it has secrets) |
| 5 | Create systemd unit | `/etc/systemd/system/myapp.service` |
| 6 | Enable + start service | `sudo systemctl enable --now myapp` |
| 7 | Create nginx config | `/etc/nginx/sites-available/myapp` |
| 8 | Enable site | `sudo ln -sf ... && sudo nginx -t && sudo systemctl reload nginx` |
| 9 | Set DNS A record | point `myapp.yourdomain.com` → server IP |
| 10 | Get SSL | `sudo certbot --nginx -d myapp.yourdomain.com` |

---

## 3. Environment file (`~/.config/myapp.env`)

```bash
# Key=value pairs — loaded by systemd via EnvironmentFile=
# Comments with # are supported
APP_HOST=127.0.0.1
APP_PORT=8787
APP_PASSWORD=change-me
# SECRET_KEY=...
```

**Important:** If the app reads env vars from a file directly (not via systemd), create a `.env` in the app directory instead.

---

## 4. Systemd service unit

```ini
[Unit]
Description=My Web App
After=network.target nginx.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/myapp

# Load secrets (one per line, KEY=VALUE format)
EnvironmentFile=/home/ubuntu/.config/myapp.env

# The app's startup command
ExecStart=/home/ubuntu/myapp/venv/bin/python /home/ubuntu/myapp/server.py

# Restart behavior
Restart=on-failure
RestartSec=5

# Security
NoNewPrivileges=true
ProtectHome=read-only
ReadWritePaths=/home/ubuntu/.config /home/ubuntu/myapp/data

[Install]
WantedBy=multi-user.target
```

**Key notes:**
- `Type=simple` — the main process is the app itself
- `EnvironmentFile=` — systemd parses this as KEY=VALUE lines (supports # comments)
- `Restart=on-failure` catches crashes; `RestartSec=5` prevents tight restart loops
- If the app needs to write files (sessions, DB, uploads), add those paths to `ReadWritePaths=`
- `ProtectHome=read-only` by default — good security, but the app can't write to `~/` unless you carve out `ReadWritePaths`

**For apps with a foreground-launch flag** (like Hermes WebUI's `bootstrap.py --foreground`):
```ini
ExecStart=/usr/bin/python3 /home/ubuntu/myapp/bootstrap.py --foreground --no-browser
```
The `--foreground` flag makes the bootstrap `os.execv()` into the server, so systemd's PID tracking still sees the live process. Without it, the bootstrap would fork a child and exit — systemd would think the service died.

---

## 5. Nginx reverse proxy config

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name myapp.yourdomain.com;

    # Large uploads for file attachments
    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:8787;
        proxy_http_version 1.1;

        # WebSocket support (required for SSE / streaming)
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Forward real client info
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Long timeouts for AI/big responses
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;

        # Disable buffering for streaming
        proxy_buffering off;
        proxy_cache off;
    }
}
```

**Create and enable:**
```bash
sudo cp /tmp/nginx-config /etc/nginx/sites-available/myapp
sudo ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t           # Validate config
sudo systemctl reload nginx  # Apply
```

---

## 6. DNS

Add an A record at your domain registrar:

| Type | Name | Value |
|------|------|-------|
| A | `myapp` | `<server-public-ip>` |

**Before DNS propagates — test locally:**
```bash
curl -s -H "Host: myapp.yourdomain.com" http://127.0.0.1/health
curl -s -H "Host: myapp.yourdomain.com" http://<public-ip>/health
```

---

## 7. SSL with Let's Encrypt

```bash
# Only after DNS resolves to this server
sudo certbot --nginx -d myapp.yourdomain.com
```

Certbot auto-edits your nginx config to add the `listen 443 ssl;` block. No manual SSL config needed.

**Renewal is automatic** — certbot installs a systemd timer (`systemctl list-timers | grep certbot`).

**Pre-DNS workaround:** If you need HTTPS before DNS propagates, generate a self-signed cert:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/myapp-selfsigned.key \
  -out /etc/ssl/certs/myapp-selfsigned.crt \
  -subj "/CN=myapp.yourdomain.com"
```
Then add a manual SSL server block in nginx. Replace with certbot when DNS is ready.

---

## 8. Testing & verification

```bash
# Service status
sudo systemctl status myapp --no-pager -l

# Check app health endpoint
curl -s http://127.0.0.1:<port>/health

# Check through nginx
curl -s -H "Host: myapp.yourdomain.com" http://127.0.0.1/health

# Check from public IP
curl -s -H "Host: myapp.yourdomain.com" http://<public-ip>/health

# Logs
sudo journalctl -u myapp --no-pager -n 50
sudo journalctl -u myapp -f   # Follow live
```

---

## 9. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `systemctl start` hangs | App started in background/daemon mode | Use `--foreground` or `Type=forking` with PIDFile |
| 502 Bad Gateway from nginx | App isn't running on the proxy_pass port | `ss -tlnp \| grep <port>` to check |
| 504 Gateway Timeout | App response too slow | Increase `proxy_read_timeout` |
| `Permission denied` on writes | ProtectHome blocks write to home dir | Add paths to `ReadWritePaths=` |
| `port 80: Address already in use` | Another process (Apache?) on port 80 | `sudo lsof -i :80` to find it |
| DNS resolves but HTTPS fails | Port 443 blocked by firewall | Check cloud security group / ufw / iptables |
| certbot can't validate domain | DNS hasn't propagated yet | Use `dig +short myapp.yourdomain.com @8.8.8.8` to check |

---

## Pitfalls

- **Don't bind the app to `0.0.0.0`.** Bind to `127.0.0.1` and let nginx handle external access. This is one less attack surface.
- **Don't put secrets in the ExecStart line** or in the `[Service]` section directly. Use `EnvironmentFile=` so secrets are in a separate chmod-600 file.
- **`Type=simple` vs `Type=forking`:** Most Python apps should use `Type=simple`. Only use `Type=forking` if the app explicitly daemonizes itself (rare).
- **nginx reload vs restart:** Use `reload` for config changes (zero-downtime), `restart` only when the binary itself changed.
- **client_max_body_size:** Default is 1MB — raise it if your app accepts file uploads.
- **WebSocket:** If the app streams responses (SSE, WebSocket), you MUST set `proxy_set_header Upgrade` and `proxy_set_header Connection "upgrade"` — otherwise streaming breaks behind nginx.
