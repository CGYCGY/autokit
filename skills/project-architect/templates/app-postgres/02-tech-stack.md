# Tech Stack

Archetype: **App on Postgres** (Convex opt-out per §4). Picks below are defaults. Do not deviate unless a §10 red flag fires.

## Application

| Concern | Choice | Reason |
|---|---|---|
| Framework | Next.js (App Router) | §3 default for App archetype |
| Language | TypeScript (`strict: true`, `noUncheckedIndexedAccess: true`) | §3 |
| Database | PostgreSQL | §4 |
| ORM | Drizzle + Drizzle Kit (migrations checked into repo) | §4, §14 — never Prisma |
| Auth | BetterAuth | §4 |
| Server state | TanStack Query | §3 |
| Validation | Zod | §3 |
| Forms | React Hook Form + Zod resolver | §3 |
| Frontend state | Zustand | §3 |
| UI components | shadcn/ui | §3 |
| Styling | Tailwind CSS | §3 |
| Icons | Lucide | §3 |
| Component variants | CVA | §3 |
| Animation | Motion | §3 — only when needed |
| LLM SDK | Vercel AI SDK (published) / Claude Agent SDK (personal) | §3 |
| Date library | date-fns | §3 |
| Logging | pino | §3 |

## Capability Ladders (climb only on concrete trigger)

| Capability | Default | Climb to | Trigger |
|---|---|---|---|
| Background jobs | trigger.dev | BullMQ + Valkey | §9 — trigger.dev features insufficient |
| Cache / queue infra | Valkey (only when BullMQ or explicit cache need) | — | §4, §14 — never Redis |
| Rate limiting | `@upstash/ratelimit` + Valkey | — | §4 |
| Search | Postgres FTS + `pg_trgm` | Meilisearch → Typesense | §7 — typo tolerance / faceting needed |
| Vector search | Postgres + pgvector | Qdrant | §8 — scale or filtering exceeds pgvector |
| Specialist work | Server-side TS in Next.js | Go service (default) / Python service (§6 trigger) | §6 — Python-only library or CPU/throughput exceeds Node |

## Cross-cutting

| Concern | Choice | Reason |
|---|---|---|
| Email (transactional) | Resend | §12 |
| Payments | Paddle (Merchant of Record) | §11 — Stripe forbidden until MoR |
| Hosting | Self-hosted | §1 — no paid hosting unless approved |

## Tooling

| Tool | Purpose |
|---|---|
| Bun | Package manager (default); pnpm fallback (§3) |
| Biome | Linter + formatter (§3, §14 — never ESLint+Prettier) |
| Vitest | Unit tests (§3) |
| Playwright | E2E tests (§3) |
| `@t3-oss/env-nextjs` + Zod | Env var validation (§3) |
| Lefthook | Git hooks (§3, §14 — never Husky) |
| Vite or Bun build | Build tool (§3, §14 — never Webpack) |

## BetterAuth + non-TS services

BetterAuth lives in the Next.js app. Other-language services validate JWTs issued by BetterAuth via shared secret or JWKS. Do not call BetterAuth directly from Go/Python.
