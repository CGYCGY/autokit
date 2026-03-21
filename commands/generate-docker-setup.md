---
model: sonnet
description: Generate Docker setup for a project (Dockerfile, docker-compose, build-push script)
argument-hint: <runtime:bun|uv|node> [services:api,worker]
allowed-tools: Bash, Glob, Grep, Read, Write, TodoWrite
---

# Purpose

Generate a complete Docker setup for local development and production deployment. Creates:
- Multi-stage Dockerfile(s) with health checks
- docker-compose.yml with configurable ports
- docker-compose.override.yml for development (hot-reload)
- .dockerignore
- build-and-push.sh script for ghcr.io
- Environment file examples

## Variables

- `$RUNTIME` - Runtime/package manager: `bun` (JS/TS), `uv` (Python), `node` (Node.js)
- `$SERVICES` - Comma-separated list of services (default: `api`)
- `$PROJECT_NAME` - Auto-detected from root directory name
- `$REGISTRY` - Default: `ghcr.io/cgycgy`

## Instructions

1. **Parse Arguments**
   - First argument: runtime (required) - `bun`, `uv`, or `node`
   - Second argument: services (optional) - comma-separated, default `api`

2. **Detect Project Context**
   - Get project name from root directory
   - Check for existing files to avoid overwriting
   - Detect framework if possible (NestJS, FastAPI, Express, etc.)

3. **Generate Files Based on Runtime**

   ### For Bun (JS/TS)
   ```dockerfile
   # Builder
   FROM oven/bun:1 AS builder
   WORKDIR /app
   COPY package.json bun.lock ./
   RUN bun install --frozen-lockfile
   COPY . .
   RUN bun run build

   # Runner
   FROM oven/bun:1-slim AS runner
   # Install curl, create non-root user, copy dist
   HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
     CMD curl -f http://localhost:${PORT:-3000}/health || exit 1
   CMD ["bun", "run", "dist/main.js"]
   ```

   ### For UV (Python)
   ```dockerfile
   # Builder
   FROM ghcr.io/astral-sh/uv:python3.12-bookworm AS builder
   WORKDIR /app
   COPY pyproject.toml uv.lock ./
   RUN uv sync --frozen --no-dev
   COPY . .

   # Runner
   FROM python:3.12-slim AS runner
   # Copy venv, create non-root user
   HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
     CMD curl -f http://localhost:${PORT:-8000}/health || exit 1
   CMD ["python", "-m", "app.main"]
   ```

   ### For Node
   ```dockerfile
   # Builder
   FROM node:22-alpine AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci
   COPY . .
   RUN npm run build

   # Runner
   FROM node:22-alpine AS runner
   # Create non-root user, copy dist
   HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
     CMD curl -f http://localhost:${PORT:-3000}/health || exit 1
   CMD ["node", "dist/main.js"]
   ```

4. **Docker Compose Configuration**
   - All external ports configurable via environment variables
   - Health checks for all services
   - Named network: `<project>-network`
   - Named volumes for data persistence
   - Service dependencies with health conditions

5. **Build-Push Script**
   - Support both `.sh` (Linux/Mac) and `.ps1` (Windows)
   - Date-based versioning (YYYYMMDD)
   - Tag both version and latest
   - Explicit `--target runner`
   - Image: `ghcr.io/cgycgy/<project-name>-<service>`

6. **Environment Examples**
   - `.env.example` - Development defaults
   - `.env.production.example` - Production with CHANGE_ME placeholders

## Workflow

1. Parse and validate arguments
2. Detect project name and existing structure
3. Create `docker/` directory structure
4. Generate Dockerfile for each service
5. Generate docker-compose.yml with all services
6. Generate docker-compose.override.yml for development
7. Generate .dockerignore
8. Generate build-and-push.sh (make executable)
9. Update/create .env.example files
10. Print summary of created files

## Report

After generation, output:
- List of files created
- Quick start commands:
  ```bash
  # Start development
  docker compose up -d

  # Build and push production images
  ./docker/scripts/build-and-push.sh
  ```
- Any warnings (existing files skipped, missing dependencies)
