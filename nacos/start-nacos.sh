#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Starting Nacos with docker-compose..."
docker-compose up -d --build

echo "Waiting for Nacos to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if curl -fsS "http://localhost:8848/nacos/v1/console/health" | grep -q "UP"; then
    echo "Nacos is healthy."
    echo "Console: http://localhost:8848/nacos"
    echo "Default user: nacos / nacos"
    exit 0
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

echo "Nacos did not become healthy within ${timeout}s."
echo "Check logs: docker-compose logs -f nacos"
exit 1
