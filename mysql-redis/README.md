# MySQL + Redis Docker 环境

使用 Docker Compose 快速启动 MySQL 和 Redis（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

| 服务 | 镜像 | 版本 | 架构支持 |
|------|------|------|----------|
| MySQL | mysql | 8.0 | ARM64 + AMD64 |
| Redis | redis | 7.2-alpine | ARM64 + AMD64 |

## 🚀 快速开始

### 1. 启动环境
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/mysql-redis
chmod +x *.sh
./start.sh
```

脚本会自动：
- 拉取 MySQL 和 Redis 镜像
- 启动容器
- 等待健康检查通过
- 显示连接信息

### 2. 连接信息

#### MySQL
- **Host**: `localhost`
- **Port**: `3306`
- **Root Password**: `root123456`
- **Database**: `testdb`
- **用户**: `testuser` / `testpass`

#### Redis
- **Host**: `localhost`
- **Port**: `6379`
- **Password**: 无（可在 `redis.conf` 中设置）

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
# 查看所有日志
docker-compose logs -f

# 查看 MySQL 日志
docker-compose logs -f mysql

# 查看 Redis 日志
docker-compose logs -f redis
```

### 查看容器状态
```bash
docker-compose ps
```

## 💻 快速测试

### MySQL 命令行
```bash
# 进入 MySQL 容器
docker exec -it mysql bash

# 或直接连接 MySQL
docker exec -it mysql mysql -uroot -proot123456

# 切换到测试数据库
USE testdb;

# 查看表
SHOW TABLES;

# 查看示例数据
SELECT * FROM users;
```

### Redis 命令行
```bash
# 进入 Redis 容器
docker exec -it redis sh

# 或直接使用 Redis CLI
docker exec -it redis redis-cli

# 测试命令
PING
SET mykey "Hello"
GET mykey
```

## 📝 使用示例

### MySQL 示例

#### 1. 使用 MySQL 客户端连接
```bash
mysql -h 127.0.0.1 -P 3306 -utestuser -ptestpass testdb
```

#### 2. Python 连接示例
```python
import pymysql

connection = pymysql.connect(
    host='localhost',
    port=3306,
    user='testuser',
    password='testpass',
    database='testdb',
    charset='utf8mb4'
)

try:
    with connection.cursor() as cursor:
        # 查询示例
        cursor.execute("SELECT * FROM users")
        result = cursor.fetchall()
        for row in result:
            print(row)
finally:
    connection.close()
```

#### 3. Java 连接示例（Spring Boot）
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/testdb?useSSL=false&serverTimezone=Asia/Shanghai
    username: testuser
    password: testpass
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### Redis 示例

#### 1. Python 连接示例
```python
import redis

# 创建连接
r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# 基本操作
r.set('name', 'Alice')
print(r.get('name'))  # 输出: Alice

# Hash 操作
r.hset('user:1', mapping={'name': 'Bob', 'age': '25'})
print(r.hgetall('user:1'))

# List 操作
r.lpush('tasks', 'task1', 'task2', 'task3')
print(r.lrange('tasks', 0, -1))
```

#### 2. Java 连接示例（Jedis）
```java
import redis.clients.jedis.Jedis;

public class RedisExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        
        // 基本操作
        jedis.set("name", "Alice");
        System.out.println(jedis.get("name"));
        
        // Hash 操作
        jedis.hset("user:1", "name", "Bob");
        jedis.hset("user:1", "age", "25");
        System.out.println(jedis.hgetAll("user:1"));
        
        jedis.close();
    }
}
```

#### 3. Node.js 连接示例
```javascript
const redis = require('redis');
const client = redis.createClient({
  host: 'localhost',
  port: 6379
});

client.on('error', (err) => console.log('Redis Client Error', err));

await client.connect();

// 基本操作
await client.set('name', 'Alice');
const value = await client.get('name');
console.log(value); // 输出: Alice

await client.disconnect();
```

## 📁 文件结构

```
mysql-redis/
├── docker-compose.yaml       # Docker Compose 配置
├── redis.conf                # Redis 配置文件
├── mysql-init/               # MySQL 初始化脚本目录
│   └── init.sql              # 数据库初始化 SQL
├── start.sh                  # 启动脚本
├── stop.sh                   # 停止脚本
├── cleanup.sh                # 清理脚本
└── README.md                 # 使用文档
```

## 🔧 自定义配置

### MySQL 配置

编辑 `docker-compose.yaml` 中的 MySQL 环境变量：

```yaml
environment:
  MYSQL_ROOT_PASSWORD: root123456    # Root 密码
  MYSQL_DATABASE: testdb             # 默认数据库
  MYSQL_USER: testuser               # 普通用户
  MYSQL_PASSWORD: testpass           # 普通用户密码
  TZ: Asia/Shanghai                  # 时区
```

### Redis 配置

编辑 `redis.conf` 文件：

```conf
# 设置密码（取消注释并修改）
requirepass your_password_here

# 调整最大内存
maxmemory 512mb

# 更改持久化策略
appendfsync always  # 每次写入都同步（安全但慢）
appendfsync everysec  # 每秒同步（默认，平衡）
appendfsync no  # 不同步（快但可能丢数据）
```

### 添加初始化 SQL

在 `mysql-init/` 目录下添加 `.sql` 文件，首次启动时会自动执行：

```sql
-- 创建自定义表
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL
);
```

## 📊 数据持久化

数据会保存在 Docker 卷中：
- `mysql-data`: MySQL 数据
- `redis-data`: Redis 数据

查看卷：
```bash
docker volume ls
```

备份数据：
```bash
# 备份 MySQL
docker exec mysql mysqldump -uroot -proot123456 testdb > backup.sql

# 备份 Redis
docker exec redis redis-cli SAVE
docker cp redis:/data/dump.rdb ./redis-backup.rdb
```

## 🔍 故障排查

### 问题：MySQL 无法启动

1. 查看日志
```bash
docker-compose logs mysql
```

2. 检查端口占用
```bash
lsof -i :3306
```

3. 如果是权限或数据损坏，清理后重新启动
```bash
./cleanup.sh
./start.sh
```

### 问题：Redis 连接被拒绝

1. 检查 Redis 是否运行
```bash
docker exec redis redis-cli ping
```

2. 检查配置文件
```bash
docker exec redis cat /usr/local/etc/redis/redis.conf
```

3. 如果设置了密码，连接时需要认证
```bash
docker exec redis redis-cli -a your_password
```

### 问题：初始化 SQL 没有执行

MySQL 初始化脚本只在**首次启动**时执行。如果需要重新执行：

```bash
# 1. 清理环境
./cleanup.sh

# 2. 修改 init.sql

# 3. 重新启动
./start.sh
```

## 📚 更多资源

- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [Redis 官方文档](https://redis.io/documentation)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 💡 提示

- MySQL 和 Redis 官方镜像都原生支持 ARM64
- 首次启动会执行 `mysql-init/` 中的所有 `.sql` 文件
- Redis 默认无密码，如需设置请编辑 `redis.conf`
- 数据持久化到 Docker 卷，重启不会丢失
- 生产环境建议修改默认密码并启用 SSL
