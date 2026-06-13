# @sentry/react-native Build Phase Fails the Build

## Symptom
The iOS Xcode build (under EAS or local) fails inside a Sentry run-script / source-map upload build phase — typically the `react-native-xcode.sh` + Sentry wrapper step — with an auth/org error. The app code is fine; the build dies during the upload phase.

## Root cause
`@sentry/react-native` installs a build phase that uploads source maps/debug symbols to Sentry. With no Sentry org/project/auth token configured, that upload step errors and, because it runs as part of the build, fails the whole build instead of being skipped.

## Fix
Disable Sentry's automatic upload in every EAS build profile until a real Sentry project exists.

```json
// eas.json — set in EVERY profile (development, preview, production, dev-standalone, ...)
{
  "build": {
    "production": {
      "env": { "SENTRY_DISABLE_AUTO_UPLOAD": "true" }
    }
  }
}
```

- `SENTRY_DISABLE_AUTO_UPLOAD=true` makes the Sentry build phase no-op instead of failing — the build proceeds without uploading source maps.
- Set it in EVERY profile; a profile without it will fail the moment its build reaches the upload phase.
- Remove it (or set per-profile) only once a real Sentry org + auth token is wired up and you actually want source maps uploaded.
- Mirrors the repo's existing chore of skipping Sentry source-map upload in EAS builds — keep new profiles consistent.
