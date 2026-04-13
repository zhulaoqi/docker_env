#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "⚠️  警告：此操作将删除所有 Kafka 容器和数据卷！"
echo "   包含：Zookeeper、Kafka Broker、Kafka UI"
read -p "确定要继续吗？(y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo "❌ 已取消清理操作"
  exit 0
fi

echo ""
echo "Cleaning Kafka containers and volumes..."
docker-compose down -v

echo ""
echo "✅ 清理完成！"
echo ""
echo "💡 删除镜像（可选）："
echo "  docker image rm confluentinc/cp-zookeeper:7.9.1"
echo "  docker image rm confluentinc/cp-kafka:7.9.1"
echo "  docker image rm provectuslabs/kafka-ui:latest"
