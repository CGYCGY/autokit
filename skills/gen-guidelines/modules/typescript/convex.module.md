---
module: convex
language: typescript
category: backend
requires: []
conflicts: [typeorm, prisma, mikroorm, drizzle]
---

# Convex Module

Convex is a reactive backend: schema + queries/mutations/actions defined in `convex/`, type-safe end-to-end, real-time subscriptions on the client. Replaces ORM + REST controllers. **If selected, `backend-principles` rules around controllers/services/repositories DO NOT APPLY** — see backend-principles "Convex Branch".

## Detection

```bash
grep "\"convex\":" package.json
find . -maxdepth 3 -type d -name "convex"
test -f convex/schema.ts && echo "convex schema exists"
grep -rn "defineSchema\|defineTable\|v\\." convex/ --include="*.ts" 2>/dev/null | head -10
```

## Pattern Extraction Commands

```bash
# Schema audit
test -f convex/schema.ts && cat convex/schema.ts | head -50
grep -rn "defineTable" convex/ --include="*.ts"
grep -rn "\.index(" convex/ --include="*.ts"

# Function classification
echo "Queries:"; grep -rn "= query(" convex/ --include="*.ts" | wc -l
echo "Mutations:"; grep -rn "= mutation(" convex/ --include="*.ts" | wc -l
echo "Actions:"; grep -rn "= action(" convex/ --include="*.ts" | wc -l
echo "Internal:"; grep -rn "internalQuery\|internalMutation\|internalAction" convex/ --include="*.ts" | wc -l

# Validators (input/output safety)
grep -rn "args: {" convex/ --include="*.ts" | wc -l
grep -rn "returns:" convex/ --include="*.ts" | wc -l   # explicit return validators

# Client consumption
grep -rn "useQuery\|useMutation\|useAction\|usePaginatedQuery" --include="*.tsx" | head -10
grep -rn "useQuery(.*skip" --include="*.tsx"  # conditional skip pattern

# Auth
test -f convex/auth.config.ts && echo "convex auth configured"
grep -rn "ctx\.auth" convex/ --include="*.ts"
```

## File Layout

```
convex/
├── _generated/             # auto-generated — do not edit
├── schema.ts               # defineSchema + defineTable + indices
├── auth.config.ts          # auth provider config (Clerk/WorkOS/etc.)
├── http.ts                 # HTTP endpoints (webhooks)
├── crons.ts                # scheduled jobs
├── <feature>.ts            # public query/mutation/action per feature
└── <feature>Helpers.ts     # internal helpers (internalQuery/Mutation)
```

## Standards

| Pattern | Standard |
|---------|----------|
| Read from DB | `query` (reactive, cached, no side effects) |
| Write to DB | `mutation` (transactional, no external I/O) |
| External API / fetch | `action` (no direct `ctx.db` — call mutations) |
| Input validation | `args: { x: v.string() }` always — never destructure unchecked |
| Return validation | `returns:` on public functions (catches schema drift) |
| Foreign keys | `v.id("tableName")` — never `v.string()` |
| Filtered queries | Define `.index(...)` and use `.withIndex(...)` |
| Auth | `await ctx.auth.getUserIdentity()` — throw on null |
| Conditional fetch | `useQuery(api.x.y, condition ? args : "skip")` |
| Internal-only fns | `internalQuery`/`internalMutation`/`internalAction` |

## Non-Obvious Anti-Patterns

```ts
// External fetch inside mutation (mutations must be deterministic + transactional)
export const send = mutation({
  args: { msg: v.string() },
  handler: async (ctx, { msg }) => {
    await fetch('https://api.example.com', { ... })  // ❌ Breaks transactionality
    await ctx.db.insert('messages', { msg })
  },
})
// Fix: action calls mutation
export const send = action({
  args: { msg: v.string() },
  handler: async (ctx, { msg }) => {
    await fetch('https://api.example.com', { ... })  // ✅ Allowed in action
    await ctx.runMutation(api.messages.insert, { msg })
  },
})

// Full table scan via .filter (no index)
const users = await ctx.db.query('users')
  .filter(q => q.eq(q.field('email'), email))  // ❌ Scans every row
  .first()
// Fix: define index + withIndex
// schema.ts: .index('by_email', ['email'])
const user = await ctx.db.query('users')
  .withIndex('by_email', q => q.eq('email', email))  // ✅
  .first()

// Storing foreign key as string (loses type safety + cascade hints)
defineTable({
  userId: v.string(),  // ❌
})
defineTable({
  userId: v.id('users'),  // ✅ Typed, doc-aware
})

// useQuery with conditional args (calls hook conditionally → React error)
const data = condition ? useQuery(api.x.y, args) : null  // ❌ Conditional hook
const data = useQuery(api.x.y, condition ? args : 'skip')  // ✅

// Pagination with .take(N) instead of usePaginatedQuery (no cursor)
const items = await ctx.db.query('items').take(20)  // ❌ No cursor on client
// Fix: usePaginatedQuery + paginationOpts
const items = await ctx.db.query('items').paginate(paginationOpts)  // ✅

// auth.getUserIdentity() without null check (returns null when logged out)
const id = await ctx.auth.getUserIdentity()
return ctx.db.query('private').filter(q => q.eq('subject', id.subject))  // ❌ Crashes anon
// Fix: explicit guard
const id = await ctx.auth.getUserIdentity()
if (!id) throw new Error('unauthorized')  // ✅

// Mutating data in a query (queries are read-only — fails silently or errors)
export const list = query({
  handler: async (ctx) => {
    await ctx.db.insert('audit', { ts: Date.now() })  // ❌ Not allowed
    return ctx.db.query('items').collect()
  },
})

// Returning Date objects (not serializable across the wire)
return { createdAt: new Date() }  // ❌
return { createdAt: Date.now() }  // ✅ number

// Re-deriving data on every query call (slow + non-reactive cache misses)
export const enriched = query(async (ctx) => {
  const items = await ctx.db.query('items').collect()
  return items.map(i => ({ ...i, computed: expensive(i) }))  // ⚠ Re-runs each call
})
// Fix: store derived on write, or use indices to filter
```

## Schema Template

```ts
// convex/schema.ts
import { defineSchema, defineTable } from 'convex/server'
import { v } from 'convex/values'

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    role: v.union(v.literal('admin'), v.literal('member')),
  })
    .index('by_email', ['email']),

  posts: defineTable({
    authorId: v.id('users'),
    title: v.string(),
    body: v.string(),
    publishedAt: v.optional(v.number()),
  })
    .index('by_author', ['authorId'])
    .index('by_published', ['publishedAt']),
})
```

## Function Templates

```ts
// convex/posts.ts
import { v } from 'convex/values'
import { query, mutation, action } from './_generated/server'
import { api } from './_generated/api'

export const listByAuthor = query({
  args: { authorId: v.id('users') },
  returns: v.array(v.object({
    _id: v.id('posts'),
    title: v.string(),
    publishedAt: v.optional(v.number()),
  })),
  handler: async (ctx, { authorId }) => {
    return ctx.db
      .query('posts')
      .withIndex('by_author', q => q.eq('authorId', authorId))
      .collect()
  },
})

export const create = mutation({
  args: { title: v.string(), body: v.string() },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity()
    if (!identity) throw new Error('unauthorized')
    const user = await ctx.db
      .query('users')
      .withIndex('by_email', q => q.eq('email', identity.email!))
      .first()
    if (!user) throw new Error('user not found')
    return ctx.db.insert('posts', { authorId: user._id, ...args })
  },
})

export const publishAndNotify = action({
  args: { postId: v.id('posts') },
  handler: async (ctx, { postId }) => {
    await ctx.runMutation(api.posts.markPublished, { postId })
    await fetch('https://hooks.example.com/notify', {
      method: 'POST',
      body: JSON.stringify({ postId }),
    })
  },
})
```

## Client Consumption

```tsx
import { useQuery, useMutation } from 'convex/react'
import { api } from '@/convex/_generated/api'

export function PostList({ authorId }: { authorId: Id<'users'> }) {
  const posts = useQuery(api.posts.listByAuthor, { authorId })
  const create = useMutation(api.posts.create)

  if (posts === undefined) return <Loading />  // initial load
  return <List items={posts} />
}
```

## Validation Checklist

- [ ] All public functions declare `args:` validators
- [ ] Public queries/mutations declare `returns:` validators
- [ ] Foreign keys typed as `v.id('table')`, not `v.string()`
- [ ] Filtered queries use `.withIndex(...)`, not `.filter(...)` on unindexed fields
- [ ] No external I/O (`fetch`, third-party SDK) in mutation/query — only in actions
- [ ] No mutations in query handlers
- [ ] `ctx.auth.getUserIdentity()` null-checked
- [ ] No `Date` objects on the wire (use `Date.now()` numbers)
- [ ] Conditional queries use `"skip"`, never wrap `useQuery` in `if`
- [ ] Pagination via `usePaginatedQuery`, not `.take(N)`

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/convex-auth.md` — WorkOS/Clerk integration, ctx.auth, JWT
- `reference/convex-files.md` — `ctx.storage`, signed URLs, uploads
- `reference/convex-scheduler.md` — `ctx.scheduler`, crons.ts, retries
- `reference/convex-http.md` — http.ts, webhooks, raw HTTP
