# CI/CD 配置文档

本文档说明UMP平台的CI/CD配置和使用方法。

## 概述

UMP平台使用GitHub Actions进行CI/CD自动化，包括：

- **CI (Continuous Integration)**: 自动化测试、代码质量检查
- **CD (Continuous Deployment)**: 自动化构建和部署

## CI工作流

### 触发条件

- Push到 `main` 或 `develop` 分支
- 创建Pull Request到 `main` 或 `develop` 分支

### 工作流步骤

1. **Backend Tests** - 后端单元测试
   - 运行PostgreSQL、Redis、ClickHouse服务
   - 执行单元测试
   - 生成测试覆盖率报告

2. **Gateway Tests** - 网关集成测试
   - 运行Kafka和Zookeeper服务
   - 执行网关端到端测试

3. **Frontend Tests** - 前端测试
   - 运行lint检查
   - 构建前端应用

4. **Code Quality** - 代码质量检查
   - 运行pylint、flake8、black检查

5. **E2E Tests** - 端到端测试
   - 运行完整的端到端测试套件

## CD工作流

### 触发条件

- Push到 `main` 分支
- 创建版本标签（`v*`）
- 手动触发（workflow_dispatch）

### 工作流步骤

1. **Build and Push** - 构建和推送Docker镜像
   - 构建API和Gateway镜像
   - 推送到GitHub Container Registry

2. **Deploy Staging** - 部署到测试环境
   - 自动部署到staging环境（当push到main分支时）

3. **Deploy Production** - 部署到生产环境
   - 手动或通过版本标签触发
   - 部署到production环境

## 本地运行CI

### 运行测试

```bash
# 后端测试
cd backend/api
source venv/bin/activate
pytest tests/ -v --cov=. --cov-report=term

# 网关测试
cd backend/gateway
source venv/bin/activate
python3 test_gateway_e2e.py

# 代码质量检查
cd backend/api
pylint *.py
flake8 *.py
black --check *.py
```

### 运行E2E测试

```bash
# 启动服务
docker-compose up -d

# 运行E2E测试
python3 scripts/e2e_test.py --tenant-id acme
```

## 部署

### 使用部署脚本

```bash
# 开发环境
./scripts/deploy.sh development start

# 测试环境
./scripts/deploy.sh staging start

# 生产环境
./scripts/deploy.sh production start
```

### 使用Docker Compose

```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 环境配置

### 开发环境

使用 `.env.development` 或 `.env` 文件：

```bash
DEV_MODE=true
LOG_LEVEL=DEBUG
```

### 测试环境

使用 `.env.staging` 文件：

```bash
DEV_MODE=false
LOG_LEVEL=INFO
```

### 生产环境

使用 `.env.production` 文件：

```bash
DEV_MODE=false
LOG_LEVEL=WARNING
```

## 故障排查

### CI失败

1. **检查测试日志**：
   - 查看GitHub Actions的测试输出
   - 本地运行相同的测试命令

2. **检查代码质量**：
   - 运行 `pylint`、`flake8`、`black` 检查
   - 修复所有错误和警告

3. **检查依赖**：
   - 确保所有依赖都已安装
   - 检查requirements.txt是否最新

### 部署失败

1. **检查Docker镜像**：
   ```bash
   docker images | grep ump
   ```

2. **检查服务状态**：
   ```bash
   docker-compose ps
   ```

3. **查看服务日志**：
   ```bash
   docker-compose logs api
   docker-compose logs gateway
   ```

4. **检查环境变量**：
   ```bash
   docker-compose config
   ```

## 最佳实践

1. **提交前运行测试**：
   ```bash
   make test
   make lint
   ```

2. **保持测试覆盖率**：
   - 目标：70%以上
   - 新功能必须包含测试

3. **代码审查**：
   - 所有代码必须经过审查
   - 确保CI通过后才能合并

4. **版本管理**：
   - 使用语义化版本（Semantic Versioning）
   - 生产部署使用版本标签

## 参考

- [GitHub Actions工作流](../.github/workflows/ci.yml)
- [部署脚本](../scripts/deploy.sh)
- [环境配置文档](./ENVIRONMENT.md)

