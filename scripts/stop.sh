#!/bin/bash
set -e

pkill -f "uvicorn main:app" || true