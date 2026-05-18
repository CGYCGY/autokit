---
module: nativewind-styling
language: typescript
category: styling
requires: []
conflicts: [tamagui-styling, styled-components, emotion]
---

# NativeWind Styling Module

Tailwind CSS for React Native. `className` on RN primitives compiles to RN styles. Coexists with web Tailwind in a monorepo (use `tailwind-styling` for web packages).

## Detection

```bash
grep "\"nativewind\":" package.json
find . -name "tailwind.config.*" -type f
find . -name "global.css" -o -name "globals.css" 2>/dev/null
grep -rn "className=" --include="*.tsx" | grep -v "node_modules" | head -5
```

## Pattern Extraction Commands

```bash
# className adoption
echo "className usage:"; grep -rn "className=" --include="*.tsx" | wc -l
echo "StyleSheet leakage:"; grep -rn "StyleSheet\.create" --include="*.tsx" | grep -v node_modules | wc -l

# cn() utility
grep -rn "export function cn\|export const cn" --include="*.ts"
grep -rn "from ['\"]clsx['\"]\|tailwind-merge" --include="*.ts" --include="*.tsx"

# Platform-aware utilities
grep -rn "ios:\|android:\|web:\|native:" --include="*.tsx" | head -10

# Color tokens vs raw
grep -rEn "bg-\[#" --include="*.tsx"  # arbitrary colors = anti-pattern
```

## Standards

| Pattern | Standard |
|---------|----------|
| Touch primitives | `className` on `View`/`Text`/`Pressable` |
| Class merging | `cn()` (clsx + tailwind-merge) |
| Platform branch | `ios:p-4 android:p-2 web:p-6` prefixes |
| Colors | Semantic from `tailwind.config` (`bg-primary`) |
| Responsive | Width breakpoints (`sm:`/`md:`) — limited utility on mobile |
| Variants | CVA, same as web |

## Differences From Web Tailwind

| Web | RN / NativeWind |
|-----|----------------|
| `hover:` | Compiles, but no useful effect on touch (no hover events) — use `active:` for press feedback |
| `group-hover:` | Same — use `group active:` |
| `dark:` | Works via `appearance` / `useColorScheme()` |
| Arbitrary CSS (`[mask-image:...]`) | Not supported (no CSS engine) |
| `aspect-square` | Works (RN supports `aspectRatio`) |
| `grid` | No support — use Flex |
| `transition-colors` | Limited — use Reanimated for complex |

## Non-Obvious Anti-Patterns

```tsx
// `hover:` compiles but has no useful effect on touch (touch devices have no hover state)
<Pressable className="bg-blue-500 hover:bg-blue-600">  // ❌ Class exists, never matches on touch
<Pressable className="bg-blue-500 active:bg-blue-600">  // ✅ Press feedback

// Arbitrary values that don't translate (no CSS engine)
<View className="bg-[radial-gradient(...)]">  // ❌ Silently dropped
// Use expo-linear-gradient or RN SVG instead

// className without cn() merge — later wins by literal order, not specificity
<View className={`p-4 ${props.className}`} />  // ❌ Can't override `p-4`
<View className={cn('p-4', props.className)} />  // ✅ tailwind-merge resolves

// StyleSheet.create alongside (two styling systems)
const styles = StyleSheet.create({ box: { padding: 16 } })  // ❌
<View style={styles.box} className="bg-white" />
// Fix: pick one — NativeWind for new code

// Sharing components between web and RN (className semantics drift)
// packages/ui/Button.tsx → used in both web + RN
<button className="px-4 py-2 hover:bg-blue-600">  // ❌ hover works on web, dead on RN
// Fix: platform-specific files or split components

// `space-x-*` / `space-y-*` (broken on RN — uses negative margins)
<View className="flex-row space-x-2">  // ⚠ Inconsistent
// Fix: `gap-2` (supported on RN 0.71+)

// Raw hex bypasses theme
<View className="bg-[#3b82f6]">  // ❌ No design system
<View className="bg-primary">  // ✅
```

## cn() Utility Setup

```ts
// lib/utils.ts (same as web — NativeWind keeps the contract)
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

## Component Template

```tsx
import { Pressable, Text, View } from 'react-native'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const buttonVariants = cva(
  'rounded-md items-center justify-center',
  {
    variants: {
      variant: {
        primary: 'bg-primary active:bg-primary/90',
        outline: 'border border-border active:bg-accent',
      },
      size: { sm: 'px-3 py-2', md: 'px-4 py-3' },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  }
)

interface ButtonProps extends VariantProps<typeof buttonVariants> {
  className?: string
  label: string
  onPress?: () => void
}

export function Button({ className, variant, size, label, onPress }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      className={cn(buttonVariants({ variant, size }), className)}
    >
      <Text className="text-primary-foreground font-medium">{label}</Text>
    </Pressable>
  )
}
```

## Validation Checklist

- [ ] No `hover:`/`group-hover:` on touch primitives — use `active:`
- [ ] No arbitrary CSS (`[mask-image:...]`, gradients via class) — use proper RN libs
- [ ] `cn()` puts `props.className` last for override
- [ ] No `StyleSheet.create` alongside NativeWind
- [ ] `gap-*` over `space-*` for flex spacing (RN 0.71+)
- [ ] All colors via semantic tokens — no `bg-[#...]`
- [ ] Cross-platform components handle `hover` vs `active` divergence

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/nativewind-config.md` — tailwind.config for RN-specific tokens
- `reference/nativewind-platform.md` — `ios:`/`android:`/`web:` patterns
