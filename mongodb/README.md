# MongoDB Docker 环境

使用 Docker Compose 快速启动 MongoDB（支持 Mac ARM64 和 AMD64）

## 📦 镜像信息

- **镜像**: `mongo:7.0`
- **架构支持**: ARM64 (Apple Silicon) + AMD64
- **模式**: 单节点

## 🚀 快速开始

### 1. 启动 MongoDB
```bash
cd /Users/zhujinqi/Documents/learn/bigdata/docker_env/mongodb
chmod +x *.sh
./start.sh
```

脚本会自动：
- 拉取 MongoDB 镜像
- 启动容器
- 等待健康检查通过
- 显示连接信息

### 2. 连接信息

- **Host**: `localhost`
- **Port**: `27017`
- **Root Username**: `root`
- **Root Password**: `root123456`
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
docker-compose logs -f mongodb
```

### 查看容器状态
```bash
docker-compose ps
```

## 💻 快速测试

### MongoDB Shell
```bash
# 进入 MongoDB 容器并连接
docker exec -it mongodb mongosh -u root -p root123456 --authenticationDatabase admin

# 切换到测试数据库
use testdb

# 插入测试数据
db.users.insertOne({ name: "Alice", age: 25 })

# 查询数据
db.users.find()
```

## 📝 使用示例

### Python 连接示例
```python
from pymongo import MongoClient

# 创建连接
client = MongoClient(
    host='localhost',
    port=27017,
    username='root',
    password='root123456',
    authSource='admin'
)

# 选择数据库
db = client['testdb']

# 插入文档
db.users.insert_one({'name': 'Bob', 'age': 30})

# 查询文档
for user in db.users.find():
    print(user)

client.close()
```

### Java 连接示例（Spring Boot）
```yaml
spring:
  data:
    mongodb:
      uri: mongodb://root:root123456@localhost:27017/testdb?authSource=admin
```

或者：
```yaml
spring:
  data:
    mongodb:
      host: localhost
      port: 27017
      database: testdb
      username: root
      password: root123456
      authentication-database: admin
```

### Node.js 连接示例
```javascript
const { MongoClient } = require('mongodb');

const uri = 'mongodb://root:root123456@localhost:27017/testdb?authSource=admin';
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    const database = client.db('testdb');
    const users = database.collection('users');
    
    // 插入文档
    await users.insertOne({ name: 'Charlie', age: 28 });
    
    // 查询文档
    const result = await users.find().toArray();
    console.log(result);
  } finally {
    await client.close();
  }
}

run().catch(console.dir);
```

## 📁 文件结构

```
mongodb/
├── docker-compose.yaml   # Docker Compose 配置
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── cleanup.sh            # 清理脚本
└── README.md             # 使用文档
```

## 📊 数据持久化

数据会保存在 Docker 卷中：
- `mongo-data`: MongoDB 数据文件
- `mongo-config`: MongoDB 配置文件

查看卷：
```bash
docker volume ls
```

备份数据：
```bash
# 备份数据库
docker exec mongodb mongodump -u root -p root123456 --authenticationDatabase admin --out /dump
docker cp mongodb:/dump ./mongodb-backup

# 恢复数据库
docker cp ./mongodb-backup mongodb:/dump
docker exec mongodb mongorestore -u root -p root123456 --authenticationDatabase admin /dump
```

## 🔍 故障排查

### 问题：容器无法启动

1. 查看日志
```bash
docker-compose logs mongodb
```

2. 检查端口占用
```bash
lsof -i :27017
```

3. 清理并重新启动
```bash
./cleanup.sh
./start.sh
```

### 问题：认证失败

确认使用正确的认证数据库：
```bash
# 正确方式（指定 authenticationDatabase=admin）
mongosh -u root -p root123456 --authenticationDatabase admin

# 或使用连接字符串
mongosh "mongodb://root:root123456@localhost:27017/?authSource=admin"
```

## 📚 更多资源

- [MongoDB 官方文档](https://www.mongodb.com/docs/)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [MongoDB 驱动文档](https://www.mongodb.com/docs/drivers/)

## 💡 提示

- MongoDB 官方镜像原生支持 ARM64
- 数据持久化到 Docker 卷，重启不会丢失
- 默认启用认证，生产环境建议修改默认密码
- 首次启动需要下载镜像，请耐心等待
