---
module: sentry-conventions
language: typescript
category: observability
requires: []
conflicts: []
---

# Sentry Conventions Module

Universal Sentry SDK rules — platform-agnostic. Extension modules ([[sentry-rn]], future `sentry-nextjs` / `sentry-node`) add platform-specific wiring on top.

## Detection

```bash
grep -E "\"@sentry/(react-native|nextjs|node|browser|react|vue|sveltekit|nuxt|gatsby)\":" package.json
grep -rn "Sentry\.init" --include="*.ts" --include="*.tsx" | head -3
```

## Pattern Extraction Commands

```bash
# Hardcoded DSN (any platform)
grep -rEn "dsn:\s*['\"]https://[^$]" --include="*.ts" --include="*.tsx"

# tracesSampleRate without guard
grep -rB2 "tracesSampleRate:\s*1\.0" --include="*.ts" --include="*.tsx" | grep -vE "__DEV__|process\.env\.NODE_ENV"

# PII scrubbing present?
grep -rn "beforeSend" --include="*.ts" --include="*.tsx"

# setUser PII leakage
grep -rEn "setUser\(\s*\{[^}]*\b(email|name|fullName|phone)\b" --include="*.ts" --include="*.tsx"

# Capture coverage (ratio of catches to captureException calls)
echo "catches:";          grep -rEn "catch\s*\(" --include="*.ts" --include="*.tsx" | wc -l
echo "captureException:"; grep -rn  "Sentry\.captureException" --include="*.ts" --include="*.tsx" | wc -l

# Flush before exit
grep -rn "Sentry\.flush" --include="*.ts" --include="*.tsx"
```

## Standards

| Concern | Standard |
|---------|----------|
| DSN | From env var — never a literal string in source |
| Trace sample rate | High in dev, low in prod (~0.05–0.1) — leave platform guard to extension |
| PII scrubbing | `beforeSend` strips `event.user.email`, `event.user.ip_address`, request bodies, form-value tags |
| Manual capture | `Sentry.captureException(err)` in every `catch` — or deliberate re-throw |
| User context | `Sentry.setUser({ id })` — id only, never email/name/phone |
| Flush on exit | `await Sentry.flush(2000)` before deliberate exit / restart |
| Init location | Module loaded once (not a fast-refreshable component file) |
| Tags / context | Tags for filterable dimensions (`feature`, `env`); `setContext` for structured payloads |

## Non-Obvious Anti-Patterns

```ts
// DSN hardcoded — ships in bundle, can't rotate per env
Sentry.init({ dsn: 'https://abc@o0.ingest.sentry.io/0' })  // ❌
Sentry.init({ dsn: process.env.SENTRY_DSN })               // ✅

// tracesSampleRate 1.0 left in prod (quota burn + noise)
Sentry.init({ tracesSampleRate: 1.0 })                                       // ❌
Sentry.init({ tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0 })  // ✅

// Silent catch — Sentry never sees the error
try { await riskyCall() } catch (e) { console.log(e) }     // ❌
try { await riskyCall() } catch (e) {
  Sentry.captureException(e)
  throw e                                                  // ✅ re-throw if caller needs to know
}

// setUser with PII — ships email/name to Sentry, defeats GDPR-by-default
Sentry.setUser({ email: user.email, fullName: user.name }) // ❌
Sentry.setUser({ id: user.id })                            // ✅

// Missing beforeSend — RHF / form errors carry user input in breadcrumbs
Sentry.init({ /* no beforeSend */ })                       // ❌ Email/SSN can land in events
Sentry.init({
  beforeSend(event) {
    if (event.user) { delete event.user.email; delete event.user.ip_address }
    if (event.request?.data) event.request.data = '[scrubbed]'
    return event
  },
})                                                         // ✅

// Re-init inside a fast-refreshable module (duplicate events on HMR)
// components/App.tsx
Sentry.init({ ... })                                       // ❌ Re-runs on hot reload
// Fix: keep Sentry.init in a once-loaded entry module (e.g., root layout / server entry)

// Forgetting flush before deliberate exit (in-flight events dropped)
process.exit(0)                                            // ❌
await Sentry.flush(2000); process.exit(0)                  // ✅

// Tags used for high-cardinality values (turns into a useless filter)
Sentry.setTag('userId', user.id)                           // ❌ Cardinality blow-up
Sentry.setUser({ id: user.id })                            // ✅ User id belongs on user, not tag
Sentry.setTag('plan', user.plan)                           // ✅ Low cardinality → good tag
```

## Manual Capture Patterns

```ts
// Caught error with context
try { await api.refresh() }
catch (e) {
  Sentry.captureException(e, { tags: { feature: 'auth' } })
  return fallback
}

// Non-error notable event
Sentry.captureMessage('Empty inbox state shown', 'info')

// Breadcrumb for user/system action
Sentry.addBreadcrumb({ category: 'ui', message: 'Tapped checkout' })

// Structured context payload
Sentry.setContext('order', { id: order.id, currency: order.currency })  // never order.customer.email
```

## Validation Checklist

- [ ] DSN sourced from env var — no literal DSN strings in source
- [ ] `tracesSampleRate` < 1.0 in production (env-guarded)
- [ ] `beforeSend` hook scrubs `event.user.email` / `ip_address` / request bodies
- [ ] All `catch` blocks call `Sentry.captureException` (or deliberately re-throw)
- [ ] `Sentry.setUser` carries `id` only — no email/name/phone
- [ ] `Sentry.flush(2000)` called before deliberate exits
- [ ] `Sentry.init` lives in a module that loads once (not a fast-refreshable component file)
- [ ] Tags reserved for low-cardinality dimensions

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/sentry-privacy.md` — beforeSend deep dive, GDPR/CCPA defaults, custom scrubbers
- `reference/sentry-performance.md` — transactions, spans, custom instrumentation
- `reference/sentry-release-health.md` — releases, sessions, crash-free rate
