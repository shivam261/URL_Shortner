#!/bin/bash
set -e

cd /home/ec2-user/myapp
uv sync --frozen || uv sync