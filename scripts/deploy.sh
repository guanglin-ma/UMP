#!/bin/bash
# UMP Platform Deployment Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-development}
COMPOSE_FILE="docker-compose.yml"

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

check_prerequisites() {
    log_info "Checking prerequisites..."
    
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
    
    log_info "Prerequisites check passed"
}

load_environment() {
    log_info "Loading environment: $ENVIRONMENT"
    
    # 优先使用环境变量（CI/CD环境）
    if [ -n "$POSTGRES_HOST" ]; then
        log_info "Using environment variables from CI/CD"
        return
    fi
    
    # 加载环境文件
    if [ -f ".env.$ENVIRONMENT" ]; then
        export $(cat .env.$ENVIRONMENT | grep -v '^#' | xargs)
        log_info "Loaded .env.$ENVIRONMENT"
    elif [ -f ".env" ]; then
        export $(cat .env | grep -v '^#' | xargs)
        log_info "Loaded .env"
    else
        log_warn "No environment file found, using defaults"
    fi
}

build_images() {
    log_info "Building Docker images..."
    docker-compose -f $COMPOSE_FILE build
    log_info "Docker images built successfully"
}

start_services() {
    log_info "Starting services..."
    docker-compose -f $COMPOSE_FILE up -d
    log_info "Services started"
}

stop_services() {
    log_info "Stopping services..."
    docker-compose -f $COMPOSE_FILE down
    log_info "Services stopped"
}

restart_services() {
    log_info "Restarting services..."
    docker-compose -f $COMPOSE_FILE restart
    log_info "Services restarted"
}

check_health() {
    log_info "Checking service health..."
    
    # Wait for services to be ready
    sleep 10
    
    # Check API
    if curl -f http://localhost:8000/health &> /dev/null; then
        log_info "API is healthy"
    else
        log_warn "API health check failed"
    fi
    
    # Check Gateway
    if curl -f http://localhost:8090/health &> /dev/null; then
        log_info "Gateway is healthy"
    else
        log_warn "Gateway health check failed"
    fi
}

show_logs() {
    log_info "Showing service logs..."
    docker-compose -f $COMPOSE_FILE logs -f
}

# Main
case "$2" in
    start)
        check_prerequisites
        load_environment
        build_images
        start_services
        check_health
        ;;
    stop)
        stop_services
        ;;
    restart)
        check_prerequisites
        load_environment
        restart_services
        check_health
        ;;
    build)
        check_prerequisites
        load_environment
        build_images
        ;;
    logs)
        show_logs
        ;;
    health)
        check_health
        ;;
    help)
        echo "Usage: $0 <environment> <command>"
        echo ""
        echo "Environments:"
        echo "  development  - Development environment"
        echo "  staging      - Staging environment"
        echo "  production   - Production environment"
        echo ""
        echo "Commands:"
        echo "  start        - Start all services"
        echo "  stop         - Stop all services"
        echo "  restart      - Restart all services"
        echo "  build        - Build Docker images"
        echo "  logs         - Show service logs"
        echo "  health       - Check service health"
        echo "  help         - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 development start"
        echo "  $0 production start"
        exit 0
        ;;
    *)
        echo "Usage: $0 <environment> <command>"
        echo ""
        echo "Environments:"
        echo "  development  - Development environment"
        echo "  staging      - Staging environment"
        echo "  production   - Production environment"
        echo ""
        echo "Commands:"
        echo "  start        - Start all services"
        echo "  stop         - Stop all services"
        echo "  restart      - Restart all services"
        echo "  build        - Build Docker images"
        echo "  logs         - Show service logs"
        echo "  health       - Check service health"
        echo "  help         - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 development start"
        echo "  $0 production start"
        exit 1
        ;;
esac

