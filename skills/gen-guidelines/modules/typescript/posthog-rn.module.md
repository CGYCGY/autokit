---
module: posthog-rn
language: typescript
category: observability
requires: [posthog-conventions]
conflicts: []
---

# PostHog React Native Module

RN/Expo-specific PostHog wiring: `PostHogProvider` at root, autocapture opt-in, AsyncStorage/MMKV persistence, expo-router screen tracking.

> See [[posthog-conventions]] for universal PostHog rules (identify, event naming, properties, reset on logout, flush).

## Detection

```bash
grep "\"posthog-react-native\":" package.json
grep -rn "PostHogProvider\|usePostHog" --include="*.tsx" | head -3
```

## Pattern Extraction Commands

```bash
# Provider mount location (must be root layout, not a screen)
grep -rn "PostHogProvider" --include="*.tsx"

# Autocapture flags + constructor lifecycle option
grep -rn "captureAppLifecycleEvents\|captureScreens\|captureTouches" --include="*.tsx"

# Custom storage (MMKV adapter)
grep -rn "customStorage" --include="*.tsx"

# identify() / reset() lifecycle
grep -rn "posthog\.\?identify\|usePostHog().*identify" --include="*.tsx"
grep -rn "posthog\.\?reset" --include="*.tsx"

# Hardcoded host
grep -rn "host:\s*['\"]https" --include="*.tsx"

# Missing EXPO_PUBLIC_ prefix on key
grep -rn "process\.env\.POSTHOG" --include="*.ts" --include="*.tsx"
```

## Standards

| Concern | Standard |
|---------|----------|
| Package | `posthog-react-native` — core SDK works in Expo Go (pure JS). Session replay + native lifecycle events require Dev Client |
| Provider | `PostHogProvider` wraps root in `app/_layout.tsx` (not a screen) |
| API key env var | `process.env.EXPO_PUBLIC_POSTHOG_KEY` (`EXPO_PUBLIC_` prefix mandatory) |
| Host | `host` option for self-hosted / regional (US/EU) — keep in env var if multi-env |
| Autocapture | Spell out flags explicitly. `autocapture={{ captureScreens, captureTouches, ... }}`. **Lifecycle events live separately**: `options={{ captureAppLifecycleEvents: true }}` |
| Screen tracking | `captureScreens: false` for expo-router (uses RN Navigation v7+, auto-capture not supported) — track manually via `posthog.screen(name)` in route effect |
| Persistence | Default `AsyncStorage`; swap to MMKV by setting `options.persistence: 'customStorage'` + `options.customStorage: { getItem, setItem, removeItem }` |
| Identify gating | Wait for `usePostHog()` non-null + auth-success before calling `identify()` — provider mount is async |

## Non-Obvious Anti-Patterns

```tsx
// Provider wrapping a screen instead of root layout (autocapture loses tree context)
// app/profile.tsx
export default function Profile() {
  return <PostHogProvider apiKey={KEY}><ProfileView /></PostHogProvider>  // ❌
}
// Fix: hoist to app/_layout.tsx

// identify() before provider mounts (no-op — posthog instance not ready)
function useAuth() {
  useEffect(() => { posthog?.identify(user.id) }, [])  // ❌ posthog may be undefined
}
// Fix: guard, or call inside an effect that depends on provider readiness
const posthog = usePostHog()
useEffect(() => { if (posthog && user) posthog.identify(user.id) }, [posthog, user])  // ✅

// Expecting capture() to send immediately (RN batches — events ride next flush)
posthog?.capture('checkout_completed')
RNRestart.restart()                                     // ❌ Event may not have flushed
await posthog?.flush(); RNRestart.restart()             // ✅

// Hardcoded API key (visible in bundle, can't rotate per env)
<PostHogProvider apiKey="phc_abc...">                   // ❌
<PostHogProvider apiKey={process.env.EXPO_PUBLIC_POSTHOG_KEY!}>  // ✅

// Forgetting EXPO_PUBLIC_ prefix (key undefined on device, silent no-op — no events fire)
<PostHogProvider apiKey={process.env.POSTHOG_KEY!}>     // ❌ undefined at runtime
<PostHogProvider apiKey={process.env.EXPO_PUBLIC_POSTHOG_KEY!}>  // ✅

// Autocapture defaults left implicit — RN defaults differ from web
<PostHogProvider apiKey={KEY}>                          // ⚠ Unclear what's tracked
<PostHogProvider
  apiKey={KEY}
  options={{ captureAppLifecycleEvents: true }}         // lifecycle is a CLIENT option, not autocapture
  autocapture={{
    captureScreens: false,                              // false for expo-router (RN Navigation v7+) — track manually
    captureTouches: false,                              // touches add noise + payload size
  }}
>                                                       // ✅ Explicit, expo-router-safe

// Putting captureAppLifecycleEvents inside `autocapture` (silently ignored)
<PostHogProvider apiKey={KEY} autocapture={{
  captureAppLifecycleEvents: true,                      // ❌ Wrong key namespace — autocapture only has capture[Screens|Touches|ignoreLabels|...]
}}>
// Fix: it's a client option
<PostHogProvider apiKey={KEY} options={{ captureAppLifecycleEvents: true }}>  // ✅
```

## Init Template

```tsx
// app/_layout.tsx
import { PostHogProvider } from 'posthog-react-native'
import { Stack } from 'expo-router'

export default function RootLayout() {
  return (
    <PostHogProvider
      apiKey={process.env.EXPO_PUBLIC_POSTHOG_KEY!}
      options={{
        host: 'https://us.i.posthog.com',
        captureAppLifecycleEvents: true,
      }}
      autocapture={{
        captureScreens: false,  // expo-router uses RN Navigation v7+ — track manually
        captureTouches: false,
      }}
    >
      <Stack />
    </PostHogProvider>
  )
}
```

## Usage Patterns

```tsx
import { usePostHog, useFeatureFlag, useFeatureFlagWithPayload } from 'posthog-react-native'

function CheckoutScreen() {
  const posthog = usePostHog()
  return <Button onPress={() => posthog?.capture('checkout_started', { plan: 'pro' })} />
}

// Manual screen tracking (replacement for autocapture on expo-router)
function ProductScreen() {
  const posthog = usePostHog()
  useEffect(() => { posthog?.screen('Product', { id: productId }) }, [posthog, productId])
}

// Feature flag hooks (return undefined while loading — gate UI accordingly)
function Paywall() {
  const variant = useFeatureFlag('paywall_v2')                    // 'control' | 'treatment' | boolean | undefined
  const [enabled, payload] = useFeatureFlagWithPayload('paywall_v2')
  if (variant === undefined) return <Skeleton />
  return variant === 'treatment' ? <NewPaywall payload={payload} /> : <OldPaywall />
}

// On login (in auth effect, after provider mounts):
posthog?.identify(user.id, { plan: user.plan })

// On logout:
posthog?.reset()
```

## MMKV Storage Adapter (optional)

```ts
// lib/posthog-mmkv-storage.ts — use when project already standardizes on MMKV
import { storage } from '@/lib/storage'  // see rn-storage-crypto

export const posthogStorage = {
  getItem: (key: string) => storage.getString(key) ?? null,
  setItem: (key: string, value: string) => storage.set(key, value),
  removeItem: (key: string) => storage.delete(key),  // required by SDK
}
```

```tsx
// Both `persistence` AND `customStorage` are required — without `persistence: 'customStorage'`
// the SDK falls back to the default file persistence and ignores the adapter.
<PostHogProvider
  apiKey={KEY}
  options={{
    persistence: 'customStorage',
    customStorage: posthogStorage,
  }}
>
  ...
</PostHogProvider>
```

## Validation Checklist

- [ ] `PostHogProvider` mounted at root (`app/_layout.tsx`), not nested in a screen
- [ ] API key sourced from `EXPO_PUBLIC_POSTHOG_KEY` env var
- [ ] `identify()` gated on `usePostHog()` non-null + auth success (provider mount is async)
- [ ] `captureAppLifecycleEvents` placed under `options`, not inside `autocapture`
- [ ] `captureScreens: false` for expo-router projects — manual `posthog.screen()` calls in place
- [ ] `flush()` awaited before `RNRestart.restart()` / forced exits
- [ ] MMKV adapter (if used) sets `persistence: 'customStorage'` AND defines `removeItem`

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/posthog-rn-feature-flags.md` — bootstrap on RN, reactive flags via `useFeatureFlag`, A/B testing
- `reference/posthog-rn-self-hosted.md` — host config, reverse proxy setup, regional endpoints
