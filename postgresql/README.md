# PostgreSQL Docker 环境

使用 Docker Compose 快速启动 PostgreSQL 15（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

- **基础镜像**: `postgres:15`
- **自定义镜像**: `postgresql15-local:latest`（基于 Dockerfile 构建，设置时区为 Asia/Shanghai）
- **架构支持**: ARM64 (Apple Silicon) + AMD64
- **模式**: 单节点

## 🚀 快速开始

### 1. 启动 PostgreSQL
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/postgresql
chmod +x *.sh
./start.sh
```

脚本会自动：
- 拉取 PostgreSQL 基础镜像
- 构建自定义镜像（设置时区）
- 启动容器
- 等待健康检查通过
- 显示连接信息

### 2. 连接信息

- **Host**: `localhost`
- **Port**: `5432`
- **Username**: `root`
- **Password**: `root123456`
- **Database**: `testdb`

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
docker-compose logs -f postgresql
```

### 查看容器状态
```bash
docker-compose ps
```

## 💻 快速测试

### psql 命令行
```bash
# 进入 PostgreSQL 容器并连接
docker exec -it postgresql psql -U root -d testdb

# 查看所有表
\dt

# 查看示例数据
SELECT * FROM users;

# 插入数据
INSERT INTO users (username, email) VALUES ('charlie', 'charlie@example.com');

# 退出
\q
```

## 📝 使用示例

### Python 连接示例
```python
import psycopg2

conn = psycopg2.connect(
    host='localhost',
    port=5432,
    user='root',
    password='root123456',
    dbname='testdb'
)

cur = conn.cursor()
cur.execute('SELECT * FROM users')
for row in cur.fetchall():
    print(row)

cur.close()
conn.close()
```

### Java 连接示例（Spring Boot）
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/testdb
    username: root
    password: root123456
    driver-class-name: org.postgresql.Driver
```

### Node.js 连接示例
```javascript
const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5432,
  user: 'root',
  password: 'root123456',
  database: 'testdb',
});

async function run() {
  await client.connect();
  const res = await client.query('SELECT * FROM users');
  console.log(res.rows);
  await client.end();
}

run().catch(console.error);
```

### Go 连接示例
```go
import (
    "database/sql"
    _ "github.com/lib/pq"
)

connStr := "host=localhost port=5432 user=root password=root123456 dbname=testdb sslmode=disable"
db, err := sql.Open("postgres", connStr)
```

## 📁 文件结构

```
postgresql/
├── Dockerfile              # 自定义镜像（设置时区）
├── docker-compose.yaml     # Docker Compose 配置
├── init-sql/
│   └── init.sql            # 数据库初始化脚本
├── start.sh                # 启动脚本
├── stop.sh                 # 停止脚本
├── cleanup.sh              # 清理脚本
└── README.md               # 使用文档
```

## 📊 数据持久化

数据会保存在 Docker 卷中：
- `pg-data`: PostgreSQL 数据文件

查看卷：
```bash
docker volume ls
```

备份数据：
```bash
# 备份整个数据库
docker exec postgresql pg_dump -U root testdb > backup.sql

# 恢复数据库
docker exec -i postgresql psql -U root testdb < backup.sql

# 备份所有数据库
docker exec postgresql pg_dumpall -U root > all_backup.sql
```

## 🔍 故障排查

### 问题：容器无法启动

1. 查看日志
```bash
docker-compose logs postgresql
```

2. 检查端口占用
```bash
lsof -i :5432
```

3. 清理并重新启动
```bash
./cleanup.sh
./start.sh
```

### 问题：认证失败

确认使用正确的用户名和密码：
```bash
# 使用 psql 连接
docker exec -it postgresql psql -U root -d testdb

# 或使用连接字符串
psql "postgresql://root:root123456@localhost:5432/testdb"
```

### 问题：初始化 SQL 未执行

初始化脚本仅在**首次创建数据卷**时执行。如需重新初始化：
```bash
./cleanup.sh   # 删除卷
./start.sh     # 重新创建
```

## 📚 更多资源

- [PostgreSQL 官方文档](https://www.postgresql.org/docs/15/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [PostgreSQL 教程](https://www.postgresqltutorial.com/)

## 💡 提示

- PostgreSQL 官方镜像原生支持 ARM64
- 数据持久化到 Docker 卷，重启不会丢失
- `init-sql/` 目录下的 `.sql` 文件会在首次启动时自动执行
- Dockerfile 已设置时区为 Asia/Shanghai
- 首次启动需要下载镜像并构建，请耐心等待
