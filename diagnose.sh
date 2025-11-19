#!/bin/bash
# 诊断脚本：快速检查所有服务状态

echo "🔍 Docker 学习环境诊断工具"
echo "======================================"
echo ""

# 检查 Docker 是否运行
echo "1️⃣ 检查 Docker 服务状态..."
if docker info >/dev/null 2>&1; then
  echo "  ✅ Docker 运行正常"
else
  echo "  ❌ Docker 未运行或无权限"
  exit 1
fi
echo ""

# 显示所有容器状态
echo "2️⃣ 容器状态概览："
echo ""
docker-compose ps
echo ""

# 检查每个容器的健康状态
echo "3️⃣ 容器健康检查："
echo ""
containers=("zookeeper" "kafka" "spark-master" "spark-worker" "flink-jobmanager" "flink-taskmanager")

for container in "${containers[@]}"; do
  if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
    status=$(docker inspect -f '{{.State.Status}}' $container 2>/dev/null)
    health=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null || echo "无健康检查")
    echo "  📦 $container:"
    echo "     状态: $status"
    echo "     健康: $health"
  else
    echo "  📦 $container: ❌ 未运行"
  fi
  echo ""
done

# 检查端口占用
echo "4️⃣ 端口监听状态："
echo ""
ports=("2181:Zookeeper" "9092:Kafka" "8080:Spark-Master" "8082:Spark-Worker" "8081:Flink" "7077:Spark-RPC")

for port_info in "${ports[@]}"; do
  port="${port_info%%:*}"
  name="${port_info##*:}"
  if lsof -i :$port >/dev/null 2>&1 || netstat -an 2>/dev/null | grep -q ":$port "; then
    echo "  ✅ $port ($name) - 正在监听"
  else
    echo "  ❌ $port ($name) - 未监听"
  fi
done

echo ""
echo "5️⃣ 最近的容器日志（最后10行）："
echo ""
echo "如需查看完整日志，使用："
echo "  docker-compose logs -f [服务名]"
echo ""

# 提供快速查看日志的选项
read -p "是否要查看某个服务的日志？(输入服务名或按回车跳过): " service_name
if [ ! -z "$service_name" ]; then
  echo ""
  echo "显示 $service_name 的最后50行日志："
  echo "======================================"
  docker-compose logs --tail=50 $service_name
fi

echo ""
echo "诊断完成！"

