# RocketMQ Docker 环境

使用 Docker Compose 快速启动 RocketMQ（支持 Mac ARM64 和 AMD64），包含完整的可视化管理界面。

## 📦 组件信息

| 组件 | 镜像 | 版本 | 说明 |
|------|------|------|------|
| NameServer | apache/rocketmq | 5.1.4 | 路由注册中心 |
| Broker | apache/rocketmq | 5.1.4 | 消息服务器（含 gRPC Proxy） |
| Dashboard | apacherocketmq/rocketmq-dashboard | latest | 可视化管理界面 |

✅ **完全对齐**：使用 Apache RocketMQ 官方 5.1.4 版本（与 Java 客户端版本一致），原生支持 ARM64，已启用 gRPC Proxy。

## 🚀 快速开始

### 1. 启动 RocketMQ
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/rocketmq
chmod +x *.sh
./start-rocketmq.sh
```

脚本会自动：
- 拉取所需镜像
- 启动 NameServer、Broker
- 等待所有服务健康检查通过
- 显示访问信息

### 2. 访问 Dashboard

启动成功后，打开浏览器访问：

```
http://localhost:8080
```

Dashboard 功能包括：
- ✅ Topic 管理（创建、删除、查看）
- ✅ 消息查询和追踪
- ✅ 消费者组监控
- ✅ 消息发送测试
- ✅ Broker 状态监控
- ✅ 集群信息查看

### 3. 连接信息

- **NameServer（旧版 API）**: `localhost:9876`
- **gRPC Proxy（5.x 新 API）**: `localhost:8081`
- **Broker**: `localhost:10911`
- **Dashboard**: `http://localhost:8082`

#### Java 客户端配置示例

**RocketMQ 5.x 新 API**（推荐，支持 gRPC）：
```yaml
rocketmq:
  endpoints: localhost:8081
  ssl-enabled: false
```

**RocketMQ 4.x 旧 API**（兼容）：
```yaml
rocketmq:
  name-server: localhost:9876
```

## 🛠️ 管理命令

### 停止服务（保留数据）
```bash
./stop-rocketmq.sh
```

### 清理环境（删除所有数据）
```bash
./cleanup-rocketmq.sh
```

⚠️ 注意：这会删除容器、卷和所有消息数据！

### 重启服务
```bash
./stop-rocketmq.sh
./start-rocketmq.sh
```

### 查看日志
```bash
# 查看所有日志
docker-compose logs -f

# 查看 NameServer 日志
docker-compose logs -f namesrv

# 查看 Broker 日志
docker-compose logs -f broker
```

## 📝 快速测试

### 使用命令行工具

#### 1. 创建 Topic
```bash
docker exec rocketmq-broker sh mqadmin updateTopic \
  -n namesrv:9876 \
  -t TestTopic \
  -c DefaultCluster
```

#### 2. 发送消息
```bash
docker exec rocketmq-broker sh mqadmin sendMessage \
  -n namesrv:9876 \
  -t TestTopic \
  -p "Hello RocketMQ from command line"
```

#### 3. 查看 Topic 列表
```bash
docker exec rocketmq-broker sh mqadmin topicList -n namesrv:9876
```

#### 4. 查看集群信息
```bash
docker exec rocketmq-broker sh mqadmin clusterList -n namesrv:9876
```


## 💻 客户端集成

### Java 客户端示例

#### Maven 依赖
```xml
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-client</artifactId>
    <version>5.1.4</version>
</dependency>
```

#### 生产者示例
```java
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;

public class Producer {
    public static void main(String[] args) throws Exception {
        // 创建生产者
        DefaultMQProducer producer = new DefaultMQProducer("ProducerGroup");
        producer.setNamesrvAddr("localhost:9876");
        producer.start();

        // 发送消息
        Message msg = new Message(
            "TestTopic",           // Topic
            "TagA",                // Tag
            "Hello RocketMQ".getBytes()  // Body
        );
        
        SendResult sendResult = producer.send(msg);
        System.out.printf("SendResult: %s%n", sendResult);

        // 关闭生产者
        producer.shutdown();
    }
}
```

#### 消费者示例
```java
import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import org.apache.rocketmq.common.message.MessageExt;
import java.util.List;

public class Consumer {
    public static void main(String[] args) throws Exception {
        // 创建消费者
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("ConsumerGroup");
        consumer.setNamesrvAddr("localhost:9876");
        
        // 订阅 Topic
        consumer.subscribe("TestTopic", "*");
        
        // 注册消息监听器
        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(
                    List<MessageExt> msgs,
                    ConsumeConcurrentlyContext context) {
                for (MessageExt msg : msgs) {
                    System.out.printf("Received: %s%n", new String(msg.getBody()));
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });
        
        // 启动消费者
        consumer.start();
        System.out.println("Consumer started.");
    }
}
```

### Python 客户端示例

#### 安装依赖
```bash
pip install rocketmq-client-python
```

#### 生产者
```python
from rocketmq.client import Producer, Message

producer = Producer('ProducerGroup')
producer.set_namesrv_addr('localhost:9876')
producer.start()

msg = Message('TestTopic')
msg.set_keys('key1')
msg.set_tags('TagA')
msg.set_body('Hello RocketMQ from Python')

ret = producer.send_sync(msg)
print('Send status: %s, msg_id: %s' % (ret.status, ret.msg_id))

producer.shutdown()
```

#### 消费者
```python
from rocketmq.client import PushConsumer

def callback(msg):
    print('Received message: %s' % msg.body.decode('utf-8'))
    return True

consumer = PushConsumer('ConsumerGroup')
consumer.set_namesrv_addr('localhost:9876')
consumer.subscribe('TestTopic', callback)
consumer.start()

print('Consumer started')
# 保持运行
input('Press any key to exit\n')
consumer.shutdown()
```

### Go 客户端示例

#### 安装依赖
```bash
go get github.com/apache/rocketmq-client-go/v2
```

#### 生产者
```go
package main

import (
    "context"
    "fmt"
    "github.com/apache/rocketmq-client-go/v2"
    "github.com/apache/rocketmq-client-go/v2/primitive"
    "github.com/apache/rocketmq-client-go/v2/producer"
)

func main() {
    p, _ := rocketmq.NewProducer(
        producer.WithNsResolver(primitive.NewPassthroughResolver([]string{"localhost:9876"})),
        producer.WithRetry(2),
    )
    
    err := p.Start()
    if err != nil {
        panic(err)
    }
    
    msg := &primitive.Message{
        Topic: "TestTopic",
        Body:  []byte("Hello RocketMQ from Go"),
    }
    
    res, err := p.SendSync(context.Background(), msg)
    if err != nil {
        panic(err)
    }
    
    fmt.Printf("Send result: %s\n", res.String())
    p.Shutdown()
}
```

## 🔧 配置说明

### Broker 配置

编辑 `broker.conf` 文件：

```conf
# 自动创建 Topic（生产环境建议关闭）
autoCreateTopicEnable = true

# Broker 角色
# ASYNC_MASTER - 异步主节点
# SYNC_MASTER - 同步主节点
# SLAVE - 从节点
brokerRole = ASYNC_MASTER

# 刷盘方式
# ASYNC_FLUSH - 异步刷盘（性能好）
# SYNC_FLUSH - 同步刷盘（可靠性高）
flushDiskType = ASYNC_FLUSH

# 消息保留时间（小时）
fileReservedTime = 48
```

### 内存配置

在 `docker-compose.yaml` 中调整 JVM 内存：

```yaml
environment:
  # NameServer 内存
  JAVA_OPT_EXT: "-Xms512m -Xmx512m"
  
  # Broker 内存（可根据需要增大）
  JAVA_OPT_EXT: "-Xms1g -Xmx1g"
```

## 🔍 故障排查

### 问题：Broker 无法连接 NameServer

1. 查看 NameServer 日志
```bash
docker-compose logs namesrv
```

2. 检查 NameServer 是否正常
```bash
docker exec rocketmq-namesrv sh mqadmin clusterList -n localhost:9876
```

3. 检查网络连接
```bash
docker exec rocketmq-broker ping namesrv
```

### 问题：消息发送失败

1. 检查 Topic 是否存在
```bash
docker exec rocketmq-broker sh mqadmin topicList -n namesrv:9876
```

2. 检查 Broker 状态
```bash
docker exec rocketmq-broker sh mqadmin clusterList -n namesrv:9876
```

3. 查看 Broker 日志
```bash
docker-compose logs broker | tail -100
```

### 问题：消费者无法消费消息

1. 检查消费者组是否存在
```bash
docker exec rocketmq-broker sh mqadmin consumerProgress -n namesrv:9876
```

2. 使用命令行查看消费者状态
```bash
docker exec rocketmq-broker sh mqadmin consumerProgress -n namesrv:9876
```

## 📁 数据持久化

数据会保存在 Docker 卷中：
- `namesrv-logs`: NameServer 日志
- `broker-logs`: Broker 日志
- `broker-store`: 消息存储（包括 CommitLog、ConsumeQueue 等）

查看卷：
```bash
docker volume ls | grep rocketmq
```

备份消息数据：
```bash
docker run --rm -v rocketmq_broker-store:/data -v $(pwd):/backup alpine tar czf /backup/rocketmq-backup.tar.gz /data
```

## 📚 更多资源

- [RocketMQ 官方文档](https://rocketmq.apache.org/docs/)
- [RocketMQ 最佳实践](https://rocketmq.apache.org/docs/bestPractice/01bestpractice)
- [RocketMQ 架构设计](https://rocketmq.apache.org/docs/domainModel/01concept)
- [RocketMQ 客户端 SDK](https://rocketmq.apache.org/docs/sdkdownload/01download)

## 💡 提示

- 使用社区维护的镜像，原生支持 ARM64 (Apple Silicon)
- 默认配置允许自动创建 Topic，方便开发测试
- 消息默认保留 48 小时
- 可通过命令行或客户端 SDK 完整使用 RocketMQ
- 生产环境建议配置主从集群并使用同步刷盘
- 首次启动需要下载镜像，请耐心等待
