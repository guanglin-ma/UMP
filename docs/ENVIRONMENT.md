# 环境配置文档

本文档说明如何配置UMP平台的各种环境（开发、测试、生产）。

## 环境变量说明

### 快速开始

1. 复制环境变量模板：
   ```bash
   cp .env.example .env
   ```

2. 根据你的环境编辑 `.env` 文件

3. 启动服务：
   ```bash
   # 启动基础设施（PostgreSQL, Redis, ClickHouse, Kafka）
   docker-compose -f infra/storage/docker-compose.yml up -d
   docker-compose -f infra/kafka/docker-compose.yml up -d
   
   # 启动后端API
   cd backend/api
   source venv/bin/activate
   uvicorn main:app --host 0.0.0.0 --port 8000
   
   # 启动网关
   cd backend/gateway
   source venv/bin/activate
   uvicorn http_poc:app --host 0.0.0.0 --port 8090
   ```

## 环境分类

### 开发环境 (Development)

**特点**：
- 启用开发模式（`DEV_MODE=true`）
- 详细的日志输出（`LOG_LEVEL=DEBUG`）
- 允许所有CORS来源
- 使用本地数据库和缓存

**配置示例**：
```bash
# .env.development
DEV_MODE=true
LOG_LEVEL=DEBUG
CORS_ORIGINS=*
POSTGRES_HOST=localhost
REDIS_HOST=localhost
CLICKHOUSE_URL=http://localhost:8123
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
```

### 测试环境 (Staging)

**特点**：
- 禁用开发模式（`DEV_MODE=false`）
- 标准日志级别（`LOG_LEVEL=INFO`）
- 限制CORS来源
- 使用测试数据库

**配置示例**：
```bash
# .env.staging
DEV_MODE=false
LOG_LEVEL=INFO
CORS_ORIGINS=https://staging.ump.example.com
POSTGRES_HOST=staging-db.example.com
REDIS_HOST=staging-redis.example.com
CLICKHOUSE_URL=http://staging-ch.example.com:8123
KAFKA_BOOTSTRAP_SERVERS=staging-kafka.example.com:9092
```

### 生产环境 (Production)

**特点**：
- 禁用开发模式（`DEV_MODE=false`）
- 警告级别日志（`LOG_LEVEL=WARNING`）
- 严格限制CORS来源
- 使用生产数据库和缓存
- 启用所有安全特性

**配置示例**：
```bash
# .env.production
DEV_MODE=false
LOG_LEVEL=WARNING
CORS_ORIGINS=https://ump.example.com
POSTGRES_HOST=prod-db.example.com
REDIS_HOST=prod-redis.example.com
CLICKHOUSE_URL=http://prod-ch.example.com:8123
KAFKA_BOOTSTRAP_SERVERS=prod-kafka.example.com:9092
GATEWAY_API_KEY=<strong-secret-key>
GATEWAY_SIGNING_SECRET=<strong-signing-secret>
KEYCLOAK_CLIENT_SECRET=<strong-client-secret>
```

## 核心配置项

### 数据库配置

#### PostgreSQL
```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=ump
POSTGRES_PASSWORD=your-password
POSTGRES_DB=ump
```

#### Redis
```bash
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your-password
REDIS_DB=0
```

#### ClickHouse
```bash
CLICKHOUSE_URL=http://localhost:8123
CLICKHOUSE_USER=default
CLICKHOUSE_PASSWORD=your-password
CLICKHOUSE_DB=ump
```

### 网关配置

```bash
GATEWAY_HOST=0.0.0.0
GATEWAY_PORT=8090
GATEWAY_API_KEY=your-api-key
GATEWAY_SIGNING_SECRET=your-signing-secret
GATEWAY_PUBLISH_ENABLED=true
GATEWAY_PUBLISH_BACKEND=kafka
```

### Kafka配置

```bash
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
KAFKA_MAX_RETRIES=3
KAFKA_RETRY_BACKOFF_MS=100
KAFKA_MAX_QUEUE_SIZE=10000
```

### 认证配置

#### Keycloak OIDC
```bash
KEYCLOAK_URL=http://localhost:8080
KEYCLOAK_REALM=ump
KEYCLOAK_CLIENT_ID=ump-api
KEYCLOAK_CLIENT_SECRET=your-client-secret
```

#### 开发模式
```bash
DEV_MODE=true  # 开发环境启用，生产环境必须禁用
```

## 环境变量加载

### Python应用

使用 `python-dotenv` 加载环境变量：

```python
from dotenv import load_dotenv
import os

load_dotenv()  # 加载 .env 文件

postgres_host = os.getenv("POSTGRES_HOST", "localhost")
```

### Shell脚本

```bash
# 加载环境变量
set -a
source .env
set +a

# 或使用 export
export $(cat .env | xargs)
```

### Docker Compose

```yaml
services:
  api:
    env_file:
      - .env
    environment:
      - POSTGRES_HOST=${POSTGRES_HOST}
```

## 安全最佳实践

1. **永远不要提交 `.env` 文件到版本控制**
   - 确保 `.env` 在 `.gitignore` 中
   - 使用 `.env.example` 作为模板

2. **使用强密码和密钥**
   - 生产环境使用随机生成的强密码
   - 定期轮换密钥和密码

3. **限制访问**
   - 使用防火墙限制数据库访问
   - 使用VPN或私有网络

4. **加密敏感数据**
   - 使用密钥管理服务（如AWS KMS, HashiCorp Vault）
   - 加密存储敏感配置

5. **环境隔离**
   - 不同环境使用不同的数据库和缓存
   - 使用不同的密钥和证书

## 故障排查

### 常见问题

1. **数据库连接失败**
   - 检查 `POSTGRES_HOST` 和 `POSTGRES_PORT`
   - 验证数据库用户权限
   - 检查防火墙规则

2. **Redis连接失败**
   - 检查 `REDIS_HOST` 和 `REDIS_PORT`
   - 验证Redis密码（如果设置）
   - 检查Redis是否运行

3. **ClickHouse连接失败**
   - 检查 `CLICKHOUSE_URL`
   - 验证用户权限
   - 检查网络连接

4. **Kafka连接失败**
   - 检查 `KAFKA_BOOTSTRAP_SERVERS`
   - 验证Kafka是否运行
   - 检查网络连接

### 调试技巧

1. **启用详细日志**：
   ```bash
   LOG_LEVEL=DEBUG
   ```

2. **检查环境变量**：
   ```bash
   # Python
   import os
   print(os.getenv("POSTGRES_HOST"))
   
   # Shell
   echo $POSTGRES_HOST
   ```

3. **测试连接**：
   ```bash
   # PostgreSQL
   psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB
   
   # Redis
   redis-cli -h $REDIS_HOST -p $REDIS_PORT
   
   # ClickHouse
   curl $CLICKHOUSE_URL/ping
   ```

## 参考

- [环境变量模板](../.env.example)
- [部署文档](./DEPLOYMENT.md)
- [CI/CD配置](../.github/workflows/ci.yml)

