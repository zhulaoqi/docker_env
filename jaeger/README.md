# Jaeger Docker 环境

使用 Docker Compose 快速启动 Jaeger 分布式追踪系统（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

- **镜像**: `jaegertracing/all-in-one:1.53`
- **架构支持**: ARM64 (Apple Silicon) + AMD64
- **模式**: All-in-one（包含所有组件）

## 🚀 快速开始

### 1. 启动 Jaeger
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/jaeger
chmod +x *.sh
./start-jaeger.sh
```

脚本会自动：
- 拉取 Jaeger all-in-one 镜像
- 启动容器
- 等待健康检查通过
- 显示访问地址

### 2. 访问 UI

启动成功后，打开浏览器访问：

```
http://localhost:16686
```

## 📡 端口说明

| 端口 | 协议 | 说明 |
|------|------|------|
| 16686 | HTTP | Jaeger UI（Web 界面） |
| 14268 | HTTP | Jaeger Collector HTTP 端点 |
| 14250 | gRPC | Jaeger Collector gRPC 端点 |
| 9411 | HTTP | Zipkin 兼容端点 |
| 6831 | UDP | Jaeger Agent Thrift compact |
| 6832 | UDP | Jaeger Agent Thrift binary |
| 5778 | HTTP | Agent HTTP 配置端点 |
| 5775 | UDP | Zipkin Thrift compact（已废弃） |

## 🛠️ 管理命令

### 停止 Jaeger（保留数据）
```bash
./stop-jaeger.sh
```

### 清理环境（删除所有数据）
```bash
./cleanup-jaeger.sh
```

⚠️ 注意：这会删除容器和卷！

### 重启 Jaeger
```bash
./stop-jaeger.sh
./start-jaeger.sh
```

### 查看日志
```bash
docker-compose logs -f jaeger
```

### 查看容器状态
```bash
docker-compose ps
```

## 📊 使用示例

### 1. 发送测试 Trace（使用 curl）

```bash
# 使用 Zipkin 兼容端点发送一个简单的 trace
curl -X POST http://localhost:9411/api/v2/spans -H 'Content-Type: application/json' -d '[{
  "traceId": "0000000000000001",
  "id": "0000000000000001",
  "name": "test-span",
  "timestamp": 1234567890000000,
  "duration": 100000,
  "localEndpoint": {
    "serviceName": "test-service"
  }
}]'
```

### 2. 使用 OpenTelemetry SDK（Python 示例）

```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# 创建 Jaeger exporter
jaeger_exporter = JaegerExporter(
    agent_host_name="localhost",
    agent_port=6831,
)

# 配置 tracer
trace.set_tracer_provider(
    TracerProvider(
        resource=Resource.create({SERVICE_NAME: "my-service"})
    )
)
tracer = trace.get_tracer(__name__)

# 添加 span processor
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

# 创建 span
with tracer.start_as_current_span("my-operation"):
    print("Doing some work...")
    # 你的业务逻辑
```

### 3. 使用 Jaeger Client（Java 示例）

```java
import io.jaegertracing.Configuration;
import io.jaegertracing.internal.JaegerTracer;
import io.opentracing.Span;
import io.opentracing.Tracer;

public class JaegerExample {
    public static void main(String[] args) {
        // 创建 tracer
        Tracer tracer = Configuration.fromEnv("my-service")
            .withSampler(Configuration.SamplerConfiguration.fromEnv()
                .withType("const")
                .withParam(1))
            .withReporter(Configuration.ReporterConfiguration.fromEnv()
                .withLogSpans(true)
                .withSender(Configuration.SenderConfiguration.fromEnv()
                    .withAgentHost("localhost")
                    .withAgentPort(6831)))
            .getTracer();

        // 创建 span
        Span span = tracer.buildSpan("my-operation").start();
        try {
            // 你的业务逻辑
            System.out.println("Doing some work...");
        } finally {
            span.finish();
        }
    }
}
```

## 🔍 UI 功能介绍

Jaeger UI 提供以下功能：

1. **Search（搜索）**
   - 按服务名搜索 traces
   - 按操作名搜索
   - 按标签过滤
   - 按时间范围过滤

2. **Trace Detail（Trace 详情）**
   - 查看完整的 trace 时间线
   - 查看每个 span 的详细信息
   - 查看 span 的标签和日志
   - 分析性能瓶颈

3. **Compare（对比）**
   - 对比不同 traces
   - 找出性能差异

4. **System Architecture（系统架构）**
   - 查看服务依赖关系图
   - 了解系统拓扑

## 🔧 配置说明

### 环境变量

可以在 `docker-compose.yaml` 中修改环境变量：

```yaml
environment:
  - COLLECTOR_ZIPKIN_HOST_PORT=:9411     # Zipkin 兼容端点
  - COLLECTOR_OTLP_ENABLED=true          # 启用 OpenTelemetry 协议
  - SPAN_STORAGE_TYPE=memory             # 存储类型（memory/badger/cassandra/elasticsearch）
  - MEMORY_MAX_TRACES=10000              # 内存中最多保存的 traces 数量
```

### 持久化存储

默认使用内存存储，重启后数据会丢失。如需持久化，可以配置使用 Badger：

```yaml
environment:
  - SPAN_STORAGE_TYPE=badger
  - BADGER_EPHEMERAL=false
  - BADGER_DIRECTORY_VALUE=/badger/data
  - BADGER_DIRECTORY_KEY=/badger/key
volumes:
  - ./badger-data:/badger
```

或使用 Elasticsearch（生产环境推荐）：

```yaml
environment:
  - SPAN_STORAGE_TYPE=elasticsearch
  - ES_SERVER_URLS=http://elasticsearch:9200
```

## 🔍 故障排查

### 问题：容器无法启动

1. 查看日志
```bash
docker-compose logs jaeger
```

2. 检查端口占用
```bash
# macOS
lsof -i :16686
lsof -i :14268
```

3. 清理并重新启动
```bash
./cleanup-jaeger.sh
./start-jaeger.sh
```

### 问题：无法收到 traces

1. 检查 agent 端口是否正常监听
```bash
netstat -an | grep 6831
```

2. 测试 collector 端点
```bash
curl http://localhost:14268/api/traces
```

3. 检查客户端配置
   - 确认 agent 地址正确（localhost:6831）
   - 确认采样率不为 0
   - 检查客户端日志

## 📚 更多资源

- [Jaeger 官方文档](https://www.jaegertracing.io/docs/)
- [Jaeger Architecture](https://www.jaegertracing.io/docs/latest/architecture/)
- [OpenTelemetry 文档](https://opentelemetry.io/docs/)
- [Jaeger Client Libraries](https://www.jaegertracing.io/docs/latest/client-libraries/)

## 💡 提示

- All-in-one 镜像仅适用于开发测试环境
- 生产环境建议分离部署各组件并使用持久化存储
- 默认使用内存存储，重启后数据会丢失
- 支持 Zipkin、Jaeger 和 OpenTelemetry 协议
- 首次启动需要下载镜像，请耐心等待
