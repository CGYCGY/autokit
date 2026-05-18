---
module: tamagui-styling
language: typescript
category: styling
requires: []
conflicts: [tailwind-styling, nativewind-styling, styled-components, emotion]
---

# Tamagui Styling Module

Compiled style-props + theme tokens for RN + web. Replaces StyleSheet for component-level styling.

## Detection

```bash
grep "\"@tamagui/core\"\|\"tamagui\":" package.json
find . -name "tamagui.config.*" -type f
grep -rn "createTamagui\|from ['\"]tamagui['\"]" --include="*.ts" --include="*.tsx" | head -5
```

## Pattern Extraction Commands

```bash
# styled() usage
grep -rn "styled(" --include="*.tsx" | grep -v node_modules

# Token usage rate (good signal of design-system adherence)
echo "Token refs ($color/$space/$size/$fontSize):"; grep -rEn "\\\$(color|space|size|radius|fontSize|lineHeight)" --include="*.tsx" | wc -l
echo "Raw hex/rgb:"; grep -rEn '#[0-9a-fA-F]{3,8}|rgba?\(' --include="*.tsx" | wc -l

# Variants
grep -rn "variants:" --include="*.tsx" | head -5

# Theme hook
grep -rn "useTheme\|useThemeName\|useMedia" --include="*.tsx"

# StyleSheet leakage (anti-pattern in Tamagui project)
grep -rn "StyleSheet\.create" --include="*.tsx" | grep -v node_modules
```

## Standards

| Pattern | Standard |
|---------|----------|
| Component styling | Tamagui style props (`<Stack p="$3" bg="$background">`) |
| Reusable styled | `styled(Stack, { name: 'Card', ... })` |
| Variants | `variants: { size: { small: {...}, large: {...} } }` |
| Colors | `$color`, `$background`, `$borderColor` — never raw hex |
| Spacing | `$space.3` / `p="$3"` — never raw px |
| Responsive | `$sm`, `$md` media tokens via `useMedia()` or `$gtSm` props |
| Theme | Single top-level `Theme` — avoid per-component `<Theme name>` wrappers |

## Non-Obvious Anti-Patterns

```tsx
// Inline style prop with raw values (defeats compiler optimization)
<Stack style={{ padding: 12, backgroundColor: '#fff' }}>  // ❌ Not optimized
<Stack p="$3" bg="$background">  // ✅ Compiled, themed

// StyleSheet.create alongside Tamagui (two sources of truth)
const styles = StyleSheet.create({ box: { padding: 12 } })  // ❌
<Stack style={styles.box} />
// Fix: use Tamagui props end-to-end

// Raw colors break dark mode
<Text color="#000">Hello</Text>  // ❌ Same in dark + light
<Text color="$color">Hello</Text>  // ✅ Theme-aware

// Per-screen Theme wrapping (re-mounts theme context)
export default function Screen() {
  return <Theme name="dark"><Body /></Theme>  // ❌ Re-creates theme tree
}
// Fix: set theme at root or via useThemeName toggle

// Conditional styles via ternary (loses static analysis)
<Stack p={isActive ? '$4' : '$2'}>  // ⚠ Works but unoptimized
// Fix: use variants
const Box = styled(Stack, {
  variants: { active: { true: { p: '$4' }, false: { p: '$2' } } }
})
<Box active={isActive} />  // ✅ Compiler can inline

// Missing `name` on styled() (breaks theme overrides + devtools)
const Card = styled(Stack, { p: '$3' })  // ❌
const Card = styled(Stack, { name: 'Card', p: '$3' })  // ✅

// useMedia inside a worklet (hooks can't run on UI thread)
const animatedStyle = useAnimatedStyle(() => {
  const media = useMedia()  // ❌ Hook in worklet
})
```

## styled() Template

```tsx
import { Stack, Text, styled } from 'tamagui'

export const Card = styled(Stack, {
  name: 'Card',
  bg: '$background',
  br: '$4',
  p: '$3',
  variants: {
    elevated: {
      true: { shadowColor: '$shadowColor', shadowRadius: 8, elevation: 4 },
    },
    size: {
      sm: { p: '$2' },
      md: { p: '$3' },
      lg: { p: '$4' },
    },
  } as const,
  defaultVariants: { size: 'md' },
})

export const CardTitle = styled(Text, {
  name: 'CardTitle',
  fontSize: '$5',
  fontWeight: '600',
  color: '$color',
})
```

## Config Anchor

```ts
// tamagui.config.ts
import { createTamagui } from 'tamagui'
import { config as base } from '@tamagui/config/v4'

export const config = createTamagui({
  ...base,
  // tokens, themes, fonts...
})

export default config
declare module 'tamagui' {
  interface TamaguiCustomConfig extends typeof config {}
}
```

## Validation Checklist

- [ ] No raw hex / rgba in component code — all colors via `$` tokens
- [ ] No `style={{}}` on Tamagui components (use props)
- [ ] No `StyleSheet.create` (single styling source)
- [ ] All `styled()` calls have a `name`
- [ ] Conditional styling via `variants`, not ternaries
- [ ] Theme set at root, not per-screen
- [ ] Spacing via `$space` tokens — no raw px

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/tamagui-config.md` — tokens, themes, fonts customization
- `reference/tamagui-compiler.md` — babel/metro setup, optimizing builds
- `reference/tamagui-animations.md` — animations, presence, layout transitions
