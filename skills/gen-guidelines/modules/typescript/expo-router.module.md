---
module: expo-router
language: typescript
category: framework
requires: [react-native-components]
conflicts: [nextjs-app-router]
---

# Expo Router Module

File-based routing for React Native via Expo. Conventionally parallel to Next.js App Router but with different special-file names and navigator-aware layouts.

## Detection

```bash
grep "\"expo-router\":" package.json
find app/ -name "_layout.tsx" -o -name "+not-found.tsx" 2>/dev/null | head -5
grep "scheme\|expo-router" app.json app.config.* 2>/dev/null
```

## Pattern Extraction Commands

```bash
# Route inventory
find app/ -name "*.tsx" 2>/dev/null | sort

# Layout types (Stack / Tabs / Drawer)
grep -rn "from ['\"]expo-router['\"]" app/ --include="_layout.tsx"
grep -rn "<Stack\|<Tabs\|<Drawer" app/ --include="_layout.tsx"

# Route groups (parentheses) vs dynamic ([id])
find app/ -type d -name "(*)" 2>/dev/null
find app/ -name "\[*\].tsx" 2>/dev/null

# Typed routes config
grep "typedRoutes" app.json app.config.* 2>/dev/null

# Search params consumption
grep -rn "useLocalSearchParams\|useGlobalSearchParams" --include="*.tsx"

# Navigation calls
grep -rn "router\.push\|router\.replace\|router\.back\|<Link " --include="*.tsx" | head -10
```

## File Conventions

| File / Folder | Role |
|---------------|------|
| `app/_layout.tsx` | Root layout (provider wrappers go here) |
| `app/index.tsx` | `/` route |
| `app/[id].tsx` | Dynamic segment (`/123`) |
| `app/[...rest].tsx` | Catch-all |
| `app/(group)/` | Layout group — doesn't affect URL |
| `app/(tabs)/_layout.tsx` | Tab navigator layout |
| `app/+not-found.tsx` | 404 |
| `app/+html.tsx` | Web-only root HTML (Expo Router web) |

## Standards

| Pattern | Standard |
|---------|----------|
| Layout | `_layout.tsx` per navigator level |
| Params (local) | `useLocalSearchParams<{ id: string }>()` typed |
| Params (global) | `useGlobalSearchParams` only when deep-link parent needs them |
| Navigation | `router.push('/path')` or `<Link href="/path">` |
| Typed routes | Enabled in `app.json` `experiments.typedRoutes: true` |
| Provider wrapping | Root `_layout.tsx` only (not per-screen) |

## Non-Obvious Anti-Patterns

```tsx
// useLocalSearchParams in a layout (re-runs on every nested route change)
// app/(tabs)/_layout.tsx
export default function Layout() {
  const { id } = useLocalSearchParams()  // ❌ Re-runs for every tab navigation
  return <Tabs />
}
// Fix: read params in the leaf screen, or use useGlobalSearchParams only if truly global

// Provider wrapping inside a screen (re-creates on navigation)
// app/profile.tsx
export default function Profile() {
  return <QueryProvider><ProfileView /></QueryProvider>  // ❌ Provider re-init on focus
}
// Fix: hoist providers to app/_layout.tsx

// Passing complex objects via router.push params (URL-encoded, broken on deep links)
router.push({ pathname: '/edit', params: { user: JSON.stringify(user) } })  // ❌
// Fix: pass id, fetch from store/server
router.push(`/edit/${user.id}`)  // ✅

// router.push in render (causes loops)
export default function Gate() {
  if (!authed) router.replace('/login')  // ❌ During render
  return <View />
}
// Fix: useEffect or Redirect component
export default function Gate() {
  if (!authed) return <Redirect href="/login" />  // ✅
  return <Authed />
}

// Stack.Screen options outside _layout (silently ignored)
// app/profile.tsx
export default function Profile() {
  return <Stack.Screen options={{ title: 'Profile' }} />  // ❌ Won't apply
}
// Fix: configure in parent _layout
// app/_layout.tsx → <Stack.Screen name="profile" options={{ title: 'Profile' }} />

// `unmountOnBlur` no longer exists (removed in React Navigation v7 / expo-router v3+)
<Tabs.Screen name="home" options={{ unmountOnBlur: true }} />  // ❌ Ignored / type error
// Pick the right replacement for what you actually need:
<Tabs.Screen name="home" options={{ freezeOnBlur: true }} />     // ✅ Keep mounted but pause CPU
<Tabs.Screen name="home" options={{ popToTopOnBlur: true }} />   // ✅ Reset nested stack on blur
// For true unmount: useIsFocused + conditional render in the screen itself
const focused = useIsFocused()
if (!focused) return null  // ✅ Manual unmount control
```

## Layout Template

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router'
import { SafeAreaProvider } from 'react-native-safe-area-context'
import { GestureHandlerRootView } from 'react-native-gesture-handler'

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="+not-found" />
        </Stack>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  )
}
```

```tsx
// app/[id].tsx
import { useLocalSearchParams } from 'expo-router'

export default function Detail() {
  const { id } = useLocalSearchParams<{ id: string }>()
  return <ItemView id={id} />
}
```

## Validation Checklist

- [ ] Providers wrapped in root `_layout.tsx`, not per-screen
- [ ] `useLocalSearchParams` not used in layouts (use leaf screens)
- [ ] No `router.push`/`replace` during render — use `<Redirect>` or `useEffect`
- [ ] Complex objects passed via store, not URL params
- [ ] `Stack.Screen options` configured in parent layout, not the screen itself
- [ ] `unmountOnBlur` only on memory-heavy screens
- [ ] `experiments.typedRoutes: true` in app config (for TS safety)

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/expo-router-deeplinks.md` — scheme, universal links, prefixes
- `reference/expo-router-auth.md` — protected routes, redirect patterns, useSegments
- `reference/expo-router-modals.md` — presentation: 'modal', sheet patterns
