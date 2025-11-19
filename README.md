# 大数据学习环境 Docker 配置

一键启动 Kafka、Spark、Flink 学习环境

## 📦 包含的服务

| 服务 | 版本 | 端口 | 说明 |
|-----|------|------|------|
| Zookeeper | 7.9.1 | 2181 | Kafka 依赖 |
| Kafka | 7.9.1 | 9092 | 消息队列 |
| Spark Master | 3.5.1 | 8080, 7077 | Spark 主节点 |
| Spark Worker | 3.5.1 | 8082 | Spark 工作节点 |
| Flink JobManager | 1.18.1 | 8081 | Flink 作业管理器 |
| Flink TaskManager | 1.18.1 | - | Flink 任务管理器 |

## 🚀 快速开始

### 启动环境
```bash
./start-learning-env.sh
```
这个脚本会：
- 启动所有服务
- 等待所有服务健康检查通过
- 显示服务访问地址
- 显示容器状态

### 访问服务

启动成功后，可以通过以下地址访问：

- **Kafka**: `localhost:9092`
- **Spark Master UI**: http://localhost:8080
- **Spark Worker UI**: http://localhost:8082
- **Flink UI**: http://localhost:8081

## 🛠️ 可用脚本

### 1. `start-learning-env.sh` - 完整启动脚本
启动所有服务并等待就绪
```bash
./start-learning-env.sh
```

### 2. `cleanup.sh` - 完全清理脚本
停止并删除所有容器和卷（保留镜像）
```bash
./cleanup.sh
```
⚠️ 注意：这会删除所有数据！

### 3. `quick-stop.sh` - 快速停止脚本
仅停止容器，保留数据
```bash
./quick-stop.sh
```

### 4. `diagnose.sh` - 诊断工具
检查所有服务状态，排查问题
```bash
./diagnose.sh
```

## 📝 常用 Docker Compose 命令

### 查看容器状态
```bash
docker-compose ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f kafka
docker-compose logs -f spark-master
docker-compose logs -f flink-jobmanager
```

### 重启服务
```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart kafka
```

### 停止服务
```bash
# 停止所有服务（保留容器）
docker-compose stop

# 停止特定服务
docker-compose stop kafka
```

### 启动已停止的服务
```bash
# 启动所有服务
docker-compose start

# 启动特定服务
docker-compose start kafka
```

### 查看容器资源占用
```bash
docker stats
```

## 🔍 故障排查

### 问题：容器无法启动

1. 检查端口是否被占用
```bash
# macOS
lsof -i :8080
lsof -i :9092

# 或使用诊断脚本
./diagnose.sh
```

2. 查看容器日志
```bash
docker-compose logs [服务名]
```

3. 检查容器健康状态
```bash
docker-compose ps
docker inspect [容器名]
```

### 问题：服务启动慢

- 所有服务都配置了健康检查
- 首次启动需要下载镜像，可能需要较长时间
- 等待时间最长 2 分钟，超时会自动退出

### 问题：磁盘空间不足

清理未使用的 Docker 资源：
```bash
# 清理未使用的镜像
docker image prune -a

# 清理所有未使用的资源
docker system prune -a
```

## 🗂️ 数据持久化

数据卷：
- `spark-data`: Spark 临时数据
- `flink-data`: Flink 临时数据

查看卷：
```bash
docker volume ls
```

## 📚 学习资源

- [Kafka 官方文档](https://kafka.apache.org/documentation/)
- [Spark 官方文档](https://spark.apache.org/docs/latest/)
- [Flink 官方文档](https://flink.apache.org/)

## ⚙️ 配置修改

如需修改配置，编辑 `docker-compose.yaml` 文件：

- 修改端口映射
- 调整资源限制（内存、CPU）
- 添加环境变量
- 更改镜像版本

修改后重新启动：
```bash
./cleanup.sh
./start-learning-env.sh
```

## 💡 提示

- 首次启动需要下载镜像，请耐心等待
- 建议至少 8GB 可用内存
- 所有脚本都已配置错误处理和超时机制
- 使用 `./diagnose.sh` 可以快速诊断问题

