#!/bin/bash
set -e

cd /home/ec2-user/myapp

# Force the script to know where uv lives in the ec2-user directory
export PATH="/home/ec2-user/.local/bin:$PATH"

# If uv is somehow missing, download it on the fly
if ! command -v uv &> /dev/null; then
    echo "uv not found in PATH, installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Sync dependencies using your pipeline logic
uv sync --frozen || uv sync