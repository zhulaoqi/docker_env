# Kafka Docker 环境

使用 Docker Compose 快速启动 Kafka + Zookeeper + Kafka UI（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

| 组件 | 镜像 | 端口 |
|------|------|------|
| Zookeeper | `confluentinc/cp-zookeeper:7.9.1` | 2181 |
| Kafka Broker | `confluentinc/cp-kafka:7.9.1` | 9092 (外部) / 9093 (内部) |
| Kafka UI | `provectuslabs/kafka-ui:latest` | 8088 |

- **架构支持**: ARM64 (Apple Silicon) + AMD64
- **模式**: 单 Broker

## 🚀 快速开始

### 1. 启动 Kafka
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/kafka
chmod +x *.sh
./start.sh
```

脚本会自动：
- 拉取所有镜像（Zookeeper、Kafka、Kafka UI）
- 按依赖顺序启动容器
- 等待所有服务健康检查通过
- 显示连接信息和常用命令

### 2. 连接信息

| 服务 | 地址 |
|------|------|
| Kafka Bootstrap (外部连接) | `localhost:9092` |
| Kafka Bootstrap (容器间) | `kafka:9093` |
| Zookeeper | `localhost:2181` |
| Kafka UI | http://localhost:8088 |

## 🖥️ Kafka UI 可视化

启动后打开浏览器访问 **http://localhost:8088** 即可使用 Kafka UI：

- **Dashboard**: 查看集群概览、Broker 状态
- **Topics**: 创建/删除 Topic，查看分区和配置
- **Messages**: 浏览 Topic 中的消息内容
- **Consumers**: 监控 Consumer Group 状态和 Lag
- **Schema Registry**: 管理 Schema（如有接入）

## 🛠️ 管理命令

### 停止服务（保留数据）
```bash
./stop.sh
```

### 清理环境（删除所有数据）
```bash
./cleanup.sh
```

⚠️ 注意：这会删除容器、卷和所有 Kafka 数据！

### 重启服务
```bash
./stop.sh
./start.sh
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看单个服务日志
docker-compose logs -f kafka
docker-compose logs -f zookeeper
docker-compose logs -f kafka-ui
```

### 查看容器状态
```bash
docker-compose ps
```

## 💻 快速测试

### Topic 管理
```bash
# 创建 Topic
docker exec kafka kafka-topics --bootstrap-server localhost:9093 \
  --create --topic test-topic --partitions 3 --replication-factor 1

# 查看 Topic 列表
docker exec kafka kafka-topics --bootstrap-server localhost:9093 --list

# 查看 Topic 详情
docker exec kafka kafka-topics --bootstrap-server localhost:9093 \
  --describe --topic test-topic

# 删除 Topic
docker exec kafka kafka-topics --bootstrap-server localhost:9093 \
  --delete --topic test-topic
```

### 生产 & 消费消息
```bash
# 生产消息（输入消息后按回车发送，Ctrl+C 退出）
docker exec -it kafka kafka-console-producer \
  --bootstrap-server localhost:9093 --topic test-topic

# 消费消息（从头开始消费）
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9093 --topic test-topic --from-beginning

# 消费消息（带 Consumer Group）
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9093 --topic test-topic \
  --group my-group --from-beginning
```

### Consumer Group 管理
```bash
# 查看 Consumer Group 列表
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9093 --list

# 查看 Consumer Group 详情（Lag 信息）
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9093 --describe --group my-group
```

## 📝 使用示例

### Java 连接示例（Spring Boot）
```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: my-app-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
```

### Python 连接示例
```python
from kafka import KafkaProducer, KafkaConsumer

# 生产者
producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: v.encode('utf-8')
)
producer.send('test-topic', value='Hello Kafka!')
producer.flush()
producer.close()

# 消费者
consumer = KafkaConsumer(
    'test-topic',
    bootstrap_servers='localhost:9092',
    group_id='my-python-group',
    auto_offset_reset='earliest',
    value_deserializer=lambda m: m.decode('utf-8')
)
for msg in consumer:
    print(f"Received: {msg.value}")
```

### Node.js 连接示例
```javascript
const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: ['localhost:9092'],
});

// 生产者
async function produce() {
  const producer = kafka.producer();
  await producer.connect();
  await producer.send({
    topic: 'test-topic',
    messages: [{ value: 'Hello Kafka from Node.js!' }],
  });
  await producer.disconnect();
}

// 消费者
async function consume() {
  const consumer = kafka.consumer({ groupId: 'my-node-group' });
  await consumer.connect();
  await consumer.subscribe({ topic: 'test-topic', fromBeginning: true });
  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log(`Received: ${message.value.toString()}`);
    },
  });
}
```

### Go 连接示例
```go
import "github.com/segmentio/kafka-go"

// 生产者
writer := &kafka.Writer{
    Addr:  kafka.TCP("localhost:9092"),
    Topic: "test-topic",
}
writer.WriteMessages(context.Background(),
    kafka.Message{Value: []byte("Hello Kafka from Go!")},
)

// 消费者
reader := kafka.NewReader(kafka.ReaderConfig{
    Brokers: []string{"localhost:9092"},
    Topic:   "test-topic",
    GroupID: "my-go-group",
})
msg, _ := reader.ReadMessage(context.Background())
fmt.Println(string(msg.Value))
```

## 📁 文件结构

```
kafka/
├── docker-compose.yaml   # Docker Compose 配置（Zookeeper + Kafka + Kafka UI）
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── cleanup.sh            # 清理脚本
└── README.md             # 使用文档
```

## 📊 数据持久化

数据会保存在 Docker 卷中：
- `zk-data`: Zookeeper 数据
- `zk-log`: Zookeeper 事务日志
- `kafka-data`: Kafka 消息数据

查看卷：
```bash
docker volume ls | grep kafka
```

## 🔧 端口说明

| 端口 | 服务 | 说明 |
|------|------|------|
| 2181 | Zookeeper | 客户端连接端口 |
| 9092 | Kafka | 外部客户端连接（宿主机应用使用此端口） |
| 9093 | Kafka | 内部通信端口（容器间使用） |
| 8088 | Kafka UI | Web 管理界面 |

## 🔍 故障排查

### 问题：Kafka 无法启动

1. 查看日志
```bash
docker-compose logs kafka
docker-compose logs zookeeper
```

2. 检查端口占用
```bash
lsof -i :9092
lsof -i :2181
lsof -i :8088
```

3. 清理并重新启动
```bash
./cleanup.sh
./start.sh
```

### 问题：客户端连接失败

- 宿主机应用使用 `localhost:9092` 连接
- Docker 容器内应用使用 `kafka:9093` 连接
- 确认 Kafka 已完全启动：`docker exec kafka kafka-topics --bootstrap-server localhost:9093 --list`

### 问题：Kafka UI 打不开

Kafka UI 依赖 Kafka 启动完成，可能需要额外等待：
```bash
docker-compose logs -f kafka-ui
```

## 📚 更多资源

- [Apache Kafka 官方文档](https://kafka.apache.org/documentation/)
- [Confluent Platform 文档](https://docs.confluent.io/platform/current/overview.html)
- [Kafka UI GitHub](https://github.com/provectus/kafka-ui)
- [KafkaJS (Node.js)](https://kafka.js.org/)
- [kafka-python](https://kafka-python.readthedocs.io/)

## 💡 提示

- Confluent 镜像原生支持 ARM64（Apple Silicon Mac）
- 数据持久化到 Docker 卷，重启不会丢失
- Kafka UI 无需登录，直接访问 http://localhost:8088
- 外部连接用 `localhost:9092`，容器间连接用 `kafka:9093`
- 首次启动需要下载约 1.5GB 镜像，请耐心等待
- 如果与 bigdata 目录下的 Kafka 同时运行会端口冲突，请先停止其中一个
