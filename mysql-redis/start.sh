#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MYSQL_IMAGE="mysql:8.0"
REDIS_IMAGE="redis:7.2-alpine"

# 检查并拉取 MySQL 镜像
if ! docker image inspect "$MYSQL_IMAGE" >/dev/null 2>&1; then
  echo "Pulling MySQL image (supports arm64 & amd64)..."
  if ! docker pull "$MYSQL_IMAGE"; then
    echo "Failed to pull MySQL image."
    exit 1
  fi
else
  echo "MySQL image already exists, skipping pull."
fi

# 检查并拉取 Redis 镜像
if ! docker image inspect "$REDIS_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Redis image (supports arm64 & amd64)..."
  if ! docker pull "$REDIS_IMAGE"; then
    echo "Failed to pull Redis image."
    exit 1
  fi
else
  echo "Redis image already exists, skipping pull."
fi

echo "Starting MySQL + Redis with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."
echo ""

# 等待 MySQL 健康
echo "⏳ Waiting for MySQL..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec mysql mysqladmin ping -h localhost -uroot -proot123456 >/dev/null 2>&1; then
    echo "✅ MySQL is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ MySQL did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs mysql"
  exit 1
fi

# 等待 Redis 健康
echo "⏳ Waiting for Redis..."
timeout=60
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec redis redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis is ready"
    break
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ Redis did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs redis"
  exit 1
fi

echo ""
echo "🎉 MySQL + Redis 环境启动成功！"
echo ""
echo "📍 MySQL 连接信息："
echo "  - Host: localhost"
echo "  - Port: 3306"
echo "  - Root Password: root123456"
echo "  - Database: testdb"
echo "  - User: testuser / testpass"
echo ""
echo "📍 Redis 连接信息："
echo "  - Host: localhost"
echo "  - Port: 6379"
echo "  - Password: (无，如需设置请编辑 redis.conf)"
echo ""
echo "💡 快速测试："
echo "  MySQL: docker exec -it mysql mysql -uroot -proot123456"
echo "  Redis: docker exec -it redis redis-cli"
echo ""
echo "💡 管理命令："
echo "  - 查看日志: docker-compose logs -f"
echo "  - 停止服务: ./stop.sh"
echo "  - 清理环境: ./cleanup.sh"
