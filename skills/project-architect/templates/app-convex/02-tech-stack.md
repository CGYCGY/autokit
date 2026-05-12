# Tech Stack

Archetype: **App on Convex**. Picks below are defaults per stack-rules. Do not deviate unless a §10 red flag fires.

## Application

| Concern | Choice | Reason |
|---|---|---|
| Framework | Next.js 16+ (App Router) | §3 default for App archetype |
| Language | TypeScript (`strict: true`, `noUncheckedIndexedAccess: true`) | §3 |
| Backend / DB / Realtime / File storage | Convex | §3 — single-vendor for App archetype |
| Auth | WorkOS (AuthKit) | §3 — unified sign-in across portfolio; Convex validates WorkOS JWTs via configured issuer |
| Validation (inside Convex) | Convex validators (`v.*`) | §3 |
| Validation (Next.js side) | Zod | §3 |
| Forms | React Hook Form + Zod resolver | §3 |
| Frontend state | Zustand | §3 |
| Server state | Convex reactivity (no TanStack Query needed) | Convex provides realtime subscriptions natively |
| UI components | shadcn/ui | §3 |
| Styling | Tailwind CSS v4+ | §3 |
| Icons | Lucide | §3 |
| Component variants | CVA | §3 |
| Animation | Motion | §3 — only when needed |
| LLM SDK | Vercel AI SDK (published) / Claude Agent SDK (personal) | §3 |
| Date library | date-fns | §3 |
| Logging | pino | §3 |

## Capability Ladders (climb only on concrete trigger)

| Capability | Default | Climb to | Trigger |
|---|---|---|---|
| Background jobs | Convex scheduled functions / actions | Go worker polling Convex `jobs` table → trigger.dev → BullMQ + Valkey | §9 — Convex action limits hit |
| Search | Convex built-in search | Meilisearch → Typesense | §7 — typo tolerance / faceting needed |
| Vector search | Convex vector search | Qdrant | §8 — scale or filtering exceeds Convex |
| Specialist work | Convex action (TS) | Go service (default) / Python service (§6 trigger) | §6 — Python-only library or CPU/throughput exceeds Convex |

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
