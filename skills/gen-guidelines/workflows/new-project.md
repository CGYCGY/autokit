# New Project Workflow

Workflow for generating guidelines for empty/new projects before any code is written.

## Detection

**Trigger conditions:**
- No source code files found (no `.go`, `.py`, `.js`, `.ts`, etc.)
- Only config files exist (`go.mod`, `pyproject.toml`, `package.json`) OR nothing at all
- User explicitly says "new project" or "starting fresh"

**Detection script:**
```bash
# Check for source code files
find . -type f \( -name "*.go" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) \
  ! -path "*/vendor/*" ! -path "*/node_modules/*" ! -path "*/.venv/*" | head -5

# If no results → empty project mode
```

## Workflow Steps

### Step 1: Confirm New Project Mode

```
No source code detected. Starting in NEW PROJECT mode.

This will generate guidelines based on your intended tech stack
(without analyzing existing code).

Continue? (yes/no)
```

### Step 2: Choose Guidelines Type

```
Guidelines type?
1. Auto-detect (Recommended)
2. Frontend
3. Backend
4. Full-stack
5. Mobile (React Native)
```

**If 2/3/4/5:** Set variables below, skip Step 5.

| Choice | SKILL_NAME | SKILL_TITLE | SKILL_SCOPE |
|--------|------------|-------------|-------------|
| 2 | frontend-guidelines | Frontend Development Guidelines | frontend |
| 3 | backend-guidelines | Backend Development Guidelines | backend |
| 4 | dev-guidelines | Development Guidelines | full-stack |
| 5 | mobile-guidelines | Mobile Development Guidelines | mobile |

---

### Step 3: Select Language

```
What programming language will you use?

1. Go
2. Python
3. TypeScript/JavaScript
4. Other (specify)

>
```

### Step 4: Select Framework (based on language)

**For Go:**
```
Select your web framework:

1. Gin
2. Echo
3. Fiber
4. Chi
5. Standard library (net/http)
6. None / CLI application

>
```

**For Python:**
```
Select your web framework:

1. FastAPI
2. Django
3. Flask
4. None / CLI application

>
```

**For TypeScript/JavaScript:**
```
Select your framework:

1. Next.js (Full-stack → dev-guidelines)
2. React (Frontend → frontend-guidelines)
3. Vue (Frontend → frontend-guidelines)
4. NestJS (Backend/Full-stack)
5. Express (Backend → backend-guidelines)
6. Hono (Backend → backend-guidelines)
7. React Native + Expo (Mobile → mobile-guidelines, Recommended for new mobile)
8. React Native (bare) (Mobile → mobile-guidelines)
9. None / CLI application

>
```

**Project type determination:**
- **Next.js** → Always full-stack (`dev-guidelines`)
- **React/Vue/Svelte** → Frontend (`frontend-guidelines`)
- **Express/Hono** → Backend (`backend-guidelines`)
- **React Native (Expo or bare)** → Mobile (`mobile-guidelines`)
- **NestJS** → Ask: "Will this be API-only (backend) or include views/templates (full-stack)?"
  - API-only → `backend-guidelines`
  - With views → `dev-guidelines`

### Step 5: Determine Project Type (Auto-detect only)

**Skip if user manually selected in Step 2.**

| Project Type | SKILL_NAME | Frameworks |
|--------------|------------|------------|
| Frontend | frontend-guidelines | React, Vue, Svelte, Angular |
| Backend | backend-guidelines | Go, FastAPI, Flask, Express, Hono, NestJS API-only |
| Full-stack | dev-guidelines | Next.js, NestJS with views, Django full MVC |

### Step 6: Select Architecture (with framework-based recommendations)

Architecture recommendations are based on framework choice:

**For Go + Gin/Echo/Fiber/Chi:**
```
What architecture pattern will you follow?

1. DDD/CQRS (Domain-Driven Design with Command/Query separation)
   → Best for complex business domains

2. Clean Architecture (Recommended for Go APIs)
   → Best for testability and framework independence

3. Layered/MVC
   → Best for straightforward CRUD applications

4. Modular Monolith
   → Best for future microservices migration

5. Simple/Flat
   → Best for small projects, scripts, utilities

>
```

**For Python + FastAPI:**
```
What architecture pattern will you follow?

1. Layered/MVC (Recommended for FastAPI)
   → Best for straightforward CRUD applications

2. DDD/CQRS
   → Best for complex business domains

3. Clean Architecture
   → Best for testability and framework independence

4. Modular Monolith
   → Best for future microservices migration

5. Simple/Flat
   → Best for small projects, scripts, utilities

>
```

**For Python + Django:**
```
What architecture pattern will you follow?

1. Django MTV (Recommended - Django's default)
   → Model-Template-View, Django's native pattern

2. DDD with Django
   → Domain-Driven Design adapted for Django

3. Simple/Flat
   → Best for small projects

>
```

**For Python + Flask:**
```
What architecture pattern will you follow?

1. Simple/Flat (Recommended for Flask)
   → Best for small projects, microservices

2. Layered/MVC
   → Best for medium-sized applications

3. Application Factory + Blueprints
   → Best for larger Flask applications

>
```

**For TypeScript + NestJS:**
```
What architecture pattern will you follow?

1. Modular Layered (Recommended - NestJS default)
   → Controllers → Services → Repositories per module

2. DDD/CQRS with NestJS
   → Using @nestjs/cqrs package

3. Hexagonal/Ports & Adapters
   → Best for complex domains with many integrations

4. Microservices
   → Using NestJS microservices package

>
```

**For TypeScript + Express:**
```
What architecture pattern will you follow?

1. Layered/MVC (Recommended for Express)
   → Routes → Controllers → Services → Repositories

2. Clean Architecture
   → Best for testability and framework independence

3. Simple/Flat
   → Best for small APIs, microservices

>
```

**For TypeScript + Next.js:**
```
What architecture pattern will you follow?

1. App Router Convention (Recommended - Next.js 13+)
   → File-based routing with server components

2. Feature-based Structure
   → Organize by features/domains

3. Layered (for API routes)
   → Separate API logic into services

>
```

**For TypeScript + Hono:**
```
What architecture pattern will you follow?

1. Simple/Flat (Recommended for Hono)
   → Best for edge functions, small APIs

2. Layered
   → Routes → Handlers → Services

3. Modular
   → Organize by feature modules

>
```

**For TypeScript + React Native (Expo or bare):**
```
What routing approach?

1. Expo Router (Recommended for Expo)
   → File-based routing, deep linking, typed routes

2. React Navigation
   → Imperative navigator config (Stack/Tabs/Drawer)

3. None / single screen
   → Small utility apps

>
```

```
What styling library?

1. Tamagui (Recommended for design systems + cross-platform)
   → Compiled style props, themes, RN + web

2. NativeWind
   → Tailwind classes on RN primitives

3. StyleSheet (built-in)
   → No external dependency, manual styles

>
```

```
What state management?

1. Zustand (Recommended for RN)
   → Lightweight, sync, MMKV-persistable

2. Redux Toolkit
   → If team already knows Redux

3. None / React state only
   → For very small apps

>
```

### Step 7: Select ORM/Database (if applicable)

**For Go:**
```
Select your database approach:

1. GORM (Recommended - most popular Go ORM)
2. sqlc (type-safe SQL generation)
3. ent (entity framework by Facebook)
4. Raw SQL (database/sql)
5. No database

>
```

**For Python + FastAPI:**
```
Select your database approach:

1. SQLAlchemy (Recommended for FastAPI)
2. Tortoise ORM (async-first)
3. SQLModel (by FastAPI creator)
4. Raw SQL
5. No database

>
```

**For Python + Django:**
```
Select your database approach:

1. Django ORM (Recommended - built-in)
2. No database

>
```

**For TypeScript + NestJS:**
```
Select your database approach:

1. TypeORM (Recommended for NestJS)
2. Prisma
3. MikroORM
4. Drizzle
5. No database

>
```

**For TypeScript + Express:**
```
Select your database approach:

1. Prisma (Recommended - modern, type-safe)
2. TypeORM
3. Drizzle
4. Knex.js
5. No database

>
```

**For TypeScript + React Native:**
```
How will the app talk to a backend?

1. Convex (Recommended for greenfield - reactive, typed, no ORM)
   → schema.ts + query/mutation/action; useQuery on client

2. REST + TanStack Query
   → Standard HTTP, fetch wrapper, Zod for response validation

3. GraphQL + TanStack Query / urql / Apollo
   → Typed schema via codegen

4. Standalone / on-device only
   → No remote backend

>
```

```
Auth provider?

1. WorkOS AuthKit (Recommended)
   → SSO, MFA, AuthKit SDK
2. Clerk
   → Pre-built UI components, good Expo integration
3. Supabase Auth
   → If using Supabase elsewhere
4. Custom (JWT + secure-store)
   → Manual implementation
5. None

>
```

```
Observability (optional)?

[ ] Sentry React Native (crashes, performance)
[ ] PostHog React Native (analytics, feature flags)
[ ] None

>
```

### Step 8: Additional Options

```
Select additional patterns to include (comma-separated, or 'none'):

1. Microservices-ready boundaries
2. Event-driven patterns
3. API versioning
4. Authentication/Authorization patterns
5. Background jobs/workers
6. Caching patterns

> 1, 4
```

### Step 9: Confirm Selections

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GUIDELINES CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Guidelines:   backend-guidelines [Auto/Manual]
Mode:         NEW PROJECT
Language:     Go
Framework:    Gin
Architecture: Clean Architecture (Recommended)
Database:     GORM
Additional:   Microservices-ready, Auth patterns

Modules to include:
✓ general-principles (always)
✓ clean-architecture
✓ gin
✓ gorm
✓ microservices-ready
✓ auth-patterns

Generate guidelines with these settings? (yes/no/modify)
>
```

### Step 10: Generate Guidelines

Since there's no code to analyze, generation uses:

1. **General principles module** - All 41 universal principles
2. **Selected architecture module** - Best practices and patterns
3. **Framework module** - Conventions and idioms
4. **Additional modules** - Selected optional patterns

**Output structure:**
```
.claude/skills/{{SKILL_NAME}}/  # frontend-guidelines, backend-guidelines, or dev-guidelines
├── SKILL.md                    # Main skill file
├── reference/
│   ├── general-principles.md   # DRY, SOLID, Clean Code, etc.
│   ├── architecture.md         # Selected architecture patterns
│   ├── framework.md            # Framework conventions
│   ├── database.md             # ORM patterns
│   └── additional/
│       ├── microservices.md
│       └── auth.md
├── examples/
│   ├── entity-example.md       # Template examples (not extracted)
│   ├── handler-example.md
│   └── repository-example.md
├── checklists/
│   ├── code-review.md
│   ├── pr-checklist.md
│   └── security-checklist.md
├── templates/                  # Starter templates
│   ├── entity.template.go
│   ├── repository.template.go
│   ├── handler.template.go
│   └── service.template.go
└── decisions.md                # Empty, for future decisions
```

### Step 11: Offer Starter Templates

```
Guidelines generated successfully!

Would you like me to also create starter code templates?

This will create example files showing the patterns:
- internal/domain/example/entity.go
- internal/domain/example/repository.go
- internal/application/example/handler.go
- internal/infrastructure/example/repository_impl.go

Create starter templates? (yes/no)
>
```

## Framework → Architecture Recommendations Summary

| Framework | Recommended Architecture | Reason |
|-----------|-------------------------|--------|
| **Go: Gin/Echo/Fiber/Chi** | Clean Architecture | Go idioms favor explicit dependencies |
| **Python: FastAPI** | Layered/MVC | Simple, async-friendly |
| **Python: Django** | Django MTV | Built into framework |
| **Python: Flask** | Simple/Flat | Flask is micro-framework |
| **TS: NestJS** | Modular Layered | NestJS default pattern |
| **TS: Express** | Layered/MVC | Most common pattern |
| **TS: Next.js** | App Router Convention | Next.js 13+ default |
| **TS: Hono** | Simple/Flat | Edge/lightweight focus |
| **TS: React Native + Expo** | Expo Router (file-based) | Expo's default; matches Next.js mental model |
| **TS: React Native (bare)** | React Navigation + feature folders | When ejected or needs custom native |

## React Native Default Module Bundle

For a new RN + Expo project, the default recommended modules:

```
✓ general-principles
✓ typescript-conventions
✓ react-native-components
✓ expo-router (if routing chosen)
✓ expo-conventions
✓ rn-storage-crypto      (assumes MMKV + secure-store for token + prefs)
✓ {tamagui-styling | nativewind-styling}    (mutually exclusive; skip if StyleSheet-only)
✓ zustand                (if state management chosen)
✓ zod-validation         (always include — RHF+Zod is the RN default for forms)
✓ convex                 (if backend=Convex)
```

## Differences from Existing Project Mode

| Aspect | Existing Project | New Project |
|--------|------------------|-------------|
| Detection | Automatic | User selects |
| Pattern extraction | From code | From templates |
| Inconsistencies | Analyzed | None |
| Examples | Real code | Template examples |
| Decisions | User resolves | Pre-configured |
| Remediation | Offered | Not applicable |
| Starter templates | No | Offered |

## Template Sources

For new projects, examples come from module template sections:

1. **Architecture templates** - From `modules/*/architecture.md`
2. **Framework templates** - From `modules/*/framework.md`
3. **Best practice examples** - From `modules/shared/general-principles.module.md`

These are "ideal" examples rather than "extracted" examples.
