---
name: gen-guidelines
description: Generates customized coding guidelines for projects by analyzing existing code patterns OR setting up standards for new empty projects. Use when user asks to "generate guidelines", "create standards", "analyze patterns", "standardize code", "setup new project standards", or mentions "coding conventions". Supports Go, Python, TypeScript/JavaScript (web), and React Native / Expo (mobile) projects with modular architecture templates (DDD/CQRS, Clean Architecture, layered, modular monolith, microservices-ready, file-based routing).
context: fork
agent: Plan
---

# Guidelines Generator Skill

## Purpose
Analyze codebase patterns or setup new project standards, generating a customized guidelines skill in `.claude/skills/`.

## Supported Languages & Frameworks

### Go
- **Architectures**: DDD/CQRS, Clean Architecture, Standard, Modular Monolith
- **ORMs**: GORM, sqlc, ent
- **Frameworks**: Gin, Echo, Fiber, Chi
- **Patterns**: Microservices-ready boundaries, CQRS commands/queries, repository interfaces

### Python
- **Frameworks**: FastAPI, Django, Flask
- **Architectures**: Layered (MVC), Modular Monolith, DDD
- **ORMs**: SQLAlchemy, Django ORM, Tortoise, SQLModel
- **Validation**: Pydantic, Marshmallow, dataclasses

### TypeScript/JavaScript (Web)
- **Frameworks**: Next.js (App Router), NestJS, Express, Hono
- **UI Libraries**: React 19+
- **State Management**: Zustand, Redux, MobX, Jotai
- **Styling**: Tailwind CSS, styled-components, Emotion, CSS Modules
- **Validation**: Zod + React Hook Form, Yup, Joi, class-validator (NestJS)
- **ORMs**: TypeORM, Prisma, MikroORM, Drizzle
- **Architectures**: Modular Layered, Clean Architecture, DDD/CQRS, Simple/Flat
- **Patterns**: Component patterns, dependency injection, decorators, hooks, immutable state

### TypeScript / React Native (Mobile)
- **Framework**: React Native 0.7x+, Expo SDK 50+
- **Routing**: Expo Router (file-based), React Navigation
- **UI Primitives**: View/Text/Pressable, FlatList, Reanimated, Gesture Handler, Safe Area Context
- **Styling**: Tamagui, NativeWind, StyleSheet
- **State Management**: Zustand (+ MMKV persist adapter), Redux Toolkit
- **Storage**: MMKV (non-sensitive), expo-secure-store (tokens/PII)
- **Crypto**: react-native-quick-crypto (hot path), expo-crypto (one-shots)
- **Forms / Validation**: React Hook Form + Zod
- **Backend**: Convex (reactive, replaces ORM), REST/GraphQL + TanStack Query
- **Auth**: WorkOS AuthKit, Clerk, Supabase Auth, custom (JWT + secure-store)
- **Observability**: Sentry RN (`sentry-rn` module), PostHog RN (detection only, no module yet)
- **Tooling**: Bun, Biome, Lefthook (detected and noted in conventions)

### Cross-Stack Backend
- **Convex**: Reactive backend that replaces ORM + REST controller layer. When detected, `backend-principles` rules collapse to Convex-specific patterns (queries / mutations / actions, validators, indices).

## Workflow Overview

**Two modes based on project state:**

### Existing Project Mode (code exists)
```
1. DETECT PROJECT    → Language, framework, architecture
2. SELECT MODULES    → Choose applicable pattern modules
3. DEEP SCAN         → Extract patterns from codebase
4. ANALYZE           → Identify inconsistencies (batch mode)
5. CONSULT USER      → Resolve each inconsistency
6. GENERATE          → Create guidelines skill
7. REMEDIATION       → Offer to fix violations (optional)
```

### New Project Mode (empty/no code)
```
1. DETECT EMPTY      → No source code found
2. SELECT STACK      → User chooses language, framework, architecture
3. RECOMMEND         → Suggest architecture based on framework choice
4. SELECT MODULES    → Based on user selections
5. GENERATE          → Create guidelines from templates
6. STARTER TEMPLATES → Offer to create example code (optional)
```

## Guidelines Types

| Type | SKILL_NAME | For |
|------|------------|-----|
| Frontend | frontend-guidelines | React, Vue, Svelte, Angular |
| Backend | backend-guidelines | Go, FastAPI, Express, Hono, NestJS API-only |
| Full-stack | dev-guidelines | Next.js, NestJS with views, Django |
| Mobile | mobile-guidelines | React Native (Expo or bare) |

## Manual Selection

Both workflows ask user first:
```
Guidelines type? 1. Auto-detect 2. Frontend 3. Backend 4. Full-stack 5. Mobile
```

If 2/3/4/5 selected → skip auto-detection, use user's choice.

## Execution Steps

### Phase 1: Project Detection & Module Selection

**Read and execute:** `workflows/detect-project.md`

For new projects, read: `workflows/new-project.md`

**ALWAYS load:** `modules/shared/general-principles.module.md` first, then selected modules from `modules/go/`, `modules/python/`, or `modules/typescript/`.

**CONDITIONALLY load:**
- `modules/shared/backend-principles.module.md` — for backend-guidelines or dev-guidelines
- `modules/shared/seeder-data.module.md` — when ORM/database detected (GORM, Prisma, SQLAlchemy, etc.)

### Phase 2: Deep Pattern Extraction

**Read and execute:** `workflows/analyze-patterns.md`

**Read extractor:** `extractors/go-extractors.md`, `extractors/python-extractors.md`, or `extractors/typescript-extractors.md`

**🚀 PARALLEL EXECUTION:** Use subagents to scan different layers simultaneously. See workflow file for subagent prompt templates.

### Phase 3: Inconsistency Analysis

**Read and execute:** `workflows/resolve-inconsistencies.md`

**🚀 PARALLEL EXECUTION:** Use subagents to analyze different categories simultaneously. See workflow file for subagent prompt templates and priority ranking.

### Phase 4: User Consultation

Present inconsistencies to user for standardization decisions. See `workflows/resolve-inconsistencies.md` for presentation format and decision recording.

Record all decisions in `decisions.md`.

### Phase 5: Guidelines Generation

**Read and execute:** `workflows/generate-guidelines.md`

**🚀 PARALLEL EXECUTION:** Use subagents to generate different docs simultaneously. See workflow file for subagent prompt templates.

Use templates from `templates/SKILL.template.md`, `templates/reference.template.md`, `templates/checklist.template.md`.

### Phase 6: Remediation (Optional)

**⚠️ SEQUENTIAL ONLY:** Do NOT use subagents for remediation. File edits require coordination to avoid conflicts.

Options:
- A) Apply auto-fixes now (safe changes)
- B) Create remediation plan (detailed tasks with code snippets)
- C) Skip remediation (just use guidelines going forward)

## Supporting Files

### Workflows
- `workflows/detect-project.md` - Project detection logic (existing projects)
- `workflows/new-project.md` - New/empty project workflow with tech stack selection
- `workflows/analyze-patterns.md` - Pattern extraction process
- `workflows/resolve-inconsistencies.md` - Inconsistency resolution
- `workflows/generate-guidelines.md` - Guidelines creation

### Modules
- `modules/shared/general-principles.module.md` - **ALWAYS included** (DRY, SOLID, Clean Code, etc.)
- `modules/shared/backend-principles.module.md` - **Backend/full-stack only** (API design, security, database)
- `modules/shared/seeder-data.module.md` - **Auto-loaded when ORM detected** (seeder requirements, patterns, anti-patterns)
- `modules/go/*.module.md` - Go pattern modules
- `modules/python/*.module.md` - Python pattern modules
- `modules/typescript/*.module.md` - TypeScript/JavaScript pattern modules

### Extractors
- `extractors/go-extractors.md` - Go code analysis logic
- `extractors/python-extractors.md` - Python code analysis logic
- `extractors/typescript-extractors.md` - TypeScript/JavaScript code analysis logic

### Templates
- `templates/SKILL.template.md` - Template for generated SKILL.md
- `templates/reference.template.md` - Template for reference docs
- `templates/checklist.template.md` - Template for checklists

### Examples
- `examples/go-ddd-output.md` - Example generated guidelines (Go DDD)
- `examples/fastapi-layered-output.md` - Example generated guidelines (Python FastAPI)

## Key Principles

1. **Context Efficiency**: Generated SKILL.md must optimize for agent execution, not human documentation
   - Remove redundant sections (activation logic already in frontmatter)
   - Every line must be actionable or provide decision-making value
   - Use progressive loading (reference files) instead of embedding everything
   - No explanatory fluff meant for humans
   - Anti-patterns: only non-obvious ones (subtle mistakes, not obvious opposites of good patterns)
2. **Universal First**: Always include general-principles module (DRY, SOLID, Clean Code)
3. **Deep Analysis**: Don't guess; extract actual patterns from code
4. **Parallel Processing**: Use subagents for pattern extraction, analysis, and doc generation
5. **Batch Inconsistencies**: Collect all issues before consulting user
6. **User Decides**: Never auto-standardize without confirmation
7. **Document Decisions**: Record all choices with rationale
8. **Safe Remediation**: No parallel file edits; remediation is always sequential
9. **Progressive Refinement**: Guidelines can be regenerated as architecture evolves

## Parallel Processing Summary

| Phase | Parallel? | Reason |
|-------|-----------|--------|
| Phase 1: Detection | ❌ No | Quick, sequential |
| Phase 2: Pattern Extraction | ✅ Yes | Scan layers independently |
| Phase 3: Inconsistency Analysis | ✅ Yes | Analyze categories independently |
| Phase 4: User Consultation | ❌ No | Requires user interaction |
| Phase 5: Doc Generation | ✅ Yes | Generate docs independently |
| Phase 6: Remediation | ❌ No | File edits need coordination |

## Special Features

### Microservices Readiness (Go)

When `microservices-ready.module` is selected:
- Scan for cross-module dependencies
- Identify boundary violations (direct domain imports)
- Check for database-per-service compliance
- Analyze event-driven communication readiness
- Generate migration roadmap

### Architecture Evolution Support

Guidelines can be regenerated:
```
Phase 1: Layered → Generate with layered.module
Phase 2: Modular Monolith → Regenerate with modular-monolith.module
Phase 3: Microservices → Regenerate with microservices-ready.module
```

## Example Invocations

**For existing projects:**
```
"Generate coding guidelines for this project"
"Create backend development standards"
"Analyze code patterns and standardize"
"I want to document our coding conventions"
"Prepare this codebase for microservices migration"
```

**For new/empty projects:**
```
"Generate guidelines for a new Go project"
"Setup coding standards for a new NestJS app"
"I'm starting a new FastAPI project, create guidelines"
"Create development standards before I start coding"
"Setup project standards for a new TypeScript backend"
```

## Output

Generates `.claude/skills/{frontend,backend,dev}-guidelines/` containing:
- SKILL.md
- reference/ (pattern docs)
- examples/ (annotated code)
- checklists/ (validation)
- decisions.md

## Testing Skill Integration

After generating development guidelines, offer to generate a testing skill:

```
Guidelines created successfully!

Would you like to also generate a testing skill? (y/n)

The testing skill will include:
- Test execution commands (Docker/local aware)
- Test patterns from your codebase
- Database setup for tests
- Seed data guidelines

> y

[Invokes testing-generator skill]
```

**Related Skill:** `testing-generator`
- Generates `.claude/skills/testing/`
- Detects development environment (Docker, local)
- Ensures test DB matches production architecture
- Creates agent-ready test execution guidelines

This integration follows Option C architecture:
- `guidelines-generator` can invoke `testing-generator`
- `testing-generator` can also be invoked standalone
- Both skills are focused and independently usable
