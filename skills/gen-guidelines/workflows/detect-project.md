# Project Detection Workflow

This workflow detects the project's language, framework, and architecture to determine which modules to apply.

## Step 0: Ask User Preference

```
Guidelines type?
1. Auto-detect (Recommended)
2. Frontend
3. Backend
4. Full-stack
5. Mobile (React Native)
```

**If 2/3/4/5:** Set variables below, skip to Step 5.

| Choice | SKILL_NAME | SKILL_TITLE | SKILL_SCOPE |
|--------|------------|-------------|-------------|
| 2 | frontend-guidelines | Frontend Development Guidelines | frontend |
| 3 | backend-guidelines | Backend Development Guidelines | backend |
| 4 | dev-guidelines | Development Guidelines | full-stack |
| 5 | mobile-guidelines | Mobile Development Guidelines | mobile |

**If 1:** Continue to Step 1.

---

## Step 1: Detect Language

### Go Detection
```bash
# Look for go.mod
find . -name "go.mod" -type f -not -path "*/vendor/*" -not -path "*/node_modules/*"
```

If found:
- Extract module name: `grep "^module" go.mod`
- Extract Go version: `grep "^go" go.mod`
- Set language: **Go**

### Python Detection
```bash
# Look for Python project files
find . -maxdepth 2 -type f \( -name "pyproject.toml" -o -name "requirements.txt" -o -name "setup.py" -o -name "Pipfile" \)
```

If found:
- Check for pyproject.toml (modern Python)
- Check requirements.txt dependencies
- Set language: **Python**

## Step 2: Detect Framework

### Go Frameworks

Search `go.mod` for framework dependencies:

```go
// Gin
github.com/gin-gonic/gin

// Echo
github.com/labstack/echo

// Fiber
github.com/gofiber/fiber

// Chi
github.com/go-chi/chi
```

**ORM Detection:**
```go
// GORM
gorm.io/gorm

// sqlc
github.com/kyleconroy/sqlc

// ent
entgo.io/ent
```

### Python Frameworks

Search `requirements.txt` or `pyproject.toml`:

```python
# FastAPI
fastapi

# Django
Django

# Flask
Flask

# SQLAlchemy
sqlalchemy

# Pydantic
pydantic
```

### TypeScript/JavaScript Frameworks

Search `package.json`:

```json
// Next.js
"next"

// React
"react"

// React Native (mobile)
"react-native"

// Expo (managed RN)
"expo"

// NestJS
"@nestjs/core"

// Express
"express"

// Vue
"vue"

// Svelte
"svelte"

// Hono
"hono"
```

**Mobile / React Native signals (any → mobile project):**
```bash
grep "\"react-native\":\|\"expo\":" package.json
find . -maxdepth 2 -name "app.json" -o -name "app.config.*" -o -name "metro.config.*"
find . -name "*.ios.tsx" -o -name "*.android.tsx" -o -name "*.native.tsx" 2>/dev/null | head -3
```

**Styling library (TypeScript):**
```bash
grep "\"tailwindcss\":" package.json    # tailwind-styling (web)
grep "\"nativewind\":" package.json     # nativewind-styling (RN)
grep "\"tamagui\":\|\"@tamagui/" package.json  # tamagui-styling (RN/web)
grep "\"styled-components\":" package.json
grep "\"@emotion/" package.json
```

**Backend / data layer (TypeScript):**
```bash
grep "\"convex\":" package.json && test -d convex && echo "Convex (replaces ORM)"
# Standard ORMs (mutually exclusive with Convex)
grep "\"prisma\"\|\"typeorm\"\|\"@mikro-orm\|\"drizzle-orm\"" package.json
```

**Observability (TypeScript / RN):**
```bash
grep "\"@sentry/react-native\":" package.json   # sentry-rn module
grep "\"@sentry/nextjs\":\|\"@sentry/node\":\|\"@sentry/browser\":" package.json   # web Sentry — no module yet
grep "\"posthog-react-native\":" package.json   # no module yet — flag in conventions
```

**Routing (TypeScript):**
```bash
grep "\"next\":" package.json           # Next.js App Router (web full-stack)
grep "\"expo-router\":" package.json    # Expo Router (RN file-based)
grep "\"react-router\":\|\"@tanstack/react-router\"" package.json  # client routing
```

**Tooling signals (inform conventions doc only — not module selection):**
```bash
test -f bun.lockb && echo "Bun"
test -f pnpm-lock.yaml && echo "pnpm"
test -f yarn.lock && echo "Yarn"
test -f package-lock.json && echo "npm"
test -f biome.json -o -f biome.jsonc && echo "Biome (replaces ESLint+Prettier)"
test -f .eslintrc.json -o -f .eslintrc.js -o -f eslint.config.js && echo "ESLint"
test -f .prettierrc -o -f .prettierrc.json && echo "Prettier"
test -f lefthook.yml -o -f .husky/ -d && echo "git hooks configured"
```

## Step 3: Determine Project Type

**Skip if user manually selected in Step 0.**

| Project Type | SKILL_NAME | Frameworks |
|--------------|------------|------------|
| Frontend | frontend-guidelines | React (no Next), Vue, Svelte, Angular |
| Mobile | mobile-guidelines | React Native (Expo or bare) |
| Backend | backend-guidelines | Go Gin/Echo/Fiber/Chi, FastAPI, Flask, Express, Hono, NestJS API-only |
| Full-stack | dev-guidelines | Next.js, NestJS with views, Django full MVC |

**Detection priority:**
1. `react-native` in package.json → mobile (overrides web React detection even if `react` is also present, since RN depends on React)
2. Next.js → full-stack
3. React/Vue/Svelte/Angular without backend → frontend
4. Go/Python/Express/Hono → backend
5. Both frontend + backend code → full-stack
6. Mobile + Convex/REST backend in same repo → mobile (Convex is "backend-as-config" — not a separate backend project)

## Step 4: Detect Architecture

### DDD/CQRS Indicators

**Folder structure:**
```
internal/domain/
internal/application/
internal/infrastructure/
internal/repository/
```

**Code patterns:**
```
# Search for DDD keywords
grep -r "aggregate\|valueobject\|DomainEvent\|Command\|Query" --include="*.go" --include="*.py"
```

### Layered Architecture Indicators

**Folder structure:**
```
models/
views/
controllers/
services/
repositories/
```

### Modular Monolith Indicators

**Multiple domain modules:**
```
internal/order/
internal/product/
internal/cart/
internal/user/
```

Each module has complete layering (domain, application, infrastructure).

### Clean Architecture Indicators

**Folder structure:**
```
entities/
use_cases/
adapters/
frameworks/
```

## Step 5: Module Selection

Based on detection results, build recommended module list:

### Database/ORM Detection (Auto-load seeder-data)

**If ORM detected, automatically include `seeder-data` module:**

```bash
# Go ORMs
grep -E "gorm.io/gorm|github.com/kyleconroy/sqlc|entgo.io/ent" go.mod

# Python ORMs
grep -E "sqlalchemy|Django|tortoise|sqlmodel" requirements.txt pyproject.toml

# TypeScript/JavaScript ORMs
grep -E "\"prisma\"|\"typeorm\"|\"@mikro-orm|\"drizzle-orm\"" package.json
```

**If any ORM found:** Add `seeder-data` to recommended modules list.

### Go Project Matrix

| Architecture | Recommended Modules |
|--------------|-------------------|
| DDD/CQRS | `ddd-cqrs`, `modular-monolith`, ORM module, framework module, `response-patterns`, `enum-patterns`, **`seeder-data`*** |
| Modular Monolith | `modular-monolith`, `microservices-ready`, ORM module, framework module, **`seeder-data`*** |
| Standard | Framework module, ORM module, `response-patterns`, **`seeder-data`*** |

### Python Project Matrix

| Framework | Architecture | Recommended Modules |
|-----------|-------------|-------------------|
| FastAPI | Layered | `fastapi`, `layered`, `pydantic`, ORM module, `response-patterns`, **`seeder-data`*** |
| FastAPI | Modular Monolith | `fastapi`, `modular-monolith`, `pydantic`, ORM module, **`seeder-data`*** |
| Django | Standard | `django`, ORM module, **`seeder-data`*** |
| Flask | Layered | `flask`, `layered`, ORM module, **`seeder-data`*** |

**\*Only if ORM detected**

### TypeScript Project Matrix

| Framework | Detected | Recommended Modules |
|-----------|----------|---------------------|
| Next.js (App Router) | `next` + `app/` | `nextjs-app-router`, `react-components`, `typescript-conventions`, styling module, validation module, ORM module, **`seeder-data`*** |
| NestJS | `@nestjs/core` | `nestjs`, `typescript-conventions`, `zod-validation` or `class-validator`, ORM module, **`seeder-data`*** |
| Express / Hono | `express` / `hono` | `typescript-conventions`, `zod-validation`, ORM module, **`seeder-data`*** |
| React Native (Expo) | `react-native` + `expo` | `react-native-components`, `expo-router` (if present), `expo-conventions`, styling module, `rn-storage-crypto`, `typescript-conventions`, state/validation modules, `convex` (if present), `sentry-rn` (if present) |
| React Native (bare) | `react-native`, no `expo` | `react-native-components`, `rn-storage-crypto`, `typescript-conventions`, state/validation modules, `sentry-rn` (if present) |

### Mobile / RN Module Selection Rules

When mobile detected:
- **Always:** `react-native-components`, `typescript-conventions`, `rn-storage-crypto` (if any storage lib present)
- **Routing:** `expo-router` if detected; otherwise none (React Navigation gets its own rules in a future module)
- **Styling:** ONE of `tamagui-styling` / `nativewind-styling` (mutually exclusive); none if only `StyleSheet`
- **Backend integration:** `convex` if `convex/` dir exists; otherwise standard validation/HTTP guidance
- **Forms:** `zod-validation` if `zod` + `react-hook-form` both present
- **State:** `zustand` if detected
- **Observability:** `sentry-rn` if `@sentry/react-native` detected
- **Auto-load:** `expo-conventions` whenever `expo` is present
- **Do NOT load:** `react-components` (web variant), `tailwind-styling` (web variant), `nextjs-app-router`

**\*Only if ORM detected**

## Step 6: User Confirmation

Present findings and recommendations:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT DETECTION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Guidelines: backend-guidelines [Auto/Manual]
Language: Go 1.21
Framework: Gin
ORM: GORM
Architecture: DDD/CQRS + Modular Monolith

Detected Modules:
• internal/order/
• internal/product/
• internal/cart/
• internal/user/

Recommended Pattern Modules:
✓ ddd-cqrs (architecture patterns)
✓ modular-monolith (module organization)
✓ gorm (ORM patterns)
✓ gin (web framework patterns)
✓ response-patterns (API responses)
✓ enum-patterns (constants/enums)
? microservices-ready (boundary enforcement)

Planning to migrate to microservices in the future? (y/n)

If yes, I'll add the microservices-ready module to enforce clean boundaries.

>
```

## Detection Utilities

### Scan Imports (Go)
```bash
# Find all imports in .go files
find . -name "*.go" -not -path "*/vendor/*" -exec grep -h "^\s*\"" {} \; | sort -u
```

### Scan Dependencies (Python)
```bash
# Parse requirements.txt
cat requirements.txt | grep -v "^#" | grep -v "^$"

# Parse pyproject.toml
grep -A 20 "\[tool.poetry.dependencies\]" pyproject.toml
```

### Folder Structure Analysis
```bash
# List top-level directories under src/internal/app
find . -maxdepth 3 -type d | sort
```

## Output

Return detection results as structured data:

```json
{
  "language": "go",
  "languageVersion": "1.21",
  "framework": "gin",
  "orm": "gorm",
  "architecture": "ddd-cqrs-modular",
  "modules": ["order", "product", "cart", "user"],
  "recommendedModules": [
    "ddd-cqrs",
    "modular-monolith",
    "gorm",
    "gin",
    "response-patterns",
    "enum-patterns"
  ],
  "optionalModules": ["microservices-ready"]
}
```

This data drives the next phase: pattern extraction.
