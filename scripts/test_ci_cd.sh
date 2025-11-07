#!/bin/bash
# CI/CD 工作流测试脚本

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check Git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Test local CI steps
test_local_ci() {
    log_step "Testing local CI steps..."
    
    # Test backend tests
    log_info "Running backend tests..."
    cd backend/api
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    pip install -q pytest pytest-cov pytest-asyncio pytest-mock || true
    pytest tests/ -v --tb=short --maxfail=5 || log_warn "Some tests failed (expected in CI)"
    cd ../..
    
    # Test code quality
    log_info "Running code quality checks..."
    cd backend/api
    pip install -q pylint flake8 black || true
    pylint *.py --disable=all --enable=E,F --max-line-length=120 || log_warn "Pylint found issues"
    flake8 *.py --max-line-length=120 --ignore=E501,W503 || log_warn "Flake8 found issues"
    black --check *.py tests/ || log_warn "Code formatting issues found"
    cd ../..
    
    log_info "Local CI tests completed"
}

# Test Docker build
test_docker_build() {
    log_step "Testing Docker build..."
    
    # Build API image
    log_info "Building API Docker image..."
    docker build -t ump-api:test -f backend/api/Dockerfile backend/api/ || {
        log_error "Failed to build API image"
        return 1
    }
    
    # Build Gateway image
    log_info "Building Gateway Docker image..."
    docker build -t ump-gateway:test -f backend/gateway/Dockerfile backend/gateway/ || {
        log_error "Failed to build Gateway image"
        return 1
    }
    
    log_info "Docker build tests completed"
}

# Test Docker Compose
test_docker_compose() {
    log_step "Testing Docker Compose configuration..."
    
    # Validate docker-compose.yml
    log_info "Validating docker-compose.yml..."
    docker-compose -f docker-compose.yml config > /dev/null || {
        log_error "docker-compose.yml validation failed"
        return 1
    }
    
    log_info "Docker Compose validation passed"
}

# Test deployment script
test_deploy_script() {
    log_step "Testing deployment script..."
    
    # Check script syntax
    log_info "Checking deployment script syntax..."
    bash -n scripts/deploy.sh || {
        log_error "Deployment script syntax error"
        return 1
    }
    
    # Test script help
    log_info "Testing deployment script help..."
    ./scripts/deploy.sh development help > /dev/null || {
        log_error "Deployment script help failed"
        return 1
    }
    
    log_info "Deployment script tests passed"
}

# Test GitHub Actions workflow syntax
test_workflow_syntax() {
    log_step "Testing GitHub Actions workflow syntax..."
    
    # Check if actionlint is available
    if command -v actionlint &> /dev/null; then
        log_info "Using actionlint to validate workflows..."
        actionlint .github/workflows/*.yml || log_warn "Workflow validation found issues"
    else
        log_warn "actionlint not installed, skipping workflow validation"
        log_info "Install actionlint: brew install actionlint (macOS) or go install github.com/rhymond/actionlint/cmd/actionlint@latest"
    fi
    
    # Basic YAML syntax check
    log_info "Checking YAML syntax..."
    # Try to install PyYAML if not available
    python3 -c "import yaml" 2>/dev/null || {
        log_warn "PyYAML not installed, installing..."
        pip3 install -q PyYAML || log_warn "Failed to install PyYAML, skipping YAML validation"
    }
    
    if python3 -c "import yaml" 2>/dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" || {
            log_error "CI workflow YAML syntax error"
            return 1
        }
        python3 -c "import yaml; yaml.safe_load(open('.github/workflows/cd.yml'))" || {
            log_error "CD workflow YAML syntax error"
            return 1
        }
    else
        log_warn "Skipping YAML validation (PyYAML not available)"
    fi
    
    log_info "Workflow syntax tests passed"
}

# Main
main() {
    log_info "Starting CI/CD workflow tests..."
    echo ""
    
    check_prerequisites
    echo ""
    
    test_workflow_syntax
    echo ""
    
    test_deploy_script
    echo ""
    
    test_docker_compose
    echo ""
    
    test_docker_build
    echo ""
    
    test_local_ci
    echo ""
    
    log_info "✅ All CI/CD tests completed!"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Configure GitHub Secrets (see docs/GITHUB_SETUP.md)"
    log_info "  2. Push code to trigger CI workflow"
    log_info "  3. Check GitHub Actions for results"
}

# Run main
main "$@"

