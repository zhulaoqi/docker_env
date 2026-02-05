# Nacos Docker 环境

使用 Docker Compose 快速启动 Nacos（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

- **镜像**: `nacos/nacos-server:v3.1.1`（支持 MCP Registry）
- **架构支持**: ARM64 (Apple Silicon) + AMD64
- **模式**: Standalone（单机模式）

## 🚀 快速开始

### 1. 启动 Nacos
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/nacos
chmod +x *.sh
./start-nacos.sh
```

脚本会自动：
- 拉取 Nacos slim 镜像
- 启动容器
- 等待健康检查通过
- 显示访问地址

### 2. 访问控制台

启动成功后，打开浏览器访问：

```
http://localhost:8848/nacos
```

**默认账号**:
- 用户名: `nacos`
- 密码: `nacos`

### 3. 端口说明

| 端口 | 说明 |
|------|------|
| 8848 | Nacos 控制台和 HTTP API |
| 9848 | 客户端 gRPC 请求端口 |
| 9849 | 服务端 gRPC 请求端口 |

## 🛠️ 管理命令

### 停止 Nacos（保留数据）
```bash
./stop-nacos.sh
```

### 清理环境（删除所有数据）
```bash
./cleanup-nacos.sh
```

⚠️ 注意：这会删除容器、卷和本地数据！

### 重启 Nacos
```bash
./stop-nacos.sh
./start-nacos.sh
```

### 查看日志
```bash
docker-compose logs -f nacos
```

### 查看容器状态
```bash
docker-compose ps
```

## 📁 数据持久化

数据会保存在本地目录：
- `./data/` - Nacos 数据文件
- `./logs/` - Nacos 日志文件

这些目录会自动创建并挂载到容器中。

## 🔍 故障排查

### 问题：容器无法启动

1. 查看日志
```bash
docker-compose logs nacos
```

2. 检查端口占用
```bash
# macOS
lsof -i :8848

# 停止占用端口的进程或修改 docker-compose.yaml 中的端口映射
```

3. 清理并重新启动
```bash
./cleanup-nacos.sh
./start-nacos.sh
```

### 问题：健康检查失败

如果启动脚本一直显示 "waiting..."，可能是：
- 内存不足（Nacos 需要至少 512MB）
- 端口被占用
- 镜像下载不完整

解决方法：
```bash
# 1. 停止容器
docker-compose down

# 2. 删除并重新拉取镜像
docker image rm nacos/nacos-server:v3.1.1
docker pull nacos/nacos-server:v3.1.1

# 3. 重新启动
./start-nacos.sh
```

## 📝 使用示例

### 服务注册
```bash
curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=example&ip=127.0.0.1&port=8080'
```

### 服务发现
```bash
curl -X GET 'http://127.0.0.1:8848/nacos/v1/ns/instance/list?serviceName=example'
```

### 发布配置
```bash
curl -X POST "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=example.properties&group=DEFAULT_GROUP&content=example=value"
```

### 获取配置
```bash
curl -X GET "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=example.properties&group=DEFAULT_GROUP"
```

## 🔧 自定义配置

如需修改配置，编辑 `docker-compose.yaml`：

```yaml
environment:
  MODE: standalone              # cluster/standalone
  PREFER_HOST_MODE: hostname    # hostname/ip
  JVM_XMS: 512m                # 最小堆内存
  JVM_XMX: 512m                # 最大堆内存
  NACOS_AUTH_ENABLE: true      # 开启鉴权
```

修改后重启：
```bash
./stop-nacos.sh
./start-nacos.sh
```

## 📚 更多资源

- [Nacos 官方文档](https://nacos.io/zh-cn/docs/quick-start.html)
- [Nacos Docker 项目](https://github.com/nacos-group/nacos-docker)
- [Nacos 控制台使用指南](https://nacos.io/zh-cn/docs/console-guide.html)

## 💡 提示

- v3.1.1 版本支持 MCP Registry、Agent 注册等 AI 架构特性
- 默认使用内嵌数据库 Derby（适合开发测试）
- 生产环境建议配置 MySQL 数据库
- 首次启动需要下载镜像，请耐心等待
