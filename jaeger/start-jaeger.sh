#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

JAEGER_IMAGE="jaegertracing/all-in-one:1.53"

# 检查镜像是否已存在
if ! docker image inspect "$JAEGER_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Jaeger all-in-one image (supports arm64 & amd64)..."
  if ! docker pull "$JAEGER_IMAGE"; then
    echo "Failed to pull Jaeger image."
    echo "Try these steps then rerun:"
    echo "  docker builder prune -af"
    echo "  docker image rm -f $JAEGER_IMAGE"
    exit 1
  fi
else
  echo "Image already exists, skipping pull."
fi

echo "Starting Jaeger with docker-compose..."
docker-compose up -d

echo "Waiting for Jaeger to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if curl -fsS "http://localhost:16686/" 2>/dev/null >/dev/null; then
    echo ""
    echo "✅ Jaeger is healthy and ready!"
    echo ""
    echo "📍 Jaeger UI: http://localhost:16686"
    echo ""
    echo "📡 Endpoints:"
    echo "  - Collector HTTP: http://localhost:14268/api/traces"
    echo "  - Collector gRPC: localhost:14250"
    echo "  - Zipkin compatible: http://localhost:9411/api/v2/spans"
    echo "  - Agent (Thrift compact): localhost:6831/udp"
    echo "  - Agent (Thrift binary): localhost:6832/udp"
    echo ""
    echo "💡 Useful commands:"
    echo "  - View logs: docker-compose logs -f jaeger"
    echo "  - Stop: ./stop-jaeger.sh"
    echo "  - Cleanup: ./cleanup-jaeger.sh"
    exit 0
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

echo ""
echo "❌ Jaeger did not become healthy within ${timeout}s."
echo "Check logs: docker-compose logs -f jaeger"
exit 1
