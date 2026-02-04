#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Stopping RocketMQ containers..."
docker-compose stop

echo "✅ Containers stopped successfully"
echo ""
echo "💡 提示："
echo "  - 重新启动: docker-compose start 或 ./start-rocketmq.sh"
echo "  - 完全清理: ./cleanup-rocketmq.sh"
