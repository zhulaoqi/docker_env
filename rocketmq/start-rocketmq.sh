#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROCKETMQ_IMAGE="apache/rocketmq:4.9.7"
DASHBOARD_IMAGE="apacherocketmq/rocketmq-dashboard:latest"

echo "✅ 使用 Apache RocketMQ 官方镜像 4.9.7（稳定版本）"
echo "⚠️  通过 Rosetta 2 模拟 amd64 架构运行（ARM Mac 兼容）"
echo ""

# 检查并拉取 RocketMQ 镜像
if ! docker image inspect "$ROCKETMQ_IMAGE" >/dev/null 2>&1; then
  echo "首次启动，正在拉取 RocketMQ 镜像..."
  docker pull "$ROCKETMQ_IMAGE" || echo "⚠️  镜像拉取失败，docker-compose 会自动重试"
else
  echo "RocketMQ 镜像已存在，跳过拉取"
fi

# 检查并拉取 Dashboard 镜像
if ! docker image inspect "$DASHBOARD_IMAGE" >/dev/null 2>&1; then
  echo "正在拉取 Dashboard 镜像..."
  docker pull "$DASHBOARD_IMAGE" || echo "⚠️  镜像拉取失败，docker-compose 会自动重试"
else
  echo "Dashboard 镜像已存在，跳过拉取"
fi

echo ""
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
echo "🎉 RocketMQ 环境启动成功（含可视化界面）！"
echo ""
echo "📍 RocketMQ Dashboard（可视化管理界面）："
echo "  - URL: http://localhost:8080"
echo "  - 功能: Topic管理、消息查询、消费者监控等"
echo ""
echo "📍 RocketMQ 连接信息："
echo "  - NameServer: localhost:9876"
echo "  - Broker: localhost:10911"
echo ""
echo "💡 使用提示："
echo "  - 在 Dashboard 界面可以直接创建 Topic、发送/查询消息"
echo "  - 支持 ARM64 原生运行（已禁用 RocksDB）"
echo ""
echo "💡 管理命令："
echo "  - 查看日志: docker-compose logs -f"
echo "  - 停止服务: ./stop-rocketmq.sh"
echo "  - 清理环境: ./cleanup-rocketmq.sh"
