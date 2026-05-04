# Bare-metal Linux Deploy Files

Drop-in systemd units used to host this fork on a Lighthouse / VPS without Docker.
See repository root README for the upstream project; these files only cover the
self-host bits we layered on top.

## Layout

```
deploy/
├── dailyhot-api.service              → /etc/systemd/system/dailyhot-api.service
├── dailyhot-api-on-failure.service   → /etc/systemd/system/dailyhot-api-on-failure.service
├── on-failure.sh                     → /usr/local/lib/dailyhot/on-failure.sh
└── README.md
```

## Install

```bash
# Project source
git clone https://github.com/xsmyhgz/DailyHotApi /opt/dailyhot-api
cd /opt/dailyhot-api
cp .env.example .env  # then edit: PORT=6688 USE_LOG_FILE=false CACHE_TTL=300 ALLOWED_DOMAIN=*
npm install --no-audit --no-fund
npm run build
npm prune --omit=dev
npm cache clean --force

# Systemd
install -m 0755 deploy/on-failure.sh /usr/local/lib/dailyhot/on-failure.sh
install -m 0644 deploy/dailyhot-api.service /etc/systemd/system/
install -m 0644 deploy/dailyhot-api-on-failure.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now dailyhot-api

# Journal cap (prevent disk runaway)
sed -i 's/^#\?SystemMaxUse=.*/SystemMaxUse=200M/' /etc/systemd/journald.conf
grep -q '^SystemMaxUse=' /etc/systemd/journald.conf || echo 'SystemMaxUse=200M' >> /etc/systemd/journald.conf
systemctl restart systemd-journald
```

## Notes

- `NODE_ENV=docker` is required: upstream `src/index.ts` only starts the server when
  `NODE_ENV` is `development` or `docker`. `production` is a silent no-op.
- `OnFailure=` writes a timestamped line to `/var/log/dailyhot-failures.log` whenever
  systemd considers the unit failed. Hook in remote alerting from there.
- Open the listening port (default 6688) in both the cloud-side firewall (Lighthouse
  console / security group) and the host firewall (`ufw allow 6688/tcp`).
