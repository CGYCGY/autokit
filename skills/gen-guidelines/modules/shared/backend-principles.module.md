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

## Convex Branch

If the `convex` module is selected, **these rules from above DO NOT apply** (Convex collapses the stack):

| Standard rule | Convex equivalent |
|---------------|-------------------|
| Controller / service / repository layering | Single function per concern: `query` / `mutation` / `action` in `convex/<feature>.ts` |
| Manual input validation at boundaries | `args: v.*` validators on every public function — enforced by Convex runtime |
| Auth middleware | `ctx.auth.getUserIdentity()` per-function, with explicit null check |
| API versioning strategy | Function names ARE the API surface — version by adding new functions, keep old ones until clients update |
| ORM migrations | `convex/schema.ts` diffed and applied on `npx convex dev` / `deploy` |
| Connection pooling | Managed by Convex — no config needed |
| Transactions | `mutation` IS the transaction boundary — no explicit `BEGIN`/`COMMIT` |
| Status codes / response shapes | Functions return values; errors thrown become typed exceptions on the client |

**What still applies under Convex:**
- Seeder data requirement (still needed — see `seeder-data.module.md` for Convex-style seeders in `convex/seed.ts`)
- No secrets in code (use `npx convex env set` for server-side env)
- Authorization checks per function (Convex doesn't enforce who-can-call — you do)
- External I/O constraint: **only in `action`**, never in `query`/`mutation`

See `modules/typescript/convex.module.md` for detail.

## Progressive Loading

**Core (always load for backend):** This file + seeder-data module
**On-demand (load when relevant):**
- `reference/api-patterns.md` — when implementing endpoints
- `reference/auth-patterns.md` — when implementing authentication
- `reference/database-patterns.md` — when implementing database entities
