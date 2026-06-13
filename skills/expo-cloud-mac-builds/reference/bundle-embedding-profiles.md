# Embedding the JS Bundle (offline-capable debug builds)

## Goal
A build that runs without a Metro/dev server — the JS bundle is embedded in the binary. Useful for sideloading a "debug-like" build that works offline. The mechanism differs between Android and iOS, and the two are easy to get subtly wrong.

## Android — debug APK silently embeds the bundle
- With Android product flavors and the default `debuggableVariants` config, the debug variant still gets the JS bundle compiled in, so the debug APK runs offline (no Metro needed) — this happens silently, you don't opt in.
- Consequence: a "debug" APK is already a self-contained offline build. Don't assume debug == needs-Metro on Android.
- If you instead want a debug variant that requires Metro, you'd have to adjust `debuggableVariants` so the bundle is NOT embedded for that variant.

## iOS — needs a non-dev-client EAS profile
- The iOS twin does NOT embed the bundle just by being a debug build. A dev-client build (EAS profile with `developmentClient: true`) expects Metro and will not run offline.
- To get the iOS equivalent of the offline Android debug APK, use an EAS build profile WITH `developmentClient` OMITTED (not `true`). Omitting it produces a non-dev-client build that embeds the JS bundle and runs standalone.

```json
// eas.json — iOS profile that embeds the bundle (offline-capable)
{
  "build": {
    "dev-standalone": {
      // no "developmentClient": true  ->  Release config, bundle embedded, runs without Metro
      "distribution": "internal",
      "channel": "development",
      "environment": "development",
      "env": { "APP_VARIANT": "dev", "SENTRY_DISABLE_AUTO_UPLOAD": "true" }
    }
  }
}
```

- The decisive bit is the ABSENCE of `developmentClient: true`, not adding any "embed" flag. Setting `developmentClient: true` is what makes it expect Metro.
- The repo already has a `dev-standalone` iOS profile for exactly this — use/extend it rather than inventing a new one.
