#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MONGO_IMAGE="mongo:7.0"

# 检查并拉取 MongoDB 镜像
if ! docker image inspect "$MONGO_IMAGE" >/dev/null 2>&1; then
  echo "Pulling MongoDB image (supports arm64 & amd64)..."
  if ! docker pull "$MONGO_IMAGE"; then
    echo "Failed to pull MongoDB image."
    exit 1
  fi
else
  echo "MongoDB image already exists, skipping pull."
fi

echo "Starting MongoDB with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for MongoDB to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec mongodb mongosh --quiet --eval 'db.runCommand({ ping: 1 })' >/dev/null 2>&1; then
    echo ""
    echo "✅ MongoDB is ready"
    echo ""
    echo "📍 MongoDB 连接信息："
    echo "  - Host: localhost"
    echo "  - Port: 27017"
    echo "  - Root Username: root"
    echo "  - Root Password: root123456"
    echo "  - Database: testdb"
    echo ""
    echo "💡 快速测试："
    echo "  docker exec -it mongodb mongosh -u root -p root123456 --authenticationDatabase admin"
    echo ""
    echo "💡 管理命令："
    echo "  - 查看日志: docker-compose logs -f mongodb"
    echo "  - 停止服务: ./stop.sh"
    echo "  - 清理环境: ./cleanup.sh"
    exit 0
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

echo ""
echo "❌ MongoDB did not become healthy within ${timeout}s."
echo "Check logs: docker-compose logs -f mongodb"
exit 1
