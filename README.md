# autokit

A personal library of Claude Code skills and commands for development workflows.

---

## Skills

| Name | Description | Requires |
|------|-------------|----------|
| `api-testing` | Tests API endpoints with automatic authentication handling. Triggers on requests to test APIs, make curl calls, or send HTTP requests. | — |
| `astro-setup` | Sets up deployment for Astro static sites. Creates a Dockerfile optimized for Astro (bun + nginx) and delegates hosting, DNS, and first deploy to `coolify-setup`. | `coolify-setup` |
| `commit` | Creates git commits following conventional commit format. Analyzes staged changes, determines scope, and generates a structured commit message. | — |
| `coolify-setup` | Sets up Coolify deployment for any Dockerized project. Handles app creation, Cloudflare DNS, environment variables, and first deploy. Requires a `deploy/Dockerfile` to exist. | — |
| `guidelines-generator` | Generates a customized coding guidelines skill by analyzing existing code patterns or setting up standards for a new project. Supports Go, Python, and TypeScript with architecture templates (DDD/CQRS, Clean Architecture, modular monolith, etc.). Optionally invokes `testing-generator` after completion. | `testing-generator` *(optional)* |
| `project-architect` | Generates foundational project documentation before development begins. Supports fullstack, frontend-only, and backend-only modes. Produces project overview, tech stack, data models, feature list, architecture, API contracts, UI flows, and roadmap. | — |
| `testing-generator` | Generates a customized testing skill by analyzing test patterns and detecting the development environment (Docker or local). Produces executable test guidelines including environment setup, database configuration, and seed data management. | — |

---

## Commands

| Name | Description |
|------|-------------|
| `convert-make-to-just` | Converts an existing `Makefile` to a `justfile` with equivalent functionality. |
| `generate-build-tester` | Generates a customized `build-tester` agent that automatically builds the project and reports success or failure without attempting fixes. |
| `generate-docker-setup` | Generates a Docker setup for a project — `Dockerfile`, `docker-compose.yml`, and a build-and-push script. |
| `generate-justfile` | Generates a `justfile` with container management, Docker deployment, and development commands tailored to the project. |
| `generate-makefile` | Generates a `Makefile` with container management, Docker deployment, and development commands tailored to the project. |
| `generate-scout` | Generates a customized `/scout` command that explores the codebase and gathers context before planning or implementing a new feature. |
| `update-docs` | Updates documentation files based on recent implementation changes or staged git changes. Accepts file paths as arguments and rewrites them to reflect the current state of the code. |
