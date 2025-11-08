#!/bin/bash
# GitHub Secrets 配置验证脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔍 GitHub Secrets 配置验证"
echo "============================"
echo ""

# 检查 GitHub CLI 是否安装
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) 未安装${NC}"
    echo "请先安装 GitHub CLI: https://cli.github.com/"
    exit 1
fi

# 检查是否已登录
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ 未登录 GitHub CLI${NC}"
    echo "请先登录: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓${NC} GitHub CLI 已安装并已登录"
echo ""

# 获取仓库信息
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
    echo -e "${YELLOW}⚠️${NC} 无法获取仓库信息，请确保在正确的目录中"
    echo "或者手动指定仓库: gh secret list --repo <owner/repo>"
    REPO=""
fi

# 定义需要验证的 Secrets
declare -a CI_SECRETS=(
    "CODECOV_TOKEN"
)

declare -a STAGING_SECRETS=(
    "STAGING_HOST"
    "STAGING_USER"
    "STAGING_DEPLOY_KEY"
    "STAGING_DB_PASSWORD"
    "STAGING_REDIS_PASSWORD"
    "STAGING_CLICKHOUSE_PASSWORD"
    "STAGING_GATEWAY_API_KEY"
    "STAGING_GATEWAY_SIGNING_SECRET"
    "STAGING_KEYCLOAK_CLIENT_SECRET"
)

declare -a PROD_SECRETS=(
    "PROD_HOST"
    "PROD_USER"
    "PROD_DEPLOY_KEY"
    "PROD_DB_PASSWORD"
    "PROD_REDIS_PASSWORD"
    "PROD_CLICKHOUSE_PASSWORD"
    "PROD_GATEWAY_API_KEY"
    "PROD_GATEWAY_SIGNING_SECRET"
    "PROD_KEYCLOAK_CLIENT_SECRET"
)

# 验证函数
verify_secret() {
    local secret_name=$1
    local repo_arg=""
    
    if [ -n "$REPO" ]; then
        repo_arg="--repo $REPO"
    fi
    
    if gh secret list $repo_arg 2>/dev/null | grep -q "^$secret_name"; then
        echo -e "${GREEN}✓${NC} $secret_name"
        return 0
    else
        echo -e "${RED}❌${NC} $secret_name (未找到)"
        return 1
    fi
}

# 验证所有 Secrets
echo "📋 验证 CI Secrets..."
echo "-------------------"
CI_MISSING=0
for secret in "${CI_SECRETS[@]}"; do
    if ! verify_secret "$secret"; then
        CI_MISSING=$((CI_MISSING + 1))
    fi
done
echo ""

echo "📋 验证 Staging 环境 Secrets..."
echo "----------------------------"
STAGING_MISSING=0
for secret in "${STAGING_SECRETS[@]}"; do
    if ! verify_secret "$secret"; then
        STAGING_MISSING=$((STAGING_MISSING + 1))
    fi
done
echo ""

echo "📋 验证 Production 环境 Secrets..."
echo "-------------------------------"
PROD_MISSING=0
for secret in "${PROD_SECRETS[@]}"; do
    if ! verify_secret "$secret"; then
        PROD_MISSING=$((PROD_MISSING + 1))
    fi
done
echo ""

# 总结
echo "📊 验证结果总结"
echo "================"
TOTAL_SECRETS=$((${#CI_SECRETS[@]} + ${#STAGING_SECRETS[@]} + ${#PROD_SECRETS[@]}))
TOTAL_MISSING=$((CI_MISSING + STAGING_MISSING + PROD_MISSING))
TOTAL_FOUND=$((TOTAL_SECRETS - TOTAL_MISSING))

echo "总 Secrets 数: $TOTAL_SECRETS"
echo -e "已配置: ${GREEN}$TOTAL_FOUND${NC}"
echo -e "缺失: ${RED}$TOTAL_MISSING${NC}"
echo ""

if [ $CI_MISSING -gt 0 ]; then
    echo -e "${YELLOW}⚠️${NC} CI Secrets 缺失: $CI_MISSING"
fi

if [ $STAGING_MISSING -gt 0 ]; then
    echo -e "${YELLOW}⚠️${NC} Staging Secrets 缺失: $STAGING_MISSING"
fi

if [ $PROD_MISSING -gt 0 ]; then
    echo -e "${YELLOW}⚠️${NC} Production Secrets 缺失: $PROD_MISSING"
fi

echo ""

# 最终结果
if [ $TOTAL_MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ 所有 Secrets 已正确配置！${NC}"
    echo ""
    echo "下一步建议："
    echo "1. 测试 CI 工作流"
    echo "2. 验证 Secrets 值格式（特别是私钥）"
    echo "3. 测试 CD 工作流（如果有服务器）"
    exit 0
else
    echo -e "${RED}❌ 部分 Secrets 缺失，请检查配置${NC}"
    echo ""
    echo "请访问 GitHub Secrets 设置页面："
    echo "https://github.com/guanglin-ma/UMP/settings/secrets/actions"
    echo ""
    echo "参考文档："
    echo "- docs/GITHUB_SECRETS_VALUES.md"
    echo "- docs/GITHUB_SECRETS_SETUP_INSTRUCTIONS.md"
    exit 1
fi

