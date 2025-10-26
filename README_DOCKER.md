# AgentOps Docker Setup

This repository has been enhanced with comprehensive Docker support for easy deployment and development.

## 🚀 Quick Start

```bash
# 1. Configure environment
cp .env.example .env
# Edit .env with your Supabase and ClickHouse credentials

# 2. Start services
make up

# 3. Access the application
# API: http://localhost:8000/docs
# Dashboard: http://localhost:3000
```

## 📦 What's Included

### New Docker Files

1. **Dockerfile** - Python SDK container
2. **docker-compose.yml** - Full stack orchestration
3. **.env.example** - Environment configuration template
4. **.dockerignore** - Build optimization
5. **Makefile** - Convenient Docker commands
6. **DOCKER_DEPLOYMENT.md** - Comprehensive deployment guide
7. **DOCKER_QUICKSTART.md** - 5-minute quick start guide
8. **validate-docker.sh** - Configuration validation script
9. **DOCKER_FILES_SUMMARY.md** - Detailed file documentation

### Services

- **API Backend** (FastAPI) - Port 8000
- **Dashboard** (Next.js) - Port 3000
- **OpenTelemetry Collector** (Optional) - Ports 4317, 4318
- **ClickHouse** (Optional, local) - Ports 8123, 9000
- **Redis** (Optional) - Port 6379

## 📖 Documentation

- **Quick Start**: [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md)
- **Full Deployment Guide**: [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md)
- **File Details**: [DOCKER_FILES_SUMMARY.md](DOCKER_FILES_SUMMARY.md)

## 🛠️ Common Commands

```bash
# Build images
make build

# Start services
make up

# Start with all optional services
make up-full

# View logs
make logs
make logs-api
make logs-dashboard

# Stop services
make down

# Clean everything (including volumes)
make clean

# Check health
make health

# Validate configuration
./validate-docker.sh
```

## 🔧 Configuration

### Required Environment Variables

- **Supabase**: URL, keys, database connection
- **ClickHouse**: Host, port, password
- **JWT**: Secret key for authentication
- **URLs**: Application and API URLs

See `.env.example` for all available configuration options.

### Getting Credentials

**Supabase** (https://supabase.com):
- Settings → API (for URLs and keys)
- Settings → Database (for connection info)

**ClickHouse** (https://clickhouse.com/cloud):
- Create service → Connect (for credentials)
- Security → Add your IP to allowlist

## 🎯 Deployment Profiles

### Default (Minimal)
```bash
make up
```
Includes: API + Dashboard

### With OpenTelemetry
```bash
docker compose --profile with-otel up -d
```
Adds: OTLP trace collector

### With Local ClickHouse
```bash
docker compose --profile with-clickhouse up -d
```
Adds: Local ClickHouse database

### Full Stack
```bash
make up-full
```
Includes: All services (API, Dashboard, OTEL, ClickHouse, Redis)

## 🔍 Validation

Run the validation script to check your setup:

```bash
./validate-docker.sh
```

This checks:
- ✓ All configuration files exist
- ✓ YAML syntax is valid
- ✓ Dockerfiles are properly structured
- ✓ Required environment variables are defined
- ✓ Documentation is comprehensive

## 🐛 Troubleshooting

### API won't start
```bash
docker compose logs api
# Check Supabase credentials in .env
```

### Dashboard connection error
```bash
# Verify API is running
curl http://localhost:8000/health

# Check CORS settings
# APP_URL should be http://localhost:3000
```

### ClickHouse connection failed
- Verify credentials in .env
- Check IP allowlist in ClickHouse Cloud
- For cloud: use port 8443 with CLICKHOUSE_SECURE=true

See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for detailed troubleshooting.

## 📊 Architecture

```
┌─────────────────┐
│   Dashboard     │  Port 3000 (Next.js)
│   (Frontend)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      API        │  Port 8000 (FastAPI)
│   (Backend)     │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌──────────┐
│Supabase │ │ClickHouse│
│  (Auth) │ │(Analytics)│
└─────────┘ └──────────┘
```

## 🚀 Production Deployment

For production deployment:

1. Use separate `.env.production` file
2. Set `PROTOCOL=https`
3. Configure SSL certificates
4. Set resource limits in docker-compose.yml
5. Use external managed services (Supabase, ClickHouse Cloud)
6. Set up monitoring (Sentry, PostHog)

See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for production best practices.

## 📝 Next Steps

1. ✅ Configure `.env` with your credentials
2. ✅ Run `./validate-docker.sh` to verify setup
3. ✅ Start services with `make up`
4. ✅ Access API at http://localhost:8000/docs
5. ✅ Access Dashboard at http://localhost:3000
6. ✅ Read [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for advanced usage

## 🤝 Support

- **Documentation**: https://docs.agentops.ai
- **GitHub Issues**: https://github.com/AgentOps-AI/agentops/issues
- **Discord**: https://discord.gg/FagdcwwXRR

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details
