#!/bin/bash
set -e

cd /home/ec2-user/myapp

# Tell the script exactly where uv is located
export PATH="/home/ec2-user/.local/bin:$PATH"

# Start Uvicorn in the background, redirecting stdout, stderr, AND stdin
nohup uv run uvicorn main:app --host 0.0.0.0 --port 8000 > app.log 2>&1 < /dev/null &