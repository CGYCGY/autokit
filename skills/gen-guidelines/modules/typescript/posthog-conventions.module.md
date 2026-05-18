---
module: posthog-conventions
language: typescript
category: observability
requires: []
conflicts: []
---

# PostHog Conventions Module

Universal PostHog SDK rules — platform-agnostic. Extension modules ([[posthog-rn]], future `posthog-web` / `posthog-node`) add platform-specific wiring on top.

## Detection

```bash
grep -E "\"(posthog-js|posthog-node|posthog-react-native|posthog-react)\":" package.json
grep -rn "posthog\.capture\|usePostHog\|PostHogProvider" --include="*.ts" --include="*.tsx" | head -3
```

## Pattern Extraction Commands

```bash
# Hardcoded API key
grep -rEn "apiKey:\s*['\"]phc_[A-Za-z0-9]" --include="*.ts" --include="*.tsx"

# identify() argument audit (should be id, not email)
grep -rEn "\.identify\(\s*['\"]?[a-zA-Z0-9._%+-]+@" --include="*.ts" --include="*.tsx"

# Event name inventory — detect casing drift
grep -rEoh "\.capture\(['\"][^'\"]+['\"]" --include="*.ts" --include="*.tsx" | sort -u

# Missing reset() on logout paths
grep -rn "signOut\|logout\|logOut" --include="*.ts" --include="*.tsx" | head -10
grep -rEn "posthog\??\.reset\(" --include="*.ts" --include="*.tsx"

# PII in event properties
grep -rEn "capture\([^)]*\b(email|password|ssn|creditCard|cardNumber|cvv)\b" --include="*.ts" --include="*.tsx"

# Feature flag usage
grep -rn "getFeatureFlag\|isFeatureEnabled\|onFeatureFlags\|useFeatureFlag" --include="*.ts" --include="*.tsx"
```

## Standards

| Concern | Standard |
|---------|----------|
| API key | From env var — never literal `phc_...` in source |
| Distinct ID | Stable user id from auth provider — **not email** |
| Event names | `verb_object` in `snake_case` (`checkout_completed`, `signup_started`) — one convention across product |
| Event properties | No PII (email, SSN, payment numbers, raw request bodies) |
| Groups | `groups({ organization: orgId })` for B2B / multi-tenant attribution |
| Feature flags | Bootstrap only flags that block first paint; `getFeatureFlag(key)` for runtime; `onFeatureFlags()` for reactive UI |
| Logout | `posthog.reset()` — clears distinct_id so next session is fresh anonymous |
| Flush | `posthog.flush()` (or `await shutdown()` on node) before deliberate exit |
| Server side | Don't fire customer-attributed events from server in their logged-out browser session (alias confusion) |

## Non-Obvious Anti-Patterns

```ts
// identify with email as distinct_id — email changes (typo correction, marriage), id doesn't
posthog.identify(user.email)                                  // ❌ Profile orphans on email change
posthog.identify(user.id, { email: user.email })              // ✅ Stable id; email as updatable property

// Missing reset() on logout — next anonymous user inherits previous distinct_id
async function signOut() { await auth.signOut() }             // ❌
async function signOut() { posthog.reset(); await auth.signOut() }  // ✅

// Event naming drift — `Checkout Completed` and `checkout_completed` are different events
posthog.capture('Checkout Completed')                         // ❌ if rest of product uses snake_case
posthog.capture('checkout_completed')                         // ✅

// PII in event properties — shows up in everyone with project access
posthog.capture('signup_started', { email: form.email, password: form.password })  // ❌
posthog.capture('signup_started', { plan: form.plan })        // ✅ Non-sensitive only

// Bootstrapping every flag — slow first paint
PostHog.init(KEY, { bootstrap: { featureFlags: ALL_FLAGS } }) // ❌ Pays full flag-payload cost
PostHog.init(KEY, { bootstrap: { featureFlags: { 'paywall_v2': true } } })  // ✅ Only render-blocking flags

// Using getFeatureFlag before flags load — returns undefined, not the default
const variant = posthog.getFeatureFlag('paywall_v2')          // ❌ undefined on cold start
// Fix: bootstrap for first paint, or gate UI on onFeatureFlags() callback
posthog.onFeatureFlags(() => setReady(true))                  // ✅

// Tags vs properties confusion — PostHog uses properties; tags are Sentry-speak
posthog.capture('event', { tags: ['mobile'] })                // ❌ "tags" is just a property name here
posthog.capture('event', { platform: 'mobile' })              // ✅ Use real property keys

// Firing customer events from server while user is logged out in browser
// (server sees authed cookie expired, browser still has anon distinct_id)
// → events alias to wrong user
// Fix: only capture user-attributed events client-side after identify
```

## Validation Checklist

- [ ] API key sourced from env var — no literal `phc_...` strings
- [ ] `identify()` uses stable user id, never email as the distinct_id
- [ ] Event names follow one casing convention (snake_case `verb_object`)
- [ ] No PII (email, password, SSN, payment) in event properties
- [ ] `posthog.reset()` called on every logout path
- [ ] `posthog.flush()` (or `shutdown()`) before deliberate exit
- [ ] Bootstrap limited to flags that block first paint
- [ ] Server-side captures gated on user-authenticated context

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/posthog-feature-flags.md` — bootstrap strategy, reactive flags, A/B testing, multivariate
- `reference/posthog-groups.md` — group analytics, B2B attribution, group properties
- `reference/posthog-self-hosted.md` — host config, reverse proxy, region selection
