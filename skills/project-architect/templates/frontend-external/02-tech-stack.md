# Tech Stack

Archetype: **Frontend on external API**. UI consumes an existing API (owned by another team, third party, or mock). No backend in this repo.

## Application

| Concern | Choice | Reason |
|---|---|---|
| Framework | Next.js (App Router) | §3 default |
| Framework alternative | Vite + React + React Router | Acceptable when SSR/RSC not needed and routing is simple |
| Language | TypeScript (`strict: true`, `noUncheckedIndexedAccess: true`) | §3 |
| Server state | TanStack Query | §3 — required (no Convex reactivity available) |
| Validation | Zod (validate API responses at the boundary) | §3 |
| Forms | React Hook Form + Zod resolver | §3 |
| Frontend state | Zustand | §3 |
| UI components | shadcn/ui | §3 |
| Styling | Tailwind CSS | §3 |
| Icons | Lucide | §3 |
| Component variants | CVA | §3 |
| Animation | Motion | §3 — only when needed |
| HTTP client | `fetch` (native) | Wrap in a thin client; no axios |
| Date library | date-fns | §3 |

## Cross-cutting

| Concern | Choice | Reason |
|---|---|---|
| Hosting | Self-hosted | §1 |

## Tooling

| Tool | Purpose |
|---|---|
| Bun | Package manager (default); pnpm fallback |
| Biome | Linter + formatter (§14 — never ESLint+Prettier) |
| Vitest | Unit tests |
| Playwright | E2E tests |
| MSW | API mocking in tests / dev when external API unavailable |
| `@t3-oss/env-nextjs` + Zod | Env var validation (Next.js) |
| Lefthook | Git hooks |
