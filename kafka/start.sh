#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ZK_IMAGE="confluentinc/cp-zookeeper:7.9.1"
KAFKA_IMAGE="confluentinc/cp-kafka:7.9.1"
UI_IMAGE="provectuslabs/kafka-ui:latest"

# 检查并拉取 Zookeeper 镜像
if ! docker image inspect "$ZK_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Zookeeper image (supports arm64 & amd64)..."
  if ! docker pull "$ZK_IMAGE"; then
    echo "Failed to pull Zookeeper image."
    exit 1
  fi
else
  echo "Zookeeper image already exists, skipping pull."
fi

# 检查并拉取 Kafka 镜像
if ! docker image inspect "$KAFKA_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Kafka image (supports arm64 & amd64)..."
  if ! docker pull "$KAFKA_IMAGE"; then
    echo "Failed to pull Kafka image."
    exit 1
  fi
else
  echo "Kafka image already exists, skipping pull."
fi

# 检查并拉取 Kafka UI 镜像
if ! docker image inspect "$UI_IMAGE" >/dev/null 2>&1; then
  echo "Pulling Kafka UI image..."
  if ! docker pull "$UI_IMAGE"; then
    echo "Failed to pull Kafka UI image."
    exit 1
  fi
else
  echo "Kafka UI image already exists, skipping pull."
fi

echo ""
echo "Starting Kafka environment with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."
echo ""

# 等待 Zookeeper 健康
echo "⏳ Waiting for Zookeeper..."
timeout=60
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec kafka-zookeeper bash -c "echo srvr | nc localhost 2181" >/dev/null 2>&1; then
    echo "✅ Zookeeper is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ Zookeeper did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs zookeeper"
  exit 1
fi

# 等待 Kafka 健康
echo "⏳ Waiting for Kafka..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec kafka kafka-topics --bootstrap-server localhost:9093 --list >/dev/null 2>&1; then
    echo "✅ Kafka is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ Kafka did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs kafka"
  exit 1
fi

# 等待 Kafka UI 健康
echo "⏳ Waiting for Kafka UI..."
timeout=90
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec kafka-ui wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health >/dev/null 2>&1; then
    echo "✅ Kafka UI is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo "⚠️  Kafka UI may still be starting, check manually: http://localhost:8088"
fi

echo ""
echo "🎉 Kafka 环境启动成功！"
echo ""
echo "📍 Kafka 连接信息："
echo "  - Bootstrap Server (外部): localhost:9092"
echo "  - Bootstrap Server (容器间): kafka:9093"
echo "  - Zookeeper: localhost:2181"
echo ""
echo "📍 Kafka UI 可视化："
echo "  - 地址: http://localhost:8088"
echo "  - 功能: Topic 管理、消息浏览、Consumer Group 监控"
echo ""
echo "💡 快速测试："
echo "  # 创建 Topic"
echo "  docker exec kafka kafka-topics --bootstrap-server localhost:9093 --create --topic test-topic --partitions 3 --replication-factor 1"
echo ""
echo "  # 生产消息"
echo "  docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9093 --topic test-topic"
echo ""
echo "  # 消费消息"
echo "  docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic test-topic --from-beginning"
echo ""
echo "💡 管理命令："
echo "  - 查看日志: docker-compose logs -f"
echo "  - 停止服务: ./stop.sh"
echo "  - 清理环境: ./cleanup.sh"
