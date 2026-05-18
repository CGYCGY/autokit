---
module: sentry-rn
language: typescript
category: observability
requires: [sentry-conventions]
conflicts: []
---

# Sentry React Native Module

RN/Expo-specific Sentry wiring: native modules, root wrap, expo-router routing, EAS sourcemap upload.

> See [[sentry-conventions]] for universal Sentry rules (DSN, beforeSend, captureException, setUser, flush, HMR).

## Detection

```bash
grep "\"@sentry/react-native\":" package.json
grep "@sentry/react-native/expo" app.json app.config.* 2>/dev/null
grep -rn "Sentry\.wrap\|reactNavigationIntegration" --include="*.tsx" | head -3
```

## Pattern Extraction Commands

```bash
# Init location (must be top-level in root entry, not in a hook)
grep -rB2 "Sentry\.init" --include="*.tsx" --include="*.ts" | head -20

# Routing instrumentation
grep -rn "reactNavigationIntegration\|routingInstrumentation" --include="*.ts" --include="*.tsx"

# Root wrap
grep -rn "Sentry\.wrap\|export default Sentry\.wrap" --include="*.tsx"

# Sourcemap pipeline configured?
grep "SENTRY_AUTH_TOKEN" eas.json .env* 2>/dev/null
grep "sentry/react-native/expo" app.json app.config.* 2>/dev/null

# Native frames tracking
grep -rn "enableNativeFramesTracking" --include="*.ts" --include="*.tsx"
```

## Standards

| Concern | Standard |
|---------|----------|
| DSN env var | `process.env.EXPO_PUBLIC_SENTRY_DSN` (`EXPO_PUBLIC_` prefix required for client access) |
| Init location | Top of root entry (`app/_layout.tsx`), at module scope — before component declarations |
| Root wrap | `export default Sentry.wrap(RootLayout)` |
| Routing instrumentation | `Sentry.reactNavigationIntegration()` (works for both react-navigation and expo-router) |
| Native frames | `enableNativeFramesTracking: !__DEV__` |
| Sourcemaps | `@sentry/react-native/expo` plugin in `app.config` + `SENTRY_AUTH_TOKEN` in EAS env |
| Build target | Dev Client or production build — **not Expo Go** (Sentry needs native modules) |

## Non-Obvious Anti-Patterns

```tsx
// init() in useEffect — early errors during JS startup are lost
export default function App() {
  useEffect(() => { Sentry.init({ ... }) }, [])  // ❌ Init runs after first render
  return <RootLayout />
}
// Fix: top-level module call before component declaration
Sentry.init({ ... })
function RootLayout() { ... }
export default Sentry.wrap(RootLayout)  // ✅

// Missing Sentry.wrap on root — loses touch breadcrumbs + perf root span
export default RootLayout                // ❌
export default Sentry.wrap(RootLayout)   // ✅

// Running on Expo Go — silent failure (Sentry needs native modules)
// `@sentry/react-native` installed, still building for Expo Go  ❌
// Fix: switch to Dev Client + EAS Build

// No sourcemap upload — prod stack traces show minified frames, unreadable
// app.config without '@sentry/react-native/expo' plugin   ❌
// Fix: add plugin + SENTRY_AUTH_TOKEN in EAS env (sourcemaps upload during build)

// Forgetting flush before RNRestart / forced exit
await signOut()
RNRestart.restart()                                          // ❌ Events may not flush
await Sentry.flush(2000); await signOut(); RNRestart.restart()  // ✅

// Routing instrumentation outside init() (no-op)
const routingInstrumentation = Sentry.reactNavigationIntegration()  // declared but unused  ❌
Sentry.init({
  integrations: [Sentry.reactNavigationIntegration({ enableTimeToInitialDisplay: true })],  // ✅
})

// EXPO_PUBLIC_ prefix missing on DSN env (key undefined at runtime, silent no-op)
Sentry.init({ dsn: process.env.SENTRY_DSN })           // ❌ undefined on device
Sentry.init({ dsn: process.env.EXPO_PUBLIC_SENTRY_DSN })  // ✅
```

## Init Template

```tsx
// app/_layout.tsx (Expo Router) — runs at top of bundle
import * as Sentry from '@sentry/react-native'
import { Stack } from 'expo-router'

Sentry.init({
  dsn: process.env.EXPO_PUBLIC_SENTRY_DSN,
  tracesSampleRate: __DEV__ ? 1.0 : 0.1,
  enableNativeFramesTracking: !__DEV__,
  integrations: [
    Sentry.reactNavigationIntegration({ enableTimeToInitialDisplay: true }),
  ],
  beforeSend(event) {
    if (event.user) {
      delete event.user.email
      delete event.user.ip_address
    }
    return event
  },
})

function RootLayout() {
  return <Stack />
}

export default Sentry.wrap(RootLayout)
```

## Sourcemap Upload (Expo plugin)

```ts
// app.config.ts
export default {
  plugins: [
    'expo-router',
    '@sentry/react-native/expo',
    // ...
  ],
}
```

```json
// eas.json — auth token needed at build time
{
  "build": {
    "production": {
      "env": { "SENTRY_AUTH_TOKEN": "$SENTRY_AUTH_TOKEN" }
    }
  }
}
```

Run once: `eas secret:create --name SENTRY_AUTH_TOKEN --value $TOKEN`.

## Validation Checklist

- [ ] `Sentry.init` at top level of root entry, not inside a hook or component body
- [ ] Root layout exported via `Sentry.wrap(...)`
- [ ] `Sentry.reactNavigationIntegration()` listed in `integrations`
- [ ] `enableNativeFramesTracking` gated on `!__DEV__`
- [ ] `@sentry/react-native/expo` listed in `app.config` plugins
- [ ] `SENTRY_AUTH_TOKEN` set in EAS env for sourcemap upload
- [ ] Build profile uses Dev Client / production build — not Expo Go
- [ ] DSN env var uses `EXPO_PUBLIC_` prefix
- [ ] `Sentry.flush(2000)` called before `RNRestart.restart()` / native exit hooks

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/sentry-rn-sourcemaps.md` — EAS Build integration, plugin config, manual upload, troubleshooting
- `reference/sentry-rn-performance.md` — transactions, spans, frame tracking, custom instrumentation
- `reference/sentry-rn-privacy.md` — RN-specific scrubbing (deep linking params, screen names)
