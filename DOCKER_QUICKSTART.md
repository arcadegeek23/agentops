# AgentOps Docker Quick Start Guide

Get AgentOps running with Docker in 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Supabase account (free tier works)
- ClickHouse Cloud account (free tier works)

## Step 1: Clone the Repository

```bash
git clone https://github.com/AgentOps-AI/agentops.git
cd agentops
```

## Step 2: Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```bash
# Minimum required configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_PROJECT_ID=your-project-id

SUPABASE_HOST=db.your-project.supabase.co
SUPABASE_PORT=5432
SUPABASE_DATABASE=postgres
SUPABASE_USER=postgres.your-project-id
SUPABASE_PASSWORD=your-db-password

CLICKHOUSE_HOST=your-service.clickhouse.cloud
CLICKHOUSE_PORT=8443
CLICKHOUSE_PASSWORD=your-password
CLICKHOUSE_DATABASE=otel_2

JWT_SECRET_KEY=$(openssl rand -hex 32)

APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### Where to Get Credentials

**Supabase:**
1. Go to https://supabase.com/dashboard
2. Select your project
3. Settings → API (for URLs and keys)
4. Settings → Database → Connection Info (for database credentials)

**ClickHouse:**
1. Go to https://clickhouse.com/cloud
2. Create or select a service
3. Click "Connect" for credentials
4. Add your IP to the allowlist

## Step 3: Start Services

Using Make (recommended):

```bash
make up
```

Or using Docker Compose directly:

```bash
docker compose up -d
```

## Step 4: Verify Deployment

Check if services are running:

```bash
docker compose ps
```

Access the services:

- **API Documentation**: http://localhost:8000/docs
- **Dashboard**: http://localhost:3000
- **Health Check**: http://localhost:8000/health

## Step 5: View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f dashboard
```

## Common Issues

### API won't start

Check database connection:
```bash
docker compose logs api | grep -i database
```

Verify Supabase credentials in `.env`

### Dashboard shows connection error

Verify API is running:
```bash
curl http://localhost:8000/health
```

Check CORS settings in `.env`:
```bash
APP_URL=http://localhost:3000
```

### ClickHouse connection failed

1. Verify credentials
2. Check if your IP is allowlisted in ClickHouse Cloud
3. For cloud: use port 8443 with CLICKHOUSE_SECURE=true

## Stopping Services

```bash
make down
# or
docker compose down
```

## Next Steps

- Read [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for advanced configuration
- Check [app/README.md](app/README.md) for application-specific documentation
- Visit https://docs.agentops.ai for usage guides

## Useful Commands

```bash
# Start services
make up

# Stop services
make down

# View logs
make logs

# Restart services
make restart

# Check health
make health

# Clean everything (including volumes)
make clean
```

## Getting Help

- Documentation: https://docs.agentops.ai
- GitHub Issues: https://github.com/AgentOps-AI/agentops/issues
- Discord: https://discord.gg/FagdcwwXRR

