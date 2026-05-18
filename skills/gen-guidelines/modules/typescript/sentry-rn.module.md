---
module: sentry-rn
language: typescript
category: platform
requires: []
conflicts: []
---

# Sentry React Native Module

Crash + error reporting for RN/Expo. Setup is brittle (native modules, sourcemaps, EAS integration) — failures are silent.

## Detection

```bash
grep "\"@sentry/react-native\":" package.json
grep -rn "Sentry\.init" --include="*.ts" --include="*.tsx" | head -3
grep "@sentry/react-native/expo" app.json app.config.* 2>/dev/null
```

## Pattern Extraction Commands

```bash
# Init location (should be top-level in root entry, not in a hook)
grep -rB2 "Sentry\.init" --include="*.tsx" --include="*.ts" | head -20

# Routing instrumentation present?
grep -rn "reactNavigationIntegration\|routingInstrumentation" --include="*.ts" --include="*.tsx"

# Root wrap present?
grep -rn "Sentry\.wrap\|export default Sentry\.wrap" --include="*.tsx"

# Anti-pattern: hardcoded DSN
grep -rEn "dsn:\s*['\"]https://[^$]" --include="*.ts" --include="*.tsx"

# Anti-pattern: tracesSampleRate 1.0 without __DEV__ guard
grep -rB2 "tracesSampleRate:\s*1\.0" --include="*.ts" --include="*.tsx" | grep -v "__DEV__"

# Anti-pattern: silent catches with no captureException
grep -rn "catch.*{" --include="*.ts" --include="*.tsx" | head -10  # spot-check
grep -rn "Sentry\.captureException\|Sentry\.captureMessage" --include="*.ts" --include="*.tsx" | wc -l

# PII scrubbing present?
grep -rn "beforeSend" --include="*.ts" --include="*.tsx"

# Sourcemap upload configured?
grep "SENTRY_AUTH_TOKEN" eas.json .env* 2>/dev/null
grep "sentry/react-native/expo" app.json app.config.* 2>/dev/null
```

## Standards

| Concern | Standard |
|---------|----------|
| DSN | `process.env.EXPO_PUBLIC_SENTRY_DSN` — never hardcoded |
| Init location | Top of root entry (e.g., `app/_layout.tsx`), before any other code |
| Root wrap | `export default Sentry.wrap(RootLayout)` |
| Trace sample rate | `__DEV__ ? 1.0 : 0.1` (or lower in prod) |
| Routing instrumentation | `Sentry.reactNavigationIntegration()` (works for expo-router) |
| PII scrubbing | `beforeSend` strips `event.user.email` / `ip_address` and any form-value tags |
| Sourcemaps | `@sentry/react-native/expo` plugin in `app.config` + `SENTRY_AUTH_TOKEN` in EAS env |
| Manual capture | `Sentry.captureException(err)` in every `catch` (re-throw if app must crash) |
| User context | `Sentry.setUser({ id })` — id only, never email/name |
| Flush on exit | `await Sentry.flush(2000)` before deliberate process kill |
| Build target | Dev Client (not Expo Go — Sentry needs native modules) |

## Non-Obvious Anti-Patterns

```tsx
// DSN hardcoded — visible in bundle, can't rotate per env
Sentry.init({ dsn: 'https://abc@o0.ingest.sentry.io/0' })  // ❌
Sentry.init({ dsn: process.env.EXPO_PUBLIC_SENTRY_DSN })  // ✅

// init() in useEffect — early errors during JS startup are lost
export default function App() {
  useEffect(() => { Sentry.init({ ... }) }, [])  // ❌ Init runs after first render
  return <RootLayout />
}
// Fix: top-level call before component declaration
Sentry.init({ ... })
function RootLayout() { ... }
export default Sentry.wrap(RootLayout)  // ✅

// tracesSampleRate: 1.0 left in production (quota burn + noise)
Sentry.init({ tracesSampleRate: 1.0 })  // ❌
Sentry.init({ tracesSampleRate: __DEV__ ? 1.0 : 0.1 })  // ✅

// Silent catch — Sentry never sees the error
try { await riskyCall() } catch (e) { console.log(e) }  // ❌
try { await riskyCall() } catch (e) {
  Sentry.captureException(e)
  throw e  // ✅ Re-throw if the caller needs to know
}

// setUser with PII (email/name) — ships to Sentry, violates GDPR/CCPA defaults
Sentry.setUser({ email: user.email, fullName: user.name })  // ❌
Sentry.setUser({ id: user.id })  // ✅

// Missing beforeSend — RHF / Convex errors often contain form values with PII
Sentry.init({ /* no beforeSend */ })  // ❌ Email/SSN can land in breadcrumbs
Sentry.init({
  beforeSend(event) {
    if (event.user) { delete event.user.email; delete event.user.ip_address }
    return event
  },
})  // ✅

// Missing Sentry.wrap on root — loses touch breadcrumbs + perf root span
export default RootLayout  // ❌
export default Sentry.wrap(RootLayout)  // ✅

// No sourcemap upload — prod stack traces show minified frames, unreadable
// app.config without '@sentry/react-native/expo' plugin   ❌
// Fix: plugin + SENTRY_AUTH_TOKEN in EAS env (sourcemaps upload during build)

// Running on Expo Go — silent failure (Sentry needs native modules)
// `@sentry/react-native` added, still building for Expo Go  ❌
// Fix: switch to Dev Client + EAS Build

// Re-init in HMR / fast refresh (causes duplicate events)
// `Sentry.init` inside a component module that fast-refreshes  ❌
// Fix: keep init in a module loaded once (root entry)

// Forgetting flush before a deliberate exit / logout that resets the app
await signOut()
RNRestart.restart()  // ❌ Events may not have flushed
await Sentry.flush(2000); await signOut(); RNRestart.restart()  // ✅
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

## Manual Capture Patterns

```ts
// Caught error you can recover from
try { await api.refresh() }
catch (e) {
  Sentry.captureException(e, { tags: { feature: 'auth' } })
  return fallback
}

// Non-error notable event
Sentry.captureMessage('Empty inbox state shown', 'info')

// Breadcrumb for navigation/user action
Sentry.addBreadcrumb({ category: 'ui', message: 'Tapped checkout' })
```

## Validation Checklist

- [ ] DSN sourced from `process.env.EXPO_PUBLIC_SENTRY_DSN` — no literal DSN strings
- [ ] `Sentry.init` at top level of root entry, not inside a hook or component body
- [ ] Root layout exported via `Sentry.wrap(...)`
- [ ] `tracesSampleRate` guarded by `__DEV__` or explicitly < 1.0 for prod
- [ ] `beforeSend` hook scrubs `event.user.email` / `ip_address` (and any form-value tags)
- [ ] All `catch` blocks call `Sentry.captureException` (or deliberately re-throw)
- [ ] `Sentry.setUser` carries `id` only — no email/name
- [ ] `@sentry/react-native/expo` listed in `app.config` plugins
- [ ] `SENTRY_AUTH_TOKEN` set in EAS env for sourcemap upload
- [ ] Build profile uses Dev Client — not Expo Go
- [ ] `Sentry.flush(2000)` called before deliberate exits (logout-restart, native crash hooks)

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/sentry-rn-sourcemaps.md` — EAS Build integration, plugin config, manual upload, troubleshooting
- `reference/sentry-rn-performance.md` — transactions, spans, frame tracking, custom instrumentation
- `reference/sentry-rn-privacy.md` — beforeSend deep dive, scrubbing patterns, GDPR/CCPA defaults
