#!/bin/bash
set -e

echo "starting server setup..."

# detect package manager
if command -v dnf >/dev/null 2>&1; then
    PKG=dnf
else
    PKG=yum
fi

sudo $PKG update -y
sudo $PKG install -y nodejs npm nginx git

sudo mkdir -p /opt/app/releases
sudo mkdir -p /opt/app/shared

sudo tee /etc/nginx/conf.d/app.conf > /dev/null <<'EOF'
server {
    listen 80;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

sudo rm -f /etc/nginx/conf.d/default.conf || true

sudo systemctl enable nginx
sudo systemctl restart nginx

echo "setup complete"
