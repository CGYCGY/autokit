# Tech Stack

Archetype: **Content site (Astro)**. Frontend-only — no backend in this repo. Forms post to a sibling repo's Convex HTTP action or Next.js route handler (§5).

## Application

| Concern | Choice | Reason |
|---|---|---|
| Framework | Astro | §5 default for Content archetype |
| Language | TypeScript (`strict: true`) | §3 |
| Content | Astro Content Collections + MDX | §5 |
| Styling | Tailwind CSS | §5 |
| Components (interactive islands) | React | §5 |
| UI components (in islands) | shadcn/ui | §5 |
| Icons (in islands) | Lucide | §3 |
| Form submission target | Convex HTTP action OR Next.js route handler in sibling repo | §5 — never a backend in the Astro repo |

## Cross-cutting

| Concern | Choice | Reason |
|---|---|---|
| Email (transactional, when needed) | Resend (called from sibling repo, not Astro) | §12 |
| Hosting | Self-hosted | §1 |

## Tooling

| Tool | Purpose |
|---|---|
| Bun | Package manager (default); pnpm fallback |
| Biome | Linter + formatter (§14 — never ESLint+Prettier) |
| Vitest | Unit tests where applicable |
| Playwright | E2E for interactive islands |
| Lefthook | Git hooks |

## Hard rule

Marketing site and app NEVER share a Next.js project. Always two repos with a shared design-system package (§5, §13).
