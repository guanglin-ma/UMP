# CI/CD 快速开始指南

本文档提供快速开始使用 CI/CD 的步骤。

## 前置条件

- [ ] GitHub 仓库已创建
- [ ] 本地代码已推送到 GitHub
- [ ] 有 GitHub 仓库的管理员权限（用于配置 Secrets）

## 快速开始步骤

### 1. 配置 GitHub Secrets（必需）

#### 访问 Secrets 设置

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret** 添加新的 Secret

#### 最小配置（用于测试）

如果只是测试 CI/CD，可以只配置以下 Secrets：

| Secret 名称 | 说明 | 是否必需 |
|------------|------|---------|
| `GITHUB_TOKEN` | 自动提供，无需配置 | ✅ 自动 |
| `STAGING_DEPLOY_KEY` | 测试环境 SSH 密钥（如果测试部署） | ⚠️ 可选 |
| `STAGING_HOST` | 测试环境服务器地址（如果测试部署） | ⚠️ 可选 |

#### 完整配置（用于生产）

参考 `docs/GITHUB_SETUP.md` 配置所有必需的 Secrets。

### 2. 验证工作流文件

```bash
# 检查工作流文件是否存在
ls -la .github/workflows/

# 应该看到：
# - ci.yml
# - cd.yml
```

### 3. 提交代码触发 CI

```bash
# 添加所有更改
git add .

# 提交更改
git commit -m "feat: add CI/CD configuration"

# 推送到 GitHub（触发 CI）
git push origin main
```

### 4. 查看 CI 结果

1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看最新的工作流运行
4. 点击运行查看详细信息

### 5. 验证 CI 步骤

检查以下步骤是否通过：

- ✅ **Backend Tests** - 后端单元测试
- ✅ **Gateway Tests** - 网关集成测试（如果 Kafka 可用）
- ✅ **Frontend Tests** - 前端测试
- ✅ **Code Quality** - 代码质量检查
- ✅ **E2E Tests** - 端到端测试（如果服务可用）

## 测试清单

### 本地测试

- [ ] 运行 `./scripts/test_ci_cd.sh`
- [ ] 检查所有测试通过

### CI 测试

- [ ] 推送代码触发 CI
- [ ] 检查所有 CI 步骤通过
- [ ] 查看测试覆盖率报告
- [ ] 查看代码质量报告

### CD 测试（可选）

- [ ] 配置所有必需的 Secrets
- [ ] 推送到 main 分支触发 staging 部署
- [ ] 创建版本标签触发 production 部署

## 常见问题

### CI 工作流不触发

1. **检查分支**：确保推送到 `main` 或 `develop` 分支
2. **检查文件路径**：确保 `.github/workflows/ci.yml` 存在
3. **检查语法**：确保 YAML 语法正确

### 测试失败

1. **查看日志**：点击失败的步骤查看详细错误
2. **本地复现**：在本地运行相同的测试命令
3. **检查依赖**：确保所有依赖都已安装

### 部署失败

1. **检查 Secrets**：确保所有必需的 Secrets 都已配置
2. **检查 SSH 密钥**：确保 SSH 密钥正确
3. **检查服务器**：确保服务器可以访问

## 下一步

1. **完善 Secrets 配置**：参考 `docs/GITHUB_SETUP.md` 配置所有 Secrets
2. **测试部署**：配置 staging 环境并测试部署
3. **监控 CI/CD**：定期检查 CI/CD 运行情况
4. **优化工作流**：根据实际需求优化工作流配置

## 参考

- [GitHub Secrets 配置指南](./GITHUB_SETUP.md)
- [CI/CD 测试指南](./TESTING_CI_CD.md)
- [CI/CD 配置文档](./CI_CD.md)

