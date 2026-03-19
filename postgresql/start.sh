#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PG_IMAGE="postgres:15"

# 检查并拉取 PostgreSQL 基础镜像
if ! docker image inspect "$PG_IMAGE" >/dev/null 2>&1; then
  echo "Pulling PostgreSQL image (supports arm64 & amd64)..."
  if ! docker pull "$PG_IMAGE"; then
    echo "Failed to pull PostgreSQL image."
    exit 1
  fi
else
  echo "PostgreSQL base image already exists, skipping pull."
fi

echo "Building and starting PostgreSQL with docker-compose..."
docker-compose up -d --build

echo ""
echo "Waiting for PostgreSQL to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec postgresql pg_isready -U root -d testdb >/dev/null 2>&1; then
    echo ""
    echo "✅ PostgreSQL is ready"
    echo ""
    echo "📍 PostgreSQL 连接信息："
    echo "  - Host: localhost"
    echo "  - Port: 5432"
    echo "  - Username: root"
    echo "  - Password: root123456"
    echo "  - Database: testdb"
    echo ""
    echo "💡 快速测试："
    echo "  docker exec -it postgresql psql -U root -d testdb"
    echo ""
    echo "💡 管理命令："
    echo "  - 查看日志: docker-compose logs -f postgresql"
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
echo "❌ PostgreSQL did not become healthy within ${timeout}s."
echo "Check logs: docker-compose logs -f postgresql"
exit 1
