#!/bin/bash
set -e

cd /home/ec2-user/myapp
nohup uv run uvicorn main:app --host 0.0.0.0 --port 8000 > app.log 2>&1 &