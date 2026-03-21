---
module: backend-principles
language: all
category: backend
requires: []
conflicts: []
priority: high
---

# Backend Principles Module

Backend/full-stack specific universal rules. Always loaded for backend-guidelines and dev-guidelines.

## Core Requirements

### Seeder Data (CRITICAL)

**Every new database entity, table, or feature MUST have seeder data for testing.**

See `seeder-data.module.md` for detailed implementation patterns and validation.

### API Design

- RESTful conventions or GraphQL schema consistency
- Versioning strategy when breaking changes occur
- Proper HTTP status codes

### Security

- Input validation at API boundaries
- Authentication/authorization enforcement
- No secrets in code (environment variables only)

### Database

- Migrations for schema changes
- Connection pooling configuration
- Transaction handling for multi-step operations

## Progressive Loading

**Core (always load for backend):** This file + seeder-data module
**On-demand (load when relevant):**
- `reference/api-patterns.md` — when implementing endpoints
- `reference/auth-patterns.md` — when implementing authentication
- `reference/database-patterns.md` — when implementing database entities
