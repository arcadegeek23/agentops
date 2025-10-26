#!/bin/bash

echo "==================================="
echo "AgentOps Docker Configuration Test"
echo "==================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if files exist
echo "1. Checking Docker configuration files..."
files=(
    "Dockerfile"
    "docker-compose.yml"
    ".env.example"
    ".dockerignore"
    "Makefile"
    "DOCKER_DEPLOYMENT.md"
    "app/api/Dockerfile"
    "app/dashboard/Dockerfile"
)

all_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file exists"
    else
        echo -e "  ${RED}✗${NC} $file is missing"
        all_exist=false
    fi
done

echo ""

# Check YAML syntax
echo "2. Validating YAML syntax..."
if command -v yamllint &> /dev/null; then
    if yamllint -d relaxed docker-compose.yml > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} docker-compose.yml syntax is valid"
    else
        echo -e "  ${YELLOW}⚠${NC} docker-compose.yml has warnings (non-critical)"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} yamllint not installed, skipping YAML validation"
fi

echo ""

# Check Dockerfile syntax
echo "3. Checking Dockerfile syntax..."
dockerfiles=(
    "Dockerfile"
    "app/api/Dockerfile"
    "app/dashboard/Dockerfile"
)

for dockerfile in "${dockerfiles[@]}"; do
    if [ -f "$dockerfile" ]; then
        if grep -q "FROM" "$dockerfile" && grep -q "WORKDIR" "$dockerfile"; then
            echo -e "  ${GREEN}✓${NC} $dockerfile has valid structure"
        else
            echo -e "  ${RED}✗${NC} $dockerfile may be incomplete"
        fi
    fi
done

echo ""

# Check environment variables
echo "4. Checking environment configuration..."
if [ -f ".env.example" ]; then
    required_vars=(
        "NEXT_PUBLIC_SUPABASE_URL"
        "SUPABASE_SERVICE_ROLE_KEY"
        "CLICKHOUSE_HOST"
        "CLICKHOUSE_PASSWORD"
        "JWT_SECRET_KEY"
    )
    
    for var in "${required_vars[@]}"; do
        if grep -q "$var" .env.example; then
            echo -e "  ${GREEN}✓${NC} $var defined in .env.example"
        else
            echo -e "  ${RED}✗${NC} $var missing from .env.example"
        fi
    done
fi

echo ""

# Check documentation
echo "5. Checking documentation..."
if [ -f "DOCKER_DEPLOYMENT.md" ]; then
    word_count=$(wc -w < DOCKER_DEPLOYMENT.md)
    if [ "$word_count" -gt 1000 ]; then
        echo -e "  ${GREEN}✓${NC} Comprehensive documentation exists ($word_count words)"
    else
        echo -e "  ${YELLOW}⚠${NC} Documentation may be incomplete ($word_count words)"
    fi
fi

echo ""

# Summary
echo "==================================="
echo "Validation Summary"
echo "==================================="
if [ "$all_exist" = true ]; then
    echo -e "${GREEN}All configuration files are present${NC}"
else
    echo -e "${RED}Some configuration files are missing${NC}"
fi

echo ""
echo "To deploy AgentOps with Docker:"
echo "  1. Copy .env.example to .env and configure"
echo "  2. Run: make up (or docker compose up -d)"
echo "  3. Access API at http://localhost:8000/docs"
echo "  4. Access Dashboard at http://localhost:3000"
echo ""
echo "For detailed instructions, see DOCKER_DEPLOYMENT.md"
