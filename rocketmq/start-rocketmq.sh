#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROCKETMQ_IMAGE="apache/rocketmq:5.1.1"
DASHBOARD_IMAGE="apacherocketmq/rocketmq-dashboard:latest"

echo "✅ 使用 Apache RocketMQ 官方镜像 5.1.1（与 Java 客户端完全对齐）"
echo "✨ TLS 已关闭，使用明文 gRPC（本地开发最简单）"
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
echo "⏳ 等待服务健康检查通过..."
echo ""

# 使用 docker inspect 检查健康状态（更可靠）
timeout=60
elapsed=0
services_ready=false

while [ $elapsed -lt $timeout ]; do
  # 检查各服务健康状态
  namesrv_health=$(docker inspect --format='{{.State.Health.Status}}' rocketmq-namesrv 2>/dev/null || echo "starting")
  broker_health=$(docker inspect --format='{{.State.Health.Status}}' rocketmq-broker 2>/dev/null || echo "starting")
  dashboard_health=$(docker inspect --format='{{.State.Health.Status}}' rocketmq-dashboard 2>/dev/null || echo "starting")
  
  if [ "$namesrv_health" = "healthy" ] && [ "$broker_health" = "healthy" ] && [ "$dashboard_health" = "healthy" ]; then
    services_ready=true
    break
  fi
  
  # 显示进度（每5秒更新一次）
  if [ $((elapsed % 5)) -eq 0 ]; then
    status_msg="  "
    [ "$namesrv_health" = "healthy" ] && status_msg+="✅ NameServer " || status_msg+="⏳ NameServer "
    [ "$broker_health" = "healthy" ] && status_msg+="✅ Broker " || status_msg+="⏳ Broker "
    [ "$dashboard_health" = "healthy" ] && status_msg+="✅ Dashboard" || status_msg+="⏳ Dashboard"
    echo "$status_msg"
  fi
  
  sleep 2
  elapsed=$((elapsed + 2))
done

echo ""
if [ "$services_ready" = "false" ]; then
  echo "⚠️  部分服务健康检查超时（${timeout}秒），当前状态："
  docker-compose ps
  echo ""
  echo "💡 提示: 服务可能仍在启动，可以稍后访问 http://localhost:8080"
  echo "         查看日志: docker-compose logs -f"
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
