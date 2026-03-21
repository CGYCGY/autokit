---
module: nextjs-app-router
language: typescript
category: framework
requires: [react-components]
conflicts: [express, hono, nestjs]
---

# Next.js App Router Module

## Detection

```bash
grep "\"next\":" package.json
find . -type d -name "app" | head -1
find app/ -name "layout.tsx" -o -name "page.tsx" 2>/dev/null | head -5
```

## Pattern Extraction Commands

```bash
# Server vs client component ratio
echo "Server:"; find app/ -name "*.tsx" -exec grep -L "use client" {} \; 2>/dev/null | wc -l
echo "Client:"; grep -rl "\"use client\"" app/ --include="*.tsx" 2>/dev/null | wc -l

# Violations: layout with "use client"
find app/ -name "layout.tsx" -exec grep -l "use client" {} \;

# Violations: metadata in client component
for f in $(grep -rl "use client" app/ --include="*.tsx"); do
  grep -l "export const metadata\|export async function generateMetadata" "$f" 2>/dev/null
done

# API route methods
grep -rn "export async function \(GET\|POST\|PUT\|DELETE\)" app/api/ --include="route.ts"

# Special files coverage
find app/ -name "loading.tsx" -o -name "error.tsx" -o -name "not-found.tsx" 2>/dev/null
```

## Standards

| File | Must Be | Notes |
|------|---------|-------|
| `layout.tsx` | Server | Never `"use client"` |
| `page.tsx` | Either | `"use client"` only if hooks needed |
| `error.tsx` | Client | Requires `"use client"` |
| `loading.tsx` | Server | No interactivity |
| `route.ts` | Server | Named exports (GET, POST) |

## Non-Obvious Anti-Patterns

```typescript
// Passing server-only data to client component
// app/page.tsx (server)
export default async function Page() {
  const secret = process.env.API_SECRET  // ❌ Will be undefined in client
  return <ClientComponent secret={secret} />
}
// Fix: Fetch in server, pass only safe data

// useSearchParams without Suspense (causes full-page CSR)
"use client"
export default function Page() {
  const params = useSearchParams()  // ❌ Opts entire page out of static
}
// Fix: Wrap in Suspense or move to child component
export default function Page() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <SearchParamsConsumer />  {/* ✅ Only this part is CSR */}
    </Suspense>
  )
}

// Fetching same data in layout and page (waterfalls)
// app/[id]/layout.tsx
export default async function Layout({ params }) {
  const data = await fetchData(params.id)  // ❌ Fetch #1
  return <div>{children}</div>
}
// app/[id]/page.tsx
export default async function Page({ params }) {
  const data = await fetchData(params.id)  // ❌ Fetch #2 (duplicate)
}
// Fix: Fetch in layout, pass via context, or use React cache()

// cookies()/headers() in cached route
export const revalidate = 3600
export default async function Page() {
  const cookie = cookies().get('session')  // ❌ Forces dynamic, ignores revalidate
}
// Fix: Either remove revalidate OR don't use dynamic functions

// generateStaticParams without fallback consideration
export async function generateStaticParams() {
  return [{ id: '1' }, { id: '2' }]  // Only these are pre-rendered
}
// New IDs hit 404 unless dynamicParams = true (default)
```

## API Route Template

```typescript
// app/api/items/route.ts
import { NextResponse } from "next/server"

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const id = searchParams.get('id')
  return NextResponse.json({ data })
}

export async function POST(request: Request) {
  const body = await request.json()
  return NextResponse.json({ success: true }, { status: 201 })
}
```

## Validation Checklist

- [ ] No `"use client"` in layout.tsx files
- [ ] No `export const metadata` in client components
- [ ] `useSearchParams` wrapped in Suspense
- [ ] No duplicate fetches between layout and page
- [ ] `cookies()`/`headers()` not mixed with static revalidate
- [ ] `error.tsx` has `"use client"` directive

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/nextjs-caching.md` — revalidate, cache(), unstable_cache
- `reference/nextjs-middleware.md` — auth, redirects, rewrites
- `reference/nextjs-server-actions.md` — form handling, mutations
