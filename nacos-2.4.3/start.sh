#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE_NAME="nacos-local:2.4.3"

# 检查自定义镜像是否已构建
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "⚠️  自定义镜像不存在，自动执行构建..."
  echo ""
  ./build.sh
  echo ""
fi

echo "Starting Nacos 2.4.3 with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for Nacos to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if curl -fsS "http://localhost:8848/nacos/" 2>/dev/null >/dev/null; then
    echo ""
    echo "✅ Nacos 2.4.3 启动成功！"
    echo ""
    echo "📍 Nacos 控制台："
    echo "  - 地址: http://localhost:8848/nacos"
    echo "  - 用户名: nacos"
    echo "  - 密码: nacos"
    echo ""
    echo "📍 端口说明："
    echo "  - 8848: HTTP API / 控制台"
    echo "  - 9848: gRPC 客户端通信"
    echo "  - 9849: gRPC 集群通信"
    echo ""
    echo "💡 管理命令："
    echo "  - 查看日志: docker-compose logs -f nacos"
    echo "  - 停止服务: ./stop.sh"
    echo "  - 清理环境: ./cleanup.sh"
    echo "  - 重新构建: ./build.sh"
    exit 0
  fi
  sleep 3
  elapsed=$((elapsed + 3))
  if [ $((elapsed % 15)) -eq 0 ]; then
    echo "  waiting... (${elapsed}s)"
  fi
done

echo ""
echo "❌ Nacos 未能在 ${timeout}s 内启动成功"
echo "Check logs: docker-compose logs -f nacos"
exit 1
