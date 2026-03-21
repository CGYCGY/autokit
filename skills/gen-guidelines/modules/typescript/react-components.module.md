---
module: react-components
language: typescript
category: framework
requires: [typescript-conventions]
conflicts: []
---

# React Components Module

## Detection

```bash
grep -rn "from ['\"]react['\"]" --include="*.tsx" | wc -l
grep "\"react\":" package.json
```

## Pattern Extraction Commands

```bash
# Component style ratio
echo "Named exports:"; grep -rn "^export function" --include="*.tsx" | wc -l
echo "Default exports:"; grep -rn "^export default" --include="*.tsx" | wc -l
echo "Arrow components:"; grep -rn "^export const.*=.*=>" --include="*.tsx" | wc -l

# forwardRef audit
echo "forwardRef without displayName:"
grep -l "forwardRef" --include="*.tsx" -r | xargs -I{} sh -c 'grep -L "displayName" {} 2>/dev/null'

# Missing "use client" with hooks (Next.js)
for f in $(grep -l "useState\|useEffect\|useCallback" --include="*.tsx" -r); do
  grep -q "use client" "$f" || echo "Missing 'use client': $f"
done

# Props pattern
grep -rn "interface.*Props\s*{" --include="*.tsx" | head -5
```

## Standards

| Pattern | Standard |
|---------|----------|
| Component declaration | Named function export |
| Props | Interface with `{ComponentName}Props` suffix |
| forwardRef | Explicit types + displayName |
| Client components | `"use client"` when using hooks |
| className merging | `cn()` utility |

## Non-Obvious Anti-Patterns

```typescript
// Stale closure in useEffect
useEffect(() => {
  const id = setInterval(() => {
    setCount(count + 1)  // ❌ Captures stale count
  }, 1000)
  return () => clearInterval(id)
}, [])  // Missing count dependency

// Fix: Use functional update
setCount(c => c + 1)  // ✅ Always current

// Object/array in dependency array
useEffect(() => { ... }, [{ id }])  // ❌ New object every render
useEffect(() => { ... }, [id])  // ✅ Primitive

// useMemo/useCallback without deps change
const handler = useCallback(() => doThing(value), [])  // ❌ Stale value
const handler = useCallback(() => doThing(value), [value])  // ✅

// Event handler recreated every render (perf issue in lists)
{items.map(item => (
  <Button onClick={() => handleClick(item.id)} />  // ❌ New fn each render
))}
// Fix: Memoize or use data attributes
<Button data-id={item.id} onClick={handleClick} />  // ✅
```

## forwardRef Template

```typescript
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, ...props }, ref) => (
    <button ref={ref} className={cn(buttonVariants({ variant }), className)} {...props} />
  )
)
Button.displayName = "Button"
export { Button }
```

## Validation Checklist

- [ ] No hooks without `"use client"` (Next.js App Router)
- [ ] No stale closures in useEffect/useCallback
- [ ] No objects/arrays as useEffect dependencies (use primitives or useMemo)
- [ ] forwardRef components have displayName
- [ ] Event handlers in lists are memoized or use data attributes

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/hooks-patterns.md` — custom hooks, useEffect patterns
- `reference/performance.md` — memoization, virtualization
- `reference/testing-components.md` — RTL patterns
