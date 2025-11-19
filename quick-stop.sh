#!/bin/bash
# 快速停止脚本 - 不删除卷，仅停止容器

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "⏸️  快速停止所有容器（保留数据）..."
if docker-compose stop; then
  echo "✅ 所有容器已停止"
  echo ""
  echo "💡 提示："
  echo "  - 重新启动: docker-compose start"
  echo "  - 或使用启动脚本: ./start-learning-env.sh"
  echo "  - 完全清理（删除数据）: ./cleanup.sh"
else
  echo "❌ 停止容器时出现错误"
  exit 1
fi

