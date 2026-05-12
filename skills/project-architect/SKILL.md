---
name: project-architect
description: Generate foundational project documentation before development begins. Classifies the project into one of five archetypes (app-convex, app-postgres, content, frontend-external, service), then produces a doc set tailored to that archetype using the inline stack rules as the source of truth.
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
model: opus
---

# Project Architect

Generate the **north-star** documents for a new project. Downstream phases (tasks → subtasks → implementation) must align with these docs.

This skill is **opinionated**. The Stack Rules section below is binding: defaults are non-negotiable unless a §10 red flag fires.

---

## Archetypes (pick exactly one)

Five archetypes, grouped by scope for the user-facing question. Each maps to one template folder. **Folder = doc set for that archetype.**

| Scope (user mental model) | Archetype | Template folder | When to pick |
|---|---|---|---|
| Fullstack | `app-convex` | `templates/app-convex/` | Default for any App project (CRUD, auth, realtime, dashboards). Convex collapses backend+DB+realtime+storage. |
| Fullstack | `app-postgres` | `templates/app-postgres/` | Only when user explicitly opts out of Convex, OR a §10 red flag rules out Convex. |
| Frontend-only | `content` | `templates/content/` | Marketing site, blog, docs, landing page, SEO-critical, mostly static. Astro. |
| Frontend-only | `frontend-external` | `templates/frontend-external/` | UI consuming an existing/third-party API. No backend in this repo. |
| Backend-only | `service` | `templates/service/` | Specialist Go/Python service per §6 (only with a real trigger — see §6). |

**Visualization**: not a separate archetype.
- Interactive viz (the viz IS the product) → `app-convex` (Next.js, NOT Astro).
- Embedded viz (charts in a content page) → `content`.

**Hybrid (app + marketing site)**: NOT one project. Per §13, this is two repos. Run this skill twice — once with `app-convex` (or `app-postgres`), once with `content`. Tell the user.

**Out-of-rulebook archetype** (MCP server, CLI tool, browser extension, mobile, desktop, etc.): **refuse**. Tell the user the rulebook does not yet cover this archetype; ask them to extend the rulebook (this SKILL.md) and add a `templates/{archetype}/` folder before re-running.

---

## Discussion Flow

The rulebook does most of the deciding. Keep questions to the minimum needed to classify and confirm.

```
1. User shares idea
2. Classify archetype:
   - If clear-fit: state the chosen archetype and proceed (§15: auto-classify, propose, proceed unless user objects)
   - If ambiguous: ask exactly one disambiguating question
3. §10 red-flag check: if any apply, STOP and ask before proceeding
4. State the stack from the archetype's 02-tech-stack.md template (it is pre-filled)
5. Level 1 — high-level: problem, users, goals, success criteria
6. Level 2 — mid-level: core features, constraints, multi-platform? (only for app-convex / app-postgres / frontend-external)
7. Level 3 — deeper: data entities OR content collections OR API endpoints (depending on archetype)
8. Confirm alignment at each level before going deeper
9. User confirms: "Generate docs"
10. Generate all docs from templates/{archetype}/ to {project-root}/docs/
```

### Discussion rules

- Do NOT ask "what tech do you want?" — the archetype decides. Only revisit on a §10 red flag or user override (§15: comply without re-arguing).
- Do NOT discuss implementation details — that's for downstream agents.
- Stop at roadmap level — no tasks/subtasks.
- "Multiple platforms" question (webapp + mobile + desktop) only applies to `app-convex`, `app-postgres`, `frontend-external`. Skip otherwise.

---

## Stack Rules (binding)

### Meta-principles

1. **Ladder pattern.** Start with what is already in the stack. Climb tiers only when the user describes a concrete requirement the current tier cannot meet — never on hypothetical future need.
2. **Concrete trigger required.** "Might need X someday" does not justify climbing.
3. **Defaults are rules.** Do not propose alternatives unless a §10 red flag fires. Do not hedge with "consider" language.
4. **Polyglot only on §6 ecosystem trigger.** Otherwise the work belongs in Convex actions or the Next.js app.
5. **No paid hosting, no paid infra unless explicitly approved.** Self-hosting is the default.
6. **Latest stable on scaffold.** When scaffolding a new project, use the latest stable release of every named library/framework. Pinned major floors in templates (Next.js, Tailwind, Astro) are minimums — go newer if a newer stable is out. Verify current stable via context7 at write time before recording version floors. Canaries/RCs only when depending on a specific unreleased feature.

### Capability ladders (climb only on concrete trigger)

**Search (§7):**
1. Convex built-in search (when on Convex) — prefix, full-text on a field
2. Postgres FTS + `pg_trgm` (when on Postgres) — when search is secondary
3. Meilisearch — typo tolerance, faceted filtering, dedicated search UX
4. Typesense — when Meilisearch limits hit

NEVER suggest: Elasticsearch, OpenSearch, Sonic.

**Vector search (§8):**
1. Convex vector search (when on Convex)
2. Postgres + pgvector (when on Postgres)
3. Qdrant — when scale or filtering exceeds the above

**Background jobs (§9):**
1. Convex scheduled functions / actions (when on Convex)
2. Go worker polling Convex `jobs` table — when Convex action limits hit but the job is straightforward
3. trigger.dev — when fan-out orchestration, retries-with-state, or many heterogeneous jobs are needed
4. BullMQ + Valkey — when trigger.dev features are insufficient

### §6 — Specialist Services trigger

Add a specialist service ONLY on one of:

- **Python-only library required:** Whisper, Scrapy + Playwright (anti-bot), pdfplumber/camelot/unstructured, Polars-heavy transforms, PaddleOCR/EasyOCR, spaCy, sentence-transformers (local).
- **Go-only ecosystem required:** specific blockchain SDK, CLI being wrapped as a service.
- **CPU-bound work expected to exceed Convex action limits** (~10 min wall time, memory ceilings).
- **High-throughput sustained connections** at volumes Convex is not designed for (mass WebSocket fan-out, SSE at scale).

If the work is "call OpenAI/Anthropic/Replicate/Deepgram/ElevenLabs," it is NOT a specialist service. It is a Convex action in TypeScript.

**Language pick:** Python only with an ecosystem trigger above. Otherwise Go. If just calling external APIs → Go.

Reference table for common specialist work: see `templates/service/02-tech-stack.md`.

### §10 — Red Flags (STOP and ask)

If any of these apply, do NOT force-fit. Flag to user and ask before proceeding:

- Strong multi-region requirements
- Regulated data residency (HIPAA, regional GDPR enforcement, financial regs)
- Real-time at massive scale (>10k concurrent persistent connections per service)
- On-prem deployment requirements
- Heavy analytical / OLAP workload as core feature
- Strong multi-tenant SQL with row-level security as core requirement
- Languages or runtimes not covered here (Elixir, Rust beyond blockchain, JVM)
- GPU-required ML inference at production volume → use Replicate / Modal / Deepgram, OR escalate
- Long-running streaming work (multi-hour ML batches, video encoding pipelines)

### §11 — Payments

- **Default:** Paddle (Merchant of Record — handles tax globally).
- **Stripe:** only when the user explicitly approves AND has a tax solution.
- Never propose Stripe as default until Stripe ships MoR.

### §12 — Email

- **Transactional:** Resend.
- Do not propose Postmark, SES, or self-hosted email unless asked.

### §13 — Repo Structure

- App + marketing → two repos, shared design-system package.
- Specialist services → separate repos OR a monorepo subpackage. Default to separate repos until 2+ services exist.
- Monorepo tooling, when introduced: Bun workspaces + Turborepo. Do NOT introduce until a second package actually exists.

### §14 — Hard Anti-Patterns (refuse without deliberation)

| Category | Never suggest | Use instead |
|---|---|---|
| Hosting | Vercel, Netlify (paid hosting) | Self-hosted |
| Payments | Stripe (until MoR) | Paddle |
| LLM frameworks | LangChain, LangChain.js, LlamaIndex | Build RAG manually first |
| ORM (TS) | Prisma | Drizzle |
| ORM (Go) | GORM | sqlc |
| HTTP frameworks (Go) | Gin, Echo, Fiber | Chi or stdlib `net/http` |
| HTTP frameworks (Node, new services) | Express | Convex / Go; Hono only if Node HTTP unavoidable |
| Cache/queue | Redis | Valkey |
| Tooling | ESLint + Prettier | Biome |
| Tooling | Husky | Lefthook |
| Tooling | Webpack | Vite / Bun build |
| Project structure | Marketing + app in one Next.js project | Two repos |
| ML at production volume on CPU-only | Self-hosted Whisper, Llama, etc. | Replicate / Modal / Deepgram |
| Self-hosted observability | Sentry, PostHog | SaaS free tiers or skip |

### §15 — Agent Posture

- **Clear-fit project:** auto-classify, propose stack, proceed unless user objects.
- **Ambiguous classification:** ask exactly one question, then proceed.
- **§10 red flag fires:** stop, name the issue, ask before proceeding.
- **User overrides a default:** comply without re-arguing. Note the override but do not block on it.

### §16 — Out of Scope

Mobile, analytics, error tracking. If a project needs them, ask the user — do not pick a default.

---

## Generating Docs

1. Confirm archetype → identify `templates/{archetype}/` folder.
2. Read every template in that folder.
3. Fill each template based on the discussion. Replace `<!-- guidance -->` HTML comments with actual content; remove the comments.
4. Pre-filled tables in `02-tech-stack.md` are the chosen stack. Do not blank them. Adjust only on §10 red flag or user override (record the override + reason in the file).
5. Output all filled docs to `{project-root}/docs/`, preserving the numeric prefixes from the template folder.

### Multi-platform projects

When the project has multiple frontends (e.g., webapp + mobile):
- Duplicate the component-architecture and ui-flows templates per platform.
  - `app-convex`: `06-component-architecture-{platform}.md`, `07-ui-flows-{platform}.md`
  - `app-postgres`: `07-component-architecture-{platform}.md`, `08-ui-flows-{platform}.md`
  - `frontend-external`: `05-component-architecture-{platform}.md`, `06-ui-flows-{platform}.md`
- `02-tech-stack.md` should add a section per platform if the per-platform stack differs.

### Hybrid projects (app + marketing)

Do NOT generate both archetypes into one `docs/`. Per §13 these are two repos. Run the skill twice — once per repo. Tell the user explicitly.

---

## Standards (apply to all archetypes)

| Standard | Description |
|---|---|
| Vertical slice | Phases in the roadmap are end-to-end slices, not horizontal layers |
| Parallel by default | Assume phases can run in parallel unless a dependency is noted |
| Mermaid embedded | Diagrams written in mermaid inside markdown |
| Feature ≠ Roadmap | Feature list = flat inventory with priority; Roadmap = sequenced phases |
