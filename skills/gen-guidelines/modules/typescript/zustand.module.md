---
module: zustand
language: typescript
category: state
requires: [react-components]
conflicts: [redux, mobx, jotai]
---

# Zustand Module

## Detection

```bash
grep "\"zustand\":" package.json
grep -rn "create<.*>()" --include="*.ts"
```

## Pattern Extraction Commands

```bash
# Store structure
grep -rn "export const use.*Store = create" --include="*.ts"
grep -A20 "create<.*>()" --include="*.ts" | head -30

# Mutation detection (violations)
grep -rn "\.push(\|\.pop(\|\.splice(" --include="*.ts" | grep -v node_modules

# Deep clone method
grep -rn "structuredClone\|JSON\.parse(JSON\.stringify" --include="*.ts"

# Store consumption pattern
grep -rn "const.*=.*useStore()" --include="*.tsx" | head -10
```

## Standards

| Pattern | Standard |
|---------|----------|
| Store typing | `create<StateInterface>()` |
| Persistence | `persist()` middleware with version |
| Immutable updates | Spread/filter/map, never mutate |
| Deep clone | `structuredClone()` |
| Consumption | Selective destructuring |

## Non-Obvious Anti-Patterns

```typescript
// Stale closure in async action
generateSchedule: async () => {
  const { players } = get()  // ❌ Captured at call time
  await longOperation()
  set({ result: compute(players) })  // players may be stale
}
// Fix: get() again after async
generateSchedule: async () => {
  await longOperation()
  const { players } = get()  // ✅ Fresh state
  set({ result: compute(players) })
}

// Selector without shallow comparison (re-renders on every store update)
const items = useStore(state => state.items.filter(x => x.active))  // ❌ New array ref
// Fix: Use shallow or custom equality
import { shallow } from 'zustand/shallow'
const items = useStore(state => state.items.filter(x => x.active), shallow)  // ✅

// Derived state stored (redundant, sync issues)
interface State {
  items: Item[]
  itemCount: number  // ❌ Can derive from items.length
}
// Fix: Compute in component or use selector

// Multiple set() calls (multiple renders)
action: () => {
  set({ a: 1 })
  set({ b: 2 })  // ❌ Two renders
}
// Fix: Single atomic update
action: () => set({ a: 1, b: 2 })  // ✅ One render

// Shallow spread for nested update
set(state => ({ config: { ...state.config, nested: newValue } }))  // ❌ If nested is object
// Fix: Deep clone when modifying nested structures
set({ config: structuredClone(newConfig) })  // ✅
```

## React Native Persistence

On RN, swap the default localStorage backend for MMKV — sync, JSI-backed, no async bridge. See `rn-storage-crypto.module.md` for the full storage decision matrix and the `mmkvStorage` adapter snippet. **Never persist tokens via zustand+MMKV** — use `expo-secure-store` directly.

## Store Template

```typescript
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'

interface AppState {
  items: Item[]
  addItem: (item: Item) => void
  updateItem: (id: string, updates: Partial<Item>) => void
  removeItem: (id: string) => void
}

export const useStore = create<AppState>()(
  persist(
    (set, get) => ({
      items: [],
      addItem: (item) => set(s => ({ items: [...s.items, item] })),
      updateItem: (id, updates) => set(s => ({
        items: s.items.map(i => i.id === id ? { ...i, ...updates } : i)
      })),
      removeItem: (id) => set(s => ({ items: s.items.filter(i => i.id !== id) })),
    }),
    { name: 'app-storage', version: 1 }
  )
)
```

## Validation Checklist

- [ ] No direct mutations (push/pop/splice/assignment)
- [ ] Async actions re-fetch state with `get()` after await
- [ ] Selectors use `shallow` for derived arrays/objects
- [ ] No derived state stored (compute instead)
- [ ] Related updates batched in single `set()` call
- [ ] Nested updates use `structuredClone()`

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/zustand-middleware.md` — devtools, immer, subscribeWithSelector
- `reference/zustand-testing.md` — mocking stores in tests
