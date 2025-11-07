# GitHub Secrets 配置检查清单

## 📋 配置步骤

### 1. 访问 Secrets 设置

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret** 添加新的 Secret

### 2. 最小配置（仅测试 CI）

如果只是测试 CI 工作流，**无需配置任何 Secrets**，因为：
- `GITHUB_TOKEN` 自动提供
- CI 工作流不需要额外的 Secrets

### 3. 完整配置（用于部署）

如果需要测试部署功能，需要配置以下 Secrets：

#### Staging 环境 Secrets

| Secret 名称 | 说明 | 是否必需 | 示例 |
|------------|------|---------|------|
| `STAGING_DEPLOY_KEY` | 测试环境 SSH 私钥 | ✅ 必需 | `-----BEGIN RSA PRIVATE KEY-----...` |
| `STAGING_HOST` | 测试环境服务器地址 | ✅ 必需 | `staging.example.com` |
| `STAGING_USER` | 测试环境 SSH 用户名 | ⚠️ 可选（默认：deploy） | `deploy` |
| `STAGING_DB_PASSWORD` | 测试环境数据库密码 | ⚠️ 可选 | `staging-password-123` |
| `STAGING_REDIS_PASSWORD` | 测试环境 Redis 密码 | ⚠️ 可选 | `staging-redis-password-123` |
| `STAGING_CLICKHOUSE_PASSWORD` | 测试环境 ClickHouse 密码 | ⚠️ 可选 | `staging-ch-password-123` |
| `STAGING_GATEWAY_API_KEY` | 测试环境网关 API Key | ⚠️ 可选 | `staging-api-key-123` |
| `STAGING_GATEWAY_SIGNING_SECRET` | 测试环境网关签名密钥 | ⚠️ 可选 | `staging-signing-secret-123` |

#### Production 环境 Secrets

| Secret 名称 | 说明 | 是否必需 | 示例 |
|------------|------|---------|------|
| `PROD_DEPLOY_KEY` | 生产环境 SSH 私钥 | ✅ 必需 | `-----BEGIN RSA PRIVATE KEY-----...` |
| `PROD_HOST` | 生产环境服务器地址 | ✅ 必需 | `prod.example.com` |
| `PROD_USER` | 生产环境 SSH 用户名 | ⚠️ 可选（默认：deploy） | `deploy` |
| `PROD_DB_PASSWORD` | 生产环境数据库密码 | ⚠️ 可选 | `prod-password-123` |
| `PROD_REDIS_PASSWORD` | 生产环境 Redis 密码 | ⚠️ 可选 | `prod-redis-password-123` |
| `PROD_CLICKHOUSE_PASSWORD` | 生产环境 ClickHouse 密码 | ⚠️ 可选 | `prod-ch-password-123` |
| `PROD_GATEWAY_API_KEY` | 生产环境网关 API Key | ⚠️ 可选 | `prod-api-key-123` |
| `PROD_GATEWAY_SIGNING_SECRET` | 生产环境网关签名密钥 | ⚠️ 可选 | `prod-signing-secret-123` |
| `PROD_KEYCLOAK_CLIENT_SECRET` | 生产环境 Keycloak 客户端密钥 | ⚠️ 可选 | `keycloak-secret-123` |

### 4. 生成 SSH 部署密钥

```bash
# 生成 SSH 密钥对
ssh-keygen -t rsa -b 4096 -C "deploy@ump" -f ~/.ssh/ump_deploy_key

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/ump_deploy_key.pub deploy@staging.example.com

# 将私钥添加到 GitHub Secrets
cat ~/.ssh/ump_deploy_key
# 复制输出内容，添加到 GitHub Secrets 的 STAGING_DEPLOY_KEY 或 PROD_DEPLOY_KEY
```

### 5. 配置检查清单

#### CI 工作流（无需 Secrets）
- [ ] 无需配置（`GITHUB_TOKEN` 自动提供）

#### CD 工作流（需要 Secrets）
- [ ] `STAGING_DEPLOY_KEY` 已配置（如果测试 staging 部署）
- [ ] `STAGING_HOST` 已配置（如果测试 staging 部署）
- [ ] `PROD_DEPLOY_KEY` 已配置（如果测试 production 部署）
- [ ] `PROD_HOST` 已配置（如果测试 production 部署）
- [ ] 其他可选 Secrets 已配置（如果需要）

## 🚀 快速开始

### 仅测试 CI（推荐）

1. **无需配置任何 Secrets**
2. 直接推送代码触发 CI：
   ```bash
   git push origin main
   ```
3. 查看 CI 结果：
   - 进入 GitHub 仓库 → **Actions** 标签
   - 查看最新的工作流运行

### 测试部署

1. **配置必需的 Secrets**：
   - `STAGING_DEPLOY_KEY`
   - `STAGING_HOST`
2. 推送代码触发 CD：
   ```bash
   git push origin main  # 触发 staging 部署
   ```
3. 查看 CD 结果：
   - 进入 GitHub 仓库 → **Actions** 标签
   - 查看 **CD** 工作流运行

## 📚 参考

- [GitHub Secrets 配置指南](./GITHUB_SETUP.md) - 详细的配置说明
- [CI/CD 快速开始指南](./QUICK_START_CI_CD.md) - 快速开始步骤
- [CI/CD 测试指南](./TESTING_CI_CD.md) - 测试指南

## ⚠️ 注意事项

1. **不要提交 Secrets 到代码仓库**
   - 确保 `.env` 文件在 `.gitignore` 中
   - 只在 GitHub Secrets 中配置敏感信息

2. **定期轮换 Secrets**
   - 每 90 天轮换一次密码和密钥
   - 使用密钥管理服务（如 AWS Secrets Manager）

3. **最小权限原则**
   - 只授予必要的权限
   - 使用不同的密钥用于不同环境

