---
module: tailwind-styling
language: typescript
category: styling
requires: []
conflicts: [styled-components, emotion, css-modules, nativewind-styling, tamagui-styling]
---

# Tailwind CSS Module

## Detection

```bash
grep "\"tailwindcss\":" package.json
find . -name "tailwind.config.*" -type f
grep -rn "cn(" --include="*.tsx" | wc -l
```

## Pattern Extraction Commands

```bash
# cn() utility location
grep -rn "export function cn" lib/utils.ts src/lib/utils.ts

# CVA usage
grep -rn "const.*Variants = cva(" --include="*.tsx" | head -5

# Violations: inline styles
grep -rn "style={{" --include="*.tsx" | wc -l

# Violations: template literal className
grep -rn 'className={\`' --include="*.tsx" | head -5

# CSS variable format check
grep -rn "--.*:" app/globals.css | grep -E "#[0-9a-fA-F]" | head -5
```

## Standards

| Pattern | Standard |
|---------|----------|
| Class merging | `cn()` from clsx + tailwind-merge |
| Variants | CVA (class-variance-authority) |
| Colors | Semantic (bg-primary, not bg-blue-500) |
| CSS vars | RGB format for alpha support |
| Responsive | Mobile-first (sm:, md:, lg:) |

## Non-Obvious Anti-Patterns

```tsx
// Tailwind classes not purged (large bundle)
// tailwind.config.js
content: ['./src/**/*.{js,ts,jsx,tsx}']  // ❌ Missing app/ directory
content: ['./app/**/*.{js,ts,jsx,tsx}', './src/**/*.{js,ts,jsx,tsx}']  // ✅

// cn() order matters - later wins, but specificity can override
cn("p-4", "p-2")  // → "p-2" ✅ tailwind-merge handles this
cn("p-4", props.className)  // ✅ User can override
cn(props.className, "p-4")  // ❌ User's className gets overwritten

// Arbitrary values break design system
<div className="p-[13px] text-[#ff5733]">  // ❌ Magic values
<div className="p-3 text-destructive">  // ✅ Design tokens

// group-hover without group class
<div>  {/* ❌ Missing group class */}
  <span className="group-hover:text-primary">...</span>
</div>
<div className="group">  {/* ✅ */}
  <span className="group-hover:text-primary">...</span>
</div>

// CSS variable without fallback in inline style
style={{ color: `rgb(var(--color-missing))` }}  // ❌ Breaks if undefined
style={{ color: `rgb(var(--color-primary, 0 0 0))` }}  // ✅ Fallback

// Ring utilities stacking incorrectly
className="ring-2 ring-offset-2"  // Works
className="focus:ring-2 ring-offset-2"  // ❌ Offset always visible
className="focus:ring-2 focus:ring-offset-2"  // ✅ Both conditional
```

## cn() Utility Setup

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Usage
<div className={cn(
  "base-classes",
  condition && "conditional-class",
  props.className  // Always last for override
)} />
```

## CVA Template

```typescript
import { cva, type VariantProps } from "class-variance-authority"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        outline: "border border-input hover:bg-accent",
      },
      size: {
        default: "h-9 px-4",
        sm: "h-8 px-3 text-sm",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  }
)

interface ButtonProps extends VariantProps<typeof buttonVariants> {}
```

## Validation Checklist

- [ ] No `style={{}}` for layout/spacing (use Tailwind)
- [ ] No template literal className (`className={\`...\`}`)
- [ ] `cn()` puts `props.className` last for override
- [ ] No arbitrary values (`p-[13px]`) — use design tokens
- [ ] `group-hover:` has parent with `group` class
- [ ] CSS variables use RGB format (for alpha: `bg-primary/50`)

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/tailwind-config.md` — custom theme, plugins
- `reference/animation-patterns.md` — transitions, keyframes
