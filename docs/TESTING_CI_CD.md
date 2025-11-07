# CI/CD 测试指南

本文档说明如何测试 CI/CD 工作流，确保自动化流程正常工作。

## 本地测试

### 运行测试脚本

```bash
# 运行完整的CI/CD测试
./scripts/test_ci_cd.sh
```

测试脚本会检查：
- 前置条件（Git、Docker、Python等）
- GitHub Actions 工作流语法
- 部署脚本语法
- Docker Compose 配置
- Docker 镜像构建
- 本地 CI 步骤（测试、代码质量检查）

### 手动测试步骤

#### 1. 测试后端单元测试

```bash
cd backend/api
source venv/bin/activate
pytest tests/ -v --cov=. --cov-report=term
```

#### 2. 测试代码质量检查

```bash
cd backend/api
source venv/bin/activate

# Pylint
pylint *.py --disable=all --enable=E,F --max-line-length=120

# Flake8
flake8 *.py --max-line-length=120 --ignore=E501,W503

# Black
black --check *.py tests/
```

#### 3. 测试 Docker 构建

```bash
# 构建 API 镜像
docker build -t ump-api:test -f backend/api/Dockerfile backend/api/

# 构建 Gateway 镜像
docker build -t ump-gateway:test -f backend/gateway/Dockerfile backend/gateway/
```

#### 4. 测试 Docker Compose

```bash
# 验证配置
docker-compose -f docker-compose.yml config

# 启动服务（测试）
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```

#### 5. 测试部署脚本

```bash
# 检查语法
bash -n scripts/deploy.sh

# 测试帮助
./scripts/deploy.sh development help
```

## GitHub Actions 测试

### 触发 CI 工作流

#### 方法 1: 推送代码

```bash
# 创建测试分支
git checkout -b test/ci-workflow

# 修改文件（例如添加注释）
echo "# Test CI" >> README.md

# 提交并推送
git add README.md
git commit -m "test: trigger CI workflow"
git push origin test/ci-workflow

# 创建 Pull Request
# 在 GitHub 上创建 PR 到 main 分支
```

#### 方法 2: 直接推送到 main 分支

```bash
# 注意：这会触发 CI 和 CD 工作流
git checkout main
echo "# Test CI" >> README.md
git add README.md
git commit -m "test: trigger CI workflow"
git push origin main
```

### 查看 CI 结果

1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看最新的工作流运行
4. 点击运行查看详细信息

### 检查 CI 步骤

- ✅ **Backend Tests** - 后端单元测试
- ✅ **Gateway Tests** - 网关集成测试
- ✅ **Frontend Tests** - 前端测试
- ✅ **Code Quality** - 代码质量检查
- ✅ **E2E Tests** - 端到端测试

### 调试 CI 失败

1. **查看日志**：
   - 点击失败的步骤
   - 查看详细错误信息

2. **本地复现**：
   - 在本地运行相同的命令
   - 修复问题后重新提交

3. **检查环境**：
   - 确保所有依赖都已安装
   - 检查环境变量配置

## CD 工作流测试

### 触发 CD 工作流

#### 方法 1: 推送到 main 分支

```bash
# 推送到 main 分支会触发 staging 部署
git checkout main
git push origin main
```

#### 方法 2: 创建版本标签

```bash
# 创建版本标签会触发 production 部署
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

#### 方法 3: 手动触发

1. 进入 GitHub 仓库
2. 点击 **Actions** → **CD**
3. 点击 **Run workflow**
4. 选择环境和分支
5. 点击 **Run workflow**

### 查看 CD 结果

1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看 **CD** 工作流运行
4. 检查构建和部署步骤

### 检查 CD 步骤

- ✅ **Build and Push** - 构建和推送 Docker 镜像
- ✅ **Deploy Staging** - 部署到测试环境
- ✅ **Deploy Production** - 部署到生产环境

### 调试 CD 失败

1. **检查 Secrets**：
   - 确保所有必需的 Secrets 都已配置
   - 检查 Secret 名称是否正确

2. **检查部署密钥**：
   - 确保 SSH 密钥已正确配置
   - 检查服务器访问权限

3. **检查镜像推送**：
   - 确保 GitHub Token 有推送权限
   - 检查镜像名称格式

## 测试清单

### 本地测试清单

- [ ] 运行 `./scripts/test_ci_cd.sh`
- [ ] 测试后端单元测试
- [ ] 测试代码质量检查
- [ ] 测试 Docker 构建
- [ ] 测试 Docker Compose
- [ ] 测试部署脚本

### CI 测试清单

- [ ] 推送代码触发 CI
- [ ] 检查所有 CI 步骤通过
- [ ] 检查测试覆盖率报告
- [ ] 检查代码质量报告
- [ ] 检查 E2E 测试结果

### CD 测试清单

- [ ] 配置 GitHub Secrets
- [ ] 测试 Docker 镜像构建
- [ ] 测试镜像推送到 Registry
- [ ] 测试 staging 部署
- [ ] 测试 production 部署（使用标签）

## 常见问题

### CI 工作流不触发

1. **检查分支**：确保推送到 `main` 或 `develop` 分支
2. **检查文件路径**：确保 `.github/workflows/ci.yml` 存在
3. **检查语法**：确保 YAML 语法正确

### Docker 构建失败

1. **检查 Dockerfile**：确保 Dockerfile 语法正确
2. **检查依赖**：确保所有依赖都已安装
3. **检查上下文**：确保构建上下文正确

### 部署失败

1. **检查 Secrets**：确保所有 Secrets 都已配置
2. **检查 SSH 密钥**：确保 SSH 密钥正确
3. **检查服务器**：确保服务器可以访问

## 参考

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GitHub 设置指南](./GITHUB_SETUP.md)
- [CI/CD 配置文档](./CI_CD.md)

