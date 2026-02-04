# Elasticsearch Docker 环境

使用 Docker Compose 快速启动 Elasticsearch（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

- **镜像**: `elasticsearch:8.12.2`
- **模式**: 单节点（`discovery.type=single-node`）
- **安全**: 本地开发关闭安全认证（`xpack.security.enabled=false`）

## 🚀 快速开始

### 1. 启动 Elasticsearch
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/elasticsearch
chmod +x *.sh
./start.sh
```

脚本会自动：
- 拉取 Elasticsearch 镜像
- 启动容器
- 等待健康检查通过
- 显示访问地址

### 2. 访问与连接

- **REST API**: `http://localhost:9200`
- **Transport**: `localhost:9300`

## 🛠️ 管理命令

### 停止服务（保留数据）
```bash
./stop.sh
```

### 清理环境（删除所有数据）
```bash
./cleanup.sh
```

⚠️ 注意：这会删除容器、卷和所有数据！

### 重启服务
```bash
./stop.sh
./start.sh
```

### 查看日志
```bash
docker-compose logs -f elasticsearch
```

### 查看容器状态
```bash
docker-compose ps
```

## 💻 快速测试

### 1. 查看集群信息
```bash
curl http://localhost:9200
```

### 2. 创建索引并写入文档
```bash
curl -X PUT "http://localhost:9200/test-index"
curl -X POST "http://localhost:9200/test-index/_doc" -H 'Content-Type: application/json' -d '{
  "title": "Hello Elasticsearch",
  "tags": ["local", "docker"],
  "created_at": "2026-02-04T10:00:00+08:00"
}'
```

### 3. 搜索
```bash
curl "http://localhost:9200/test-index/_search?q=title:Hello"
```

## 📁 文件结构

```
elasticsearch/
├── docker-compose.yaml   # Docker Compose 配置
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── cleanup.sh            # 清理脚本
└── README.md             # 使用文档
```

## 🔧 常用配置

如需调整 JVM 内存、端口或安全设置，可修改 `docker-compose.yaml`：

```yaml
environment:
  - ES_JAVA_OPTS=-Xms512m -Xmx512m
  - xpack.security.enabled=false
ports:
  - "9200:9200"
  - "9300:9300"
```

## 🔍 故障排查

### 问题：容器无法启动

1. 查看日志
```bash
docker-compose logs elasticsearch
```

2. 检查端口占用
```bash
lsof -i :9200
lsof -i :9300
```

3. 清理并重新启动
```bash
./cleanup.sh
./start.sh
```

### 问题：访问 9200 失败

1. 确认容器状态
```bash
docker-compose ps
```

2. 重新启动服务
```bash
./stop.sh
./start.sh
```

## 📚 更多资源

- [Elasticsearch 官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 💡 提示

- 本地开发已关闭安全认证，生产环境请启用安全配置
- 数据持久化在 Docker 卷 `es-data` 中
- 首次启动需要下载镜像，请耐心等待
