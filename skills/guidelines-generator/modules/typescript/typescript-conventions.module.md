---
module: typescript-conventions
language: typescript
category: language
requires: []
conflicts: []
priority: highest
---

# TypeScript Conventions Module

## Detection

```bash
find . -name "tsconfig.json" -type f
find . -name "*.ts" -o -name "*.tsx" | head -5
```

## Tooling Commands

**Detect project linters:**
```bash
# Check package.json for linting scripts
grep -E "\"(lint|typecheck|tsc|eslint)\":" package.json

# Check for ESLint config
ls -la .eslintrc* eslint.config.* 2>/dev/null

# Check for TypeScript config
cat tsconfig.json | grep -E "strict|noImplicitAny"
```

**Run after implementation:**
```bash
# TypeScript type checking
npm run typecheck           # or: npx tsc --noEmit
# or: yarn typecheck
# or: pnpm typecheck

# ESLint
npm run lint               # or: npx eslint . --ext .ts,.tsx
# or: yarn lint
# or: pnpm lint

# Fix auto-fixable issues
npm run lint:fix           # or: npx eslint . --fix
```

**Common patterns from package.json:**
```json
{
  "scripts": {
    "typecheck": "tsc --noEmit",
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix"
  }
}
```

## Pattern Extraction Commands

```bash
# Type vs interface ratio
echo "Interfaces:"; grep -rn "^export interface" --include="*.ts" | wc -l
echo "Type objects:"; grep -rn "^export type.*= {" --include="*.ts" | wc -l

# Enum usage (violations)
grep -rn "^export enum\|^enum " --include="*.ts"

# Any usage (violations)
grep -rn ": any\|<any>" --include="*.ts" | grep -v node_modules | wc -l

# Import type usage
echo "Type imports:"; grep -rn "^import type" --include="*.ts" | wc -l
echo "Regular imports from types/:"; grep -rn "^import {" --include="*.ts" | grep "/types" | wc -l
```

## Standards

| Pattern | Standard |
|---------|----------|
| Object shapes | `interface` (extensible) |
| Unions/intersections | `type` |
| Enums | String literal unions |
| Type imports | `import type { }` |
| Unknown data | `unknown` not `any` |

## Non-Obvious Anti-Patterns

```typescript
// Type narrowing lost after assignment
function process(input: string | number) {
  if (typeof input === 'string') {
    let value = input  // ❌ value is string | number (widened)
    const value = input  // ✅ value is string (narrowed)
  }
}

// Object.keys returns string[], not keyof T
const obj: Record<'a' | 'b', number> = { a: 1, b: 2 }
Object.keys(obj).forEach(key => {
  obj[key]  // ❌ Error: string can't index Record<'a'|'b', number>
})
// Fix: Type assertion or use Object.entries
;(Object.keys(obj) as Array<keyof typeof obj>).forEach(key => obj[key])  // ✅

// Excess property check only on object literals
interface Config { name: string }
const config = { name: 'test', extra: true }
const c1: Config = config  // ✅ No error (indirect assignment)
const c2: Config = { name: 'test', extra: true }  // ❌ Error (literal)
// Gotcha: Runtime has extra prop, type says it doesn't

// Readonly doesn't deep freeze
interface State {
  readonly items: string[]
}
const state: State = { items: ['a'] }
state.items.push('b')  // ✅ No error - array is mutable!
// Fix: ReadonlyArray or Readonly<string[]>
interface State {
  readonly items: readonly string[]  // ✅ Can't push
}

// Discriminated union without exhaustive check
type Action = { type: 'add'; item: string } | { type: 'remove'; id: number }
function reducer(action: Action) {
  switch (action.type) {
    case 'add': return action.item
    // Missing 'remove' case - no error by default!
  }
}
// Fix: Add exhaustive check
function reducer(action: Action) {
  switch (action.type) {
    case 'add': return action.item
    case 'remove': return action.id
    default:
      const _exhaustive: never = action  // ❌ Error if case missing
      return _exhaustive
  }
}
```

## Naming Conventions

| Suffix | Use For | Example |
|--------|---------|---------|
| (none) | Domain entities | `Player`, `Order` |
| `Props` | Component props | `ButtonProps` |
| `State` | State shapes | `AppState` |
| `Config` | Configuration | `ApiConfig` |
| `Result` | Return types | `ValidationResult` |

## Validation Checklist

- [ ] No `any` (use `unknown` + type guards)
- [ ] No `enum` (use string literal unions)
- [ ] `import type` for type-only imports
- [ ] `const` for narrowed types, `let` widens
- [ ] `readonly` arrays use `readonly T[]` not `Readonly<T[]>`
- [ ] Discriminated unions have exhaustive switch
- [ ] **Run `npm run typecheck` (or `tsc --noEmit`) and fix ALL type errors**
- [ ] **Run `npm run lint` and fix ALL ESLint errors**

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/utility-types.md` — Partial, Pick, Omit, Record patterns
- `reference/type-guards.md` — custom type predicates, assertion functions
