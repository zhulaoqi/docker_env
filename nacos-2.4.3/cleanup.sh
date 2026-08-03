#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "⚠️  警告：此操作将删除 Nacos 2.4.3 容器、数据卷和所有配置数据！"
read -p "确定要继续吗？(y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo "❌ 已取消清理操作"
  exit 0
fi

echo ""
echo "Cleaning Nacos 2.4.3 containers and volumes..."
docker-compose down -v

echo ""
echo "✅ 清理完成！"
echo ""
echo "💡 删除镜像（可选）："
echo "  docker image rm nacos-local:2.4.3"
echo "  docker image rm nacos/nacos-server:v2.4.3"
