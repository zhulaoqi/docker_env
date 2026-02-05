#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ES_IMAGE="elasticsearch:8.12.2"

# 检查并拉取 Elasticsearch 镜像
if ! docker image inspect "$ES_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Elasticsearch image (supports arm64 & amd64)..."
  if ! docker pull "$ES_IMAGE"; then
    echo "Failed to pull Elasticsearch image."
    exit 1
  fi
else
  echo "Elasticsearch image already exists, skipping pull."
fi

echo "Starting Elasticsearch with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for Elasticsearch to be healthy..."
timeout=180
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if curl -fsS "http://localhost:9200" >/dev/null 2>&1; then
    echo ""
    echo "✅ Elasticsearch is healthy and ready!"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo ""
  echo "❌ Elasticsearch did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs -f elasticsearch"
  exit 1
fi

echo ""
echo "🔧 Running initialization script..."
if bash "$SCRIPT_DIR/init-es.sh"; then
  echo "✅ Elasticsearch initialization completed!"
else
  echo "⚠️  Initialization script failed, but Elasticsearch is running"
  echo "You can manually run: bash init-es.sh"
fi

echo ""
echo "📍 Endpoint: http://localhost:9200"
echo ""
echo "💡 Useful commands:"
echo "  - View logs: docker-compose logs -f elasticsearch"
echo "  - Stop: ./stop.sh"
echo "  - Cleanup: ./cleanup.sh"
