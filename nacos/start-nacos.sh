#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

NACOS_IMAGE="nacos/nacos-server:v2.3.2-slim"

# 检查镜像是否已存在
if ! docker image inspect "$NACOS_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Nacos slim image (supports arm64 & amd64)..."
  if ! docker pull "$NACOS_IMAGE"; then
    echo "Failed to pull nacos image."
    echo "Try these steps then rerun:"
    echo "  docker builder prune -af"
    echo "  docker image rm -f $NACOS_IMAGE"
    exit 1
  fi
else
  echo "Image already exists, skipping pull."
fi

echo "Starting Nacos with docker-compose..."
docker-compose up -d

echo "Waiting for Nacos to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if curl -fsS "http://localhost:8848/nacos/actuator/health" 2>/dev/null | grep -q "UP"; then
    echo ""
    echo "✅ Nacos is healthy and ready!"
    echo ""
    echo "📍 Console: http://localhost:8848/nacos"
    echo "🔑 Default user: nacos / nacos"
    echo ""
    echo "💡 Useful commands:"
    echo "  - View logs: docker-compose logs -f nacos"
    echo "  - Stop: ./stop-nacos.sh"
    echo "  - Cleanup: ./cleanup-nacos.sh"
    exit 0
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

echo ""
echo "❌ Nacos did not become healthy within ${timeout}s."
echo "Check logs: docker-compose logs -f nacos"
exit 1
