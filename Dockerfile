# AgentOps Python SDK Dockerfile
# This Dockerfile builds a container with the AgentOps Python SDK installed
# Suitable for running agent applications with AgentOps monitoring

FROM python:3.12-slim-bookworm

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy uv from official image for faster dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy package files
COPY pyproject.toml uv.lock ./

# Copy the agentops package source
COPY agentops ./agentops/

# Install the package and dependencies
RUN uv pip install --system -e .

# Create a directory for user applications
WORKDIR /workspace

# Default command - can be overridden
CMD ["python3"]

