#!/bin/bash

# 等待容器健康的函数，带超时
wait_for_healthy() {
  local container=$1
  local timeout=120  # 2分钟超时
  local elapsed=0
  
  while [ $elapsed -lt $timeout ]; do
    status=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null || echo "not_found")
    if [ "$status" == "healthy" ]; then
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
    if [ $((elapsed % 10)) -eq 0 ]; then
      echo "  等待中... (${elapsed}s)"
    fi
  done
  
  echo "❌ 超时：$container 在 ${timeout}s 内未就绪"
  echo "💡 查看日志: docker-compose logs $container"
  return 1
}

echo "📦 启动 Docker Compose 服务..."
docker-compose up -d

echo ""

# -------------------------------------
# 等待各服务就绪
# -------------------------------------
echo "⏳ 等待 Zookeeper 就绪..."
wait_for_healthy zookeeper && echo "✅ Zookeeper 已就绪" || exit 1

echo "⏳ 等待 Kafka 就绪..."
wait_for_healthy kafka && echo "✅ Kafka 已就绪" || exit 1

echo "⏳ 等待 Spark Master 就绪..."
wait_for_healthy spark-master && echo "✅ Spark Master 已就绪" || exit 1

echo "⏳ 等待 Spark Worker 就绪..."
wait_for_healthy spark-worker && echo "✅ Spark Worker 已就绪" || exit 1

echo "⏳ 等待 Flink JobManager 就绪..."
wait_for_healthy flink-jobmanager && echo "✅ Flink JobManager 已就绪" || exit 1

echo ""
echo "🎉 学习环境已全部启动完成！"
echo ""
echo "📍 服务访问地址："
echo "  ✅ Kafka: localhost:9092"
echo "  ✅ Spark Master UI: http://localhost:8080"
echo "  ✅ Spark Worker UI: http://localhost:8082"
echo "  ✅ Flink JobManager UI: http://localhost:8081"
echo ""
echo "📊 容器状态："
docker-compose ps
echo ""
echo "📝 常用命令："
echo "  - 查看日志: docker-compose logs -f [服务名]"
echo "  - 查看所有日志: docker-compose logs -f"
echo "  - 停止环境: ./cleanup.sh"
echo "  - 重启服务: docker-compose restart [服务名]"
