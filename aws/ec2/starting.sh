#!/bin/bash

# Update all installed packages to latest versions
sudo dnf update -y

# --- Swap setup (t3.micro has only 1GB RAM, needed to avoid OOM crashes) ---
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# --- Install required software ---
# Removed Node/pnpm/pm2. Kept ruby (CodeDeploy), wget, and nginx.
# Added curl and git, which uv occasionally needs for pulling specific package types.
sudo dnf install -y ruby wget nginx curl git

# --- Install uv globally for ec2-user ---
# Installing it now so it's ready before CodeDeploy even connects
sudo -i -u ec2-user bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# --- CodeDeploy agent setup ---
cd /home/ec2-user
# ⚠️ REPLACE <region> WITH YOUR ACTUAL AWS REGION (e.g., ap-south-1)
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent

# --- nginx reverse proxy setup for FastAPI ---
# Forward all traffic from port 80 to port 8000 (where Uvicorn runs)
sudo tee /etc/nginx/conf.d/fastapi.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:8000;       # send requests to FastAPI
        
        # Standard headers for backend APIs to know the real client IP
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable nginx to start automatically on boot
sudo systemctl enable nginx
sudo systemctl start nginx

# --- App directory setup ---
# Created 'myapp' to exactly match the destination in your appspec.yml
mkdir -p /home/ec2-user/myapp
sudo chown -R ec2-user:ec2-user /home/ec2-user/myapp
# --- FastAPI Log Rotation Setup ---
# Automatically rotate, compress, and clear app.log daily without crashing Uvicorn
sudo tee /etc/logrotate.d/fastapi > /dev/null <<'EOF'
/home/ec2-user/myapp/app.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF