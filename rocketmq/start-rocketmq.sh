#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROCKETMQ_IMAGE="apache/rocketmq:5.2.0"
DASHBOARD_IMAGE="apacherocketmq/rocketmq-dashboard:latest"

# 检查并拉取 RocketMQ 镜像（ARM64）
if ! docker image inspect "$ROCKETMQ_IMAGE" >/dev/null 2>&1; then
  echo "Pulling RocketMQ image (ARM64)..."
  if ! docker pull --platform linux/arm64 "$ROCKETMQ_IMAGE"; then
    echo "Failed to pull RocketMQ image."
    exit 1
  fi
else
  echo "RocketMQ image already exists, skipping pull."
fi

# 检查并拉取 Dashboard 镜像（ARM64）
if ! docker image inspect "$DASHBOARD_IMAGE" >/dev/null 2>&1; then
  echo "Pulling RocketMQ Dashboard image (ARM64)..."
  if ! docker pull --platform linux/arm64 "$DASHBOARD_IMAGE"; then
    echo "Failed to pull Dashboard image."
    exit 1
  fi
else
  echo "Dashboard image already exists, skipping pull."
fi

echo "Starting RocketMQ with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."
echo ""

# 等待 NameServer
echo "⏳ Waiting for NameServer..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec rocketmq-namesrv sh mqadmin clusterList -n localhost:9876 >/dev/null 2>&1; then
    echo "✅ NameServer is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ NameServer did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs namesrv"
  exit 1
fi

# 等待 Broker
echo "⏳ Waiting for Broker..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker exec rocketmq-broker sh mqadmin clusterList -n namesrv:9876 2>/dev/null | grep -q "BrokerName"; then
    echo "✅ Broker is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ Broker did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs broker"
  exit 1
fi

# 等待 Dashboard
echo "⏳ Waiting for Dashboard..."
timeout=60
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if curl -fsS "http://localhost:8080/" 2>/dev/null >/dev/null; then
    echo "✅ Dashboard is ready"
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
done

if [ $elapsed -ge $timeout ]; then
  echo "❌ Dashboard did not become healthy within ${timeout}s."
  echo "Check logs: docker-compose logs dashboard"
  exit 1
fi

echo ""
echo "🎉 RocketMQ 环境启动成功！"
echo ""
echo "📍 RocketMQ 连接信息："
echo "  - NameServer: localhost:9876"
echo "  - Broker: localhost:10911"
echo ""
echo "📍 RocketMQ Dashboard："
echo "  - URL: http://localhost:8080"
echo "  - 功能: Topic管理、消息查询、消费者监控等"
echo ""
echo "💡 快速测试："
echo "  # 创建 Topic"
echo "  docker exec rocketmq-broker sh mqadmin updateTopic -n namesrv:9876 -t TestTopic -c DefaultCluster"
echo ""
echo "  # 发送消息"
echo "  docker exec rocketmq-broker sh mqadmin sendMessage -n namesrv:9876 -t TestTopic -p 'Hello RocketMQ'"
echo ""
echo "  # 消费消息"
echo "  docker exec rocketmq-broker sh mqadmin consumeMessage -n namesrv:9876 -t TestTopic -g TestGroup"
echo ""
echo "💡 管理命令："
echo "  - 查看日志: docker-compose logs -f"
echo "  - 停止服务: ./stop-rocketmq.sh"
echo "  - 清理环境: ./cleanup-rocketmq.sh"
