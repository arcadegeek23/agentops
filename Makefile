.PHONY: help build up down restart logs clean test

# Default target
help:
	@echo "AgentOps Docker Management"
	@echo ""
	@echo "Available commands:"
	@echo "  make build          - Build all Docker images"
	@echo "  make up             - Start all services (API + Dashboard)"
	@echo "  make up-full        - Start all services including optional ones"
	@echo "  make down           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make logs           - View logs from all services"
	@echo "  make logs-api       - View API logs"
	@echo "  make logs-dashboard - View Dashboard logs"
	@echo "  make clean          - Stop services and remove volumes"
	@echo "  make ps             - Show running containers"
	@echo "  make shell-api      - Open shell in API container"
	@echo "  make shell-dashboard - Open shell in Dashboard container"
	@echo "  make test           - Run tests"
	@echo "  make health         - Check service health"

# Build all images
build:
	docker-compose build

# Build without cache
build-no-cache:
	docker-compose build --no-cache

# Start basic services (API + Dashboard)
up:
	docker-compose up -d
	@echo "Services started. Access:"
	@echo "  API: http://localhost:8000/docs"
	@echo "  Dashboard: http://localhost:3000"

# Start all services including optional ones
up-full:
	docker-compose --profile with-otel --profile with-clickhouse --profile with-redis up -d
	@echo "All services started."

# Start with logs
up-logs:
	docker-compose up

# Stop all services
down:
	docker-compose --profile with-otel --profile with-clickhouse --profile with-redis down

# Stop and remove volumes
clean:
	docker-compose --profile with-otel --profile with-clickhouse --profile with-redis down -v
	@echo "All services stopped and volumes removed."

# Restart all services
restart:
	docker-compose restart

# Restart specific service
restart-api:
	docker-compose restart api

restart-dashboard:
	docker-compose restart dashboard

# View logs
logs:
	docker-compose logs -f

logs-api:
	docker-compose logs -f api

logs-dashboard:
	docker-compose logs -f dashboard

logs-otel:
	docker-compose logs -f otelcollector

logs-clickhouse:
	docker-compose logs -f clickhouse

# Show running containers
ps:
	docker-compose ps

# Health check
health:
	@echo "Checking API health..."
	@curl -f http://localhost:8000/health || echo "API is not healthy"
	@echo ""
	@echo "Checking Dashboard..."
	@curl -f http://localhost:3000 > /dev/null 2>&1 && echo "Dashboard is running" || echo "Dashboard is not accessible"

# Open shell in containers
shell-api:
	docker-compose exec api /bin/bash

shell-dashboard:
	docker-compose exec dashboard /bin/sh

# Run tests
test:
	docker-compose exec api pytest

# Initialize ClickHouse schema (for local ClickHouse)
init-clickhouse:
	@echo "Initializing ClickHouse schema..."
	curl -u default:password 'http://localhost:8123/?query=CREATE%20DATABASE%20IF%20NOT%20EXISTS%20otel_2'
	curl --data-binary @app/clickhouse/migrations/0000_init.sql -u default:password 'http://localhost:8123/?query='
	@echo "ClickHouse initialized."

# Pull latest images
pull:
	docker-compose pull

# Show Docker disk usage
disk-usage:
	docker system df

# Prune unused Docker resources
prune:
	docker system prune -a

# Validate compose file
validate:
	docker-compose config

# Create .env from example if it doesn't exist
init-env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from .env.example"; \
		echo "Please edit .env and add your credentials"; \
	else \
		echo ".env file already exists"; \
	fi

