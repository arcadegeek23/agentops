# AgentOps Docker Deployment Guide

This guide provides comprehensive instructions for deploying AgentOps using Docker and Docker Compose.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Profiles](#deployment-profiles)
- [Configuration](#configuration)
- [Building and Running](#building-and-running)
- [Troubleshooting](#troubleshooting)
- [Production Deployment](#production-deployment)

## Overview

AgentOps provides multiple Docker deployment options:

1. **Python SDK Only** - Containerized Python SDK for running agent applications
2. **Full Stack** - Complete platform with API, Dashboard, and optional services
3. **Development Mode** - Full stack with hot-reload and debugging capabilities

## Prerequisites

Before you begin, ensure you have:

- **Docker** 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0+ ([Install Compose](https://docs.docker.com/compose/install/))
- **Supabase Account** ([Sign up](https://supabase.com))
- **ClickHouse Cloud Account** ([Sign up](https://clickhouse.com/cloud)) or local ClickHouse

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/AgentOps-AI/agentops.git
cd agentops
```

### 2. Configure Environment Variables

Copy the example environment file and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` and configure at minimum:

- **Supabase credentials** (URL, keys, database connection)
- **ClickHouse credentials** (host, port, password)
- **JWT secret key** (generate with `openssl rand -hex 32`)
- **Application URLs** (usually localhost for development)

See [Configuration](#configuration) section for detailed information.

### 3. Start the Services

**Basic deployment (API + Dashboard):**

```bash
docker-compose up -d
```

**With all optional services:**

```bash
docker-compose --profile with-otel --profile with-clickhouse --profile with-redis up -d
```

### 4. Verify Deployment

- **API Documentation**: http://localhost:8000/docs
- **Dashboard**: http://localhost:3000
- **Health Check**: http://localhost:8000/health

## Deployment Profiles

Docker Compose profiles allow you to selectively start services:

### Default Profile

Includes only the essential services:
- API Backend
- Dashboard Frontend

```bash
docker-compose up -d
```

### With OpenTelemetry Collector

Adds local OTLP trace collection:

```bash
docker-compose --profile with-otel up -d
```

### With Local ClickHouse

Adds local ClickHouse database (useful for fully offline development):

```bash
docker-compose --profile with-clickhouse up -d
```

### With Redis

Adds Redis for rate limiting and caching:

```bash
docker-compose --profile with-redis up -d
```

### All Services

```bash
docker-compose --profile with-otel --profile with-clickhouse --profile with-redis up -d
```

## Configuration

### Required Environment Variables

#### Supabase Configuration

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_PROJECT_ID=your-project-id

# Database connection
SUPABASE_HOST=db.xxxxx.supabase.co
SUPABASE_PORT=5432
SUPABASE_DATABASE=postgres
SUPABASE_USER=postgres.xxxxx
SUPABASE_PASSWORD=your-db-password
```

**How to get Supabase credentials:**
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **Settings → API**
   - Project URL → `NEXT_PUBLIC_SUPABASE_URL`
   - anon public → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - service_role secret → `SUPABASE_SERVICE_ROLE_KEY`
4. Navigate to **Settings → Database → Connection Info**
   - Host, Port, Database, User, Password

#### ClickHouse Configuration

```env
CLICKHOUSE_HOST=your-service.clickhouse.cloud
CLICKHOUSE_PORT=8443
CLICKHOUSE_USER=default
CLICKHOUSE_PASSWORD=your-password
CLICKHOUSE_DATABASE=otel_2
CLICKHOUSE_SECURE=true
CLICKHOUSE_ENDPOINT=https://your-service.clickhouse.cloud:8443
CLICKHOUSE_USERNAME=default
```

**How to get ClickHouse credentials:**
1. Go to [ClickHouse Cloud](https://clickhouse.com/cloud)
2. Create a service or select existing one
3. Click **Connect** to view connection details
4. Add your IP to the allowlist in **Security** settings

#### Authentication

```env
JWT_SECRET_KEY=your-long-random-secret-key
```

Generate a secure key:
```bash
openssl rand -hex 32
```

#### Application URLs

```env
PROTOCOL=http
API_DOMAIN=localhost:8000
APP_DOMAIN=localhost:3000
APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

### Optional Environment Variables

#### Stripe (for billing features)

```env
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
NEXT_STRIPE_SECRET_KEY=sk_test_...
NEXT_STRIPE_WEBHOOK_SECRET=whsec_...
```

#### Monitoring

```env
SENTRY_DSN=https://...@sentry.io/...
NEXT_PUBLIC_SENTRY_DSN=https://...@sentry.io/...
NEXT_PUBLIC_POSTHOG_KEY=phc_...
```

## Building and Running

### Build Images

Build all images:

```bash
docker-compose build
```

Build specific service:

```bash
docker-compose build api
docker-compose build dashboard
```

### Start Services

Start in detached mode:

```bash
docker-compose up -d
```

Start with logs:

```bash
docker-compose up
```

Start specific services:

```bash
docker-compose up -d api dashboard
```

### View Logs

All services:

```bash
docker-compose logs -f
```

Specific service:

```bash
docker-compose logs -f api
docker-compose logs -f dashboard
```

### Stop Services

```bash
docker-compose down
```

Stop and remove volumes:

```bash
docker-compose down -v
```

### Restart Services

```bash
docker-compose restart
```

Restart specific service:

```bash
docker-compose restart api
```

## Troubleshooting

### API Cannot Connect to Database

**Symptoms:**
- API fails to start
- Database connection errors in logs

**Solutions:**
1. Verify Supabase credentials in `.env`
2. Check if Supabase database is accessible
3. Ensure `SUPABASE_HOST` and `SUPABASE_PASSWORD` are correct
4. Verify SSL mode: `SUPABASE_SSLMODE=require`

```bash
docker-compose logs api | grep -i "database\|connection"
```

### Dashboard Cannot Reach API

**Symptoms:**
- Dashboard loads but shows connection errors
- CORS errors in browser console

**Solutions:**
1. Verify `NEXT_PUBLIC_API_URL=http://localhost:8000`
2. Ensure `APP_URL=http://localhost:3000` in API environment
3. Check API health: `curl http://localhost:8000/health`
4. Verify both services are running: `docker-compose ps`

### ClickHouse Connection Issues

**Symptoms:**
- Traces not appearing in dashboard
- ClickHouse connection errors

**Solutions:**
1. Verify ClickHouse credentials
2. Check if your IP is allowlisted in ClickHouse Cloud
3. For cloud: use port 8443 with `CLICKHOUSE_SECURE=true`
4. For local: use port 8123 with `CLICKHOUSE_SECURE=false`
5. Test connection:

```bash
curl -u default:password "http://localhost:8123/?query=SELECT%201"
```

### Port Already in Use

**Symptoms:**
- `Error: bind: address already in use`

**Solutions:**
1. Check what's using the port:

```bash
# Linux/Mac
lsof -i :8000
lsof -i :3000

# Windows
netstat -ano | findstr :8000
```

2. Stop conflicting services or change ports in `docker-compose.yml`

### Build Failures

**Symptoms:**
- Docker build fails
- Dependency installation errors

**Solutions:**
1. Clear Docker cache:

```bash
docker-compose build --no-cache
```

2. Ensure you have enough disk space:

```bash
docker system df
docker system prune -a
```

3. Check Docker logs:

```bash
docker-compose logs --tail=100
```

### Container Keeps Restarting

**Symptoms:**
- Service status shows "Restarting"

**Solutions:**
1. Check container logs:

```bash
docker-compose logs api
```

2. Verify all required environment variables are set
3. Check health check status:

```bash
docker-compose ps
```

## Production Deployment

### Security Considerations

1. **Use HTTPS**: Set `PROTOCOL=https` and configure SSL certificates
2. **Secure Secrets**: Use Docker secrets or environment variable management
3. **Network Isolation**: Use custom Docker networks
4. **Resource Limits**: Set CPU and memory limits in compose file

Example with resource limits:

```yaml
services:
  api:
    # ... other config ...
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

### Environment-Specific Configuration

Create separate environment files:

```bash
.env.development
.env.staging
.env.production
```

Load specific environment:

```bash
docker-compose --env-file .env.production up -d
```

### Scaling Services

Scale specific services:

```bash
docker-compose up -d --scale api=3
```

### Health Checks and Monitoring

Monitor service health:

```bash
docker-compose ps
```

Set up external monitoring:
- Configure Sentry for error tracking
- Use PostHog for analytics
- Set up Prometheus/Grafana for metrics

### Backup and Recovery

**Backup volumes:**

```bash
docker run --rm -v agentops_clickhouse-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/clickhouse-backup.tar.gz /data
```

**Restore volumes:**

```bash
docker run --rm -v agentops_clickhouse-data:/data -v $(pwd):/backup \
  ubuntu tar xzf /backup/clickhouse-backup.tar.gz -C /
```

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Deploy AgentOps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build images
        run: docker-compose build
      
      - name: Push to registry
        run: |
          docker-compose push
      
      - name: Deploy to production
        run: |
          docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Additional Resources

- [AgentOps Documentation](https://docs.agentops.ai)
- [App Setup Guide](app/README.md)
- [API Documentation](app/api/README.md)
- [Dashboard Documentation](app/dashboard/README.md)
- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Documentation](https://docs.docker.com/compose)

## Support

For issues and questions:
- GitHub Issues: https://github.com/AgentOps-AI/agentops/issues
- Discord: https://discord.gg/FagdcwwXRR
- Documentation: https://docs.agentops.ai

