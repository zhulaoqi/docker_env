#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE_NAME="nacos-local:3.1.1"
BASE_IMAGE="nacos/nacos-server:v3.1.1"

echo "🔨 构建 Nacos 自定义镜像..."
echo "   基础镜像: $BASE_IMAGE"
echo "   目标镜像: $IMAGE_NAME"
echo ""

# 确保基础镜像存在
if ! docker image inspect "$BASE_IMAGE" >/dev/null 2>&1; then
  echo "📥 拉取基础镜像 (supports arm64 & amd64)..."
  if ! docker pull "$BASE_IMAGE"; then
    echo "❌ 拉取基础镜像失败"
    echo "💡 尝试: docker builder prune -af && 重新执行"
    exit 1
  fi
else
  echo "✅ 基础镜像已存在，跳过拉取"
fi

echo ""
echo "🏗️  开始构建..."
docker build -t "$IMAGE_NAME" .

echo ""
echo "✅ 镜像构建完成！"
echo ""
echo "📦 镜像信息："
docker images "$IMAGE_NAME"
echo ""
echo "💡 下一步："
echo "  - 启动服务: ./start.sh"
