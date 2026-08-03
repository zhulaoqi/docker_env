# Nacos Local Docker 环境

使用 Docker Compose 快速启动 Nacos 3.x 单机模式（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

- **基础镜像**: `nacos/nacos-server:v3.1.1`
- **自定义镜像**: `nacos-local:3.1.1`（设置时区 Asia/Shanghai）
- **架构支持**: ARM64 (Apple Silicon) + AMD64
- **模式**: Standalone（单机）

## 🚀 快速开始

### 1. 一键启动
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/nacos-local
chmod +x *.sh
./start.sh
```

脚本会自动：
- 检测镜像，不存在则自动构建
- 启动 Nacos 容器
- 等待健康检查通过
- 显示控制台地址

### 2. 单独构建镜像
```bash
./build.sh
```

### 3. 访问控制台

- **地址**: http://localhost:8848/
- **用户名**: `nacos`
- **密码**: `nacos`

## 🛠️ 管理命令

| 命令 | 说明 |
|------|------|
| `./build.sh` | 构建自定义镜像 |
| `./start.sh` | 启动服务（自动构建 + 健康检查） |
| `./stop.sh` | 停止服务（保留数据） |
| `./cleanup.sh` | 清理容器和数据卷（带确认） |

### 查看日志
```bash
docker-compose logs -f nacos
```

### 查看容器状态
```bash
docker-compose ps
```

## 🔧 端口说明

| 端口 | 说明 |
|------|------|
| 8848 | HTTP API + Nacos 控制台 |
| 9848 | gRPC 客户端通信端口 |
| 9849 | gRPC 集群间通信端口 |

## 💻 接入示例

### Spring Boot（Spring Cloud Alibaba）
```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848
        username: nacos
        password: nacos
      config:
        server-addr: localhost:8848
        username: nacos
        password: nacos
        file-extension: yaml
```

### Nacos Open API
```bash
# 注册服务实例
curl -X POST "http://localhost:8848/nacos/v2/ns/instance" \
  -d "serviceName=test-service&ip=127.0.0.1&port=8080"

# 查询服务实例
curl "http://localhost:8848/nacos/v2/ns/instance/list?serviceName=test-service"

# 发布配置
curl -X POST "http://localhost:8848/nacos/v2/cs/config" \
  -d "dataId=test&group=DEFAULT_GROUP&content=hello=world"

# 获取配置
curl "http://localhost:8848/nacos/v2/cs/config?dataId=test&group=DEFAULT_GROUP"
```

### Go 连接示例
```go
import "github.com/nacos-group/nacos-sdk-go/v2/clients"

clientConfig := constant.ClientConfig{
    NamespaceId: "",
    Username:    "nacos",
    Password:    "nacos",
}
serverConfigs := []constant.ServerConfig{{
    IpAddr: "localhost",
    Port:   8848,
}}
```

## 📁 文件结构

```
nacos-local/
├── Dockerfile            # 自定义镜像（设置时区）
├── docker-compose.yaml   # Docker Compose 配置
├── build.sh              # 镜像构建脚本
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── cleanup.sh            # 清理脚本
└── README.md             # 使用文档
```

## 📊 数据持久化

数据保存在 Docker 命名卷中：
- `nacos-data`: 配置数据（Derby 嵌入式数据库）
- `nacos-logs`: 运行日志

查看卷：
```bash
docker volume ls | grep nacos
```

## ⚙️ JVM 配置

默认 JVM 参数（适合本地开发）：
- `-Xms512m -Xmx512m -Xmn256m`

如需调整，修改 `docker-compose.yaml` 中的环境变量：
```yaml
environment:
  JVM_XMS: 1g
  JVM_XMX: 1g
  JVM_XMN: 512m
```

## 🔍 故障排查

### 问题：启动超时

1. 查看日志
```bash
docker-compose logs nacos
```

2. 检查端口占用
```bash
lsof -i :8848
lsof -i :9848
```

3. 清理并重新启动
```bash
./cleanup.sh
./start.sh
```

### 问题：内存不足

Nacos 3.x 默认需要较多内存，如果 Docker 分配内存不足可能启动失败。确保 Docker Desktop 至少分配 4GB 内存。

### 问题：与旧版 nacos 目录冲突

本目录与项目中的 `nacos/` 目录使用相同端口（8848/9848/9849），请确保不要同时运行。

## 📚 更多资源

- [Nacos 官方文档](https://nacos.io/docs/latest/overview/)
- [Nacos Docker Hub](https://hub.docker.com/r/nacos/nacos-server)
- [Spring Cloud Alibaba](https://sca.aliyun.com/)

## 💡 提示

- Nacos 官方镜像原生支持 ARM64
- Standalone 模式使用内嵌 Derby 数据库，适合开发测试
- 生产环境建议使用 MySQL 外置数据库 + 集群模式
- 首次启动需要下载镜像约 400MB，请耐心等待
- 注意不要和 `nacos/` 目录下的服务同时运行
