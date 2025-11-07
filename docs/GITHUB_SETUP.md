# GitHub 配置指南

本文档说明如何配置 GitHub Secrets 和 Container Registry 访问权限，以支持 CI/CD 自动化部署。

## 配置 GitHub Secrets

### 访问 Secrets 设置

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret** 添加新的 Secret

### 必需的 Secrets

#### 生产环境部署 Secrets

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `PROD_DEPLOY_KEY` | 生产环境部署私钥（SSH） | `-----BEGIN RSA PRIVATE KEY-----...` |
| `PROD_HOST` | 生产环境服务器地址 | `prod.example.com` |
| `PROD_USER` | 生产环境SSH用户名 | `deploy` |
| `PROD_DB_PASSWORD` | 生产环境数据库密码 | `strong-password-123` |
| `PROD_REDIS_PASSWORD` | 生产环境Redis密码 | `redis-password-123` |
| `PROD_CLICKHOUSE_PASSWORD` | 生产环境ClickHouse密码 | `ch-password-123` |
| `PROD_GATEWAY_API_KEY` | 生产环境网关API Key | `prod-api-key-123` |
| `PROD_GATEWAY_SIGNING_SECRET` | 生产环境网关签名密钥 | `prod-signing-secret-123` |
| `PROD_KEYCLOAK_CLIENT_SECRET` | 生产环境Keycloak客户端密钥 | `keycloak-secret-123` |

#### 测试环境部署 Secrets

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `STAGING_DEPLOY_KEY` | 测试环境部署私钥（SSH） | `-----BEGIN RSA PRIVATE KEY-----...` |
| `STAGING_HOST` | 测试环境服务器地址 | `staging.example.com` |
| `STAGING_USER` | 测试环境SSH用户名 | `deploy` |
| `STAGING_DB_PASSWORD` | 测试环境数据库密码 | `staging-password-123` |
| `STAGING_REDIS_PASSWORD` | 测试环境Redis密码 | `staging-redis-password-123` |
| `STAGING_CLICKHOUSE_PASSWORD` | 测试环境ClickHouse密码 | `staging-ch-password-123` |
| `STAGING_GATEWAY_API_KEY` | 测试环境网关API Key | `staging-api-key-123` |
| `STAGING_GATEWAY_SIGNING_SECRET` | 测试环境网关签名密钥 | `staging-signing-secret-123` |

#### Docker Registry Secrets

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `DOCKER_USERNAME` | Docker Registry 用户名 | `github-username` |
| `DOCKER_PASSWORD` | Docker Registry 密码/Token | `ghp_xxxxxxxxxxxx` |

#### 可选 Secrets

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `SLACK_WEBHOOK_URL` | Slack 通知 Webhook URL | `https://hooks.slack.com/services/...` |
| `CODECOV_TOKEN` | Codecov Token（用于代码覆盖率） | `codecov-token-123` |

### 生成 SSH 部署密钥

```bash
# 生成SSH密钥对
ssh-keygen -t rsa -b 4096 -C "deploy@ump" -f ~/.ssh/ump_deploy_key

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/ump_deploy_key.pub deploy@prod.example.com

# 将私钥添加到GitHub Secrets
cat ~/.ssh/ump_deploy_key
# 复制输出内容，添加到 GitHub Secrets 的 PROD_DEPLOY_KEY
```

### 生成 GitHub Personal Access Token

1. 进入 GitHub **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. 点击 **Generate new token (classic)**
3. 设置权限：
   - `write:packages` - 推送 Docker 镜像
   - `read:packages` - 拉取 Docker 镜像
   - `repo` - 访问仓库（如果需要）
4. 生成 Token 后，复制并添加到 GitHub Secrets 的 `DOCKER_PASSWORD`

## 配置 GitHub Container Registry

### 启用 Container Registry

GitHub Container Registry (ghcr.io) 默认启用，无需额外配置。

### 访问权限设置

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Packages**
3. 在 **Package access** 中设置：
   - **Public** - 公开访问（推荐用于开源项目）
   - **Private** - 私有访问（需要认证）

### 使用 Container Registry

#### 推送镜像

```bash
# 登录到 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 构建并推送镜像
docker build -t ghcr.io/OWNER/REPO-NAME:latest .
docker push ghcr.io/OWNER/REPO-NAME:latest
```

#### 拉取镜像

```bash
# 登录（如果需要拉取私有镜像）
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 拉取镜像
docker pull ghcr.io/OWNER/REPO-NAME:latest
```

## 配置环境变量

### 在 GitHub Actions 中使用 Secrets

```yaml
env:
  PROD_DB_PASSWORD: ${{ secrets.PROD_DB_PASSWORD }}
  PROD_GATEWAY_API_KEY: ${{ secrets.PROD_GATEWAY_API_KEY }}
```

### 在部署脚本中使用 Secrets

```bash
# 从环境变量读取
export PROD_DB_PASSWORD="${PROD_DB_PASSWORD}"
export PROD_GATEWAY_API_KEY="${PROD_GATEWAY_API_KEY}"
```

## 安全最佳实践

1. **定期轮换 Secrets**
   - 每 90 天轮换一次密码和密钥
   - 使用密钥管理服务（如 AWS Secrets Manager）

2. **最小权限原则**
   - 只授予必要的权限
   - 使用不同的密钥用于不同环境

3. **审计和监控**
   - 定期检查 Secrets 使用情况
   - 监控异常访问

4. **加密存储**
   - 使用加密的密钥存储
   - 不要在代码中硬编码密钥

## 故障排查

### Secrets 未生效

1. **检查 Secret 名称**：确保 Secret 名称与工作流中使用的名称一致
2. **检查权限**：确保工作流有权限访问 Secrets
3. **检查环境**：确保在正确的环境中使用 Secrets

### Container Registry 访问失败

1. **检查 Token 权限**：确保 Token 有 `write:packages` 权限
2. **检查登录**：确保已正确登录到 Registry
3. **检查镜像名称**：确保镜像名称格式正确（`ghcr.io/OWNER/REPO-NAME:tag`）

### 部署失败

1. **检查 SSH 密钥**：确保 SSH 密钥已正确配置
2. **检查服务器访问**：确保服务器可以访问
3. **检查部署脚本**：确保部署脚本有执行权限

## 参考

- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Container Registry 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

