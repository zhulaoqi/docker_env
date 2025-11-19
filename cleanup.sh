#!/bin/bash
# -----------------------------
# Docker 学习环境安全清理脚本
# 停止容器、删除容器、卷、网络，但保留镜像
# -----------------------------

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Docker 学习环境清理工具"
echo "======================================"
echo ""

# 显示当前运行的容器
echo "📊 当前容器状态："
docker-compose ps
echo ""

# 询问确认
read -p "确定要停止并清理所有容器吗？(y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo "❌ 已取消清理操作"
  exit 0
fi

echo ""
echo "🛑 停止并删除所有容器..."
if docker-compose down -v; then
  echo "✅ 容器已停止并删除"
else
  echo "⚠️  停止容器时出现错误"
fi

echo ""
echo "🗑️  删除未使用的卷..."
if docker volume prune -f; then
  echo "✅ 卷清理完成"
else
  echo "⚠️  卷清理时出现错误"
fi

echo ""
echo "🌐 删除未使用的网络..."
if docker network prune -f; then
  echo "✅ 网络清理完成"
else
  echo "⚠️  网络清理时出现错误"
fi

echo ""
echo "💾 镜像已保留，下次启动无需重新下载"
echo ""
echo "✅ 清理完成！"
echo ""
echo "💡 提示："
echo "  - 重新启动环境: ./start-learning-env.sh"
echo "  - 查看镜像列表: docker images"
