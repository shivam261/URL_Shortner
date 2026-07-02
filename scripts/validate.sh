#!/bin/bash
set -e

echo "Starting application validation loop..."

# Poll the application up to 10 times, waiting 2 seconds between attempts
for i in {1..10}; do
  # We temporarily allow curl to fail (no -e crash) inside the condition check
  if curl -f http://127.0.0.1:8000/health > /dev/null 2>&1; then
    echo "Application is up and healthy!"
    exit 0
  fi
  
  echo "Application port 8000 not open yet. Retrying in 2 seconds (Attempt $i/10)..."
  sleep 2
done

echo "Validation failed: Uvicorn application did not start within 20 seconds."
exit 1