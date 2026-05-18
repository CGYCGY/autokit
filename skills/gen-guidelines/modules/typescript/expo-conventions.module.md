---
module: expo-conventions
language: typescript
category: platform
requires: []
conflicts: []
---

# Expo Conventions Module

Project-level Expo configuration: app config, EAS Build, OTA updates, dev client vs Expo Go, plugin model. Decisions here have non-recoverable consequences (e.g., OTA can't ship native module changes).

## Detection

```bash
test -f app.json && echo "app.json present"
find . -maxdepth 2 -name "app.config.*" -type f
test -f eas.json && echo "eas.json present"
grep "\"expo\":" package.json | head -1
grep -A30 "\"expo\":" package.json | grep "plugins\|extra\|scheme"
```

## Pattern Extraction Commands

```bash
# Static vs dynamic config
test -f app.config.ts && echo "DYNAMIC (app.config.ts)"
test -f app.config.js && echo "DYNAMIC (app.config.js)"
test -f app.json && test ! -f app.config.ts && test ! -f app.config.js && echo "STATIC (app.json only)"

# Plugins inventory
grep -A1 '"plugins"' app.json app.config.* 2>/dev/null | head -30

# Env / extra
grep "extra\|EXPO_PUBLIC_" app.json app.config.* 2>/dev/null
grep -rn "Constants\.expoConfig\.extra\|process\.env\.EXPO_PUBLIC_" --include="*.ts" --include="*.tsx" | head -10

# OTA / runtime
grep "runtimeVersion\|updates" app.json app.config.* 2>/dev/null

# EAS profiles
test -f eas.json && cat eas.json | head -40
```

## Standards

| Concern | Standard |
|---------|----------|
| Config form | `app.config.ts` if any value needs env / branching; else `app.json` |
| Env to client | `EXPO_PUBLIC_*` (inlined at build) for public; SecureStore for secrets |
| Runtime config | `Constants.expoConfig.extra` for build-baked vars |
| Native deps | Document in `plugins`; build a Dev Client (not Expo Go) |
| OTA | `expo-updates` with `runtimeVersion: 'appVersion'` or fingerprint |
| EAS profiles | `development` (Dev Client) → `preview` (internal QA) → `production` |
| iOS perms | All `NS*UsageDescription` in `ios.infoPlist` or via plugin |
| Android perms | Listed in `android.permissions` or via plugin |

## Native Module Compatibility

| Need | Use |
|------|-----|
| Stay on Expo Go | Only Expo SDK packages + JS-only libs |
| Use any RN package | Dev Client (`expo-dev-client`) + EAS Build |
| Custom native code | Config plugin or `expo prebuild` + bare workflow |

**Expo Go is for the Expo SDK + JS libs only.** Adding `react-native-mmkv`, `react-native-quick-crypto`, or any other library with native code requires a Dev Client.

## Non-Obvious Anti-Patterns

```ts
// Hardcoded API URL (impossible to override per environment)
const API = 'https://api.prod.example.com'  // ❌
// Fix: app.config.ts + Constants
// app.config.ts
export default ({ config }) => ({
  ...config,
  extra: { apiUrl: process.env.API_URL ?? 'http://localhost:3000' },
})
// usage:
import Constants from 'expo-constants'
const API = Constants.expoConfig?.extra?.apiUrl  // ✅

// Secret in EXPO_PUBLIC_ env (shipped in the bundle, decompilable)
EXPO_PUBLIC_STRIPE_SECRET=sk_live_...  // ❌ Public = client-visible
// Fix: keep secrets server-side; only ship publishable keys

// OTA pushing a native-module bump (won't take effect — bundle expects different native)
// Adding react-native-mmkv via OTA  ❌ Crashes on launch
// Fix: bump runtimeVersion + new EAS build

// Missing iOS permission description (App Store rejection)
// Camera plugin without ios.infoPlist.NSCameraUsageDescription  ❌
// Fix: declare every NS*UsageDescription you trigger

// Building production with development profile envs
// eas.json production profile inheriting from development  ❌ Ships dev creds

// Static app.json when env-driven values needed
{ "expo": { "extra": { "apiUrl": "https://prod.com" } } }  // ❌ Locked at commit
// Fix: app.config.ts with process.env

// Running against Expo Go after adding a non-SDK native lib
// react-native-mmkv won't work in Expo Go — needs Dev Client  ❌
```

## app.config.ts Template

```ts
import type { ConfigContext, ExpoConfig } from 'expo/config'

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'MyApp',
  slug: 'myapp',
  scheme: 'myapp',
  version: '1.0.0',
  orientation: 'portrait',
  runtimeVersion: { policy: 'appVersion' },
  updates: {
    url: 'https://u.expo.dev/...',
    checkAutomatically: 'ON_LOAD',
  },
  ios: {
    bundleIdentifier: 'com.example.myapp',
    supportsTablet: false,
    infoPlist: {
      NSCameraUsageDescription: 'Used to attach photos to posts.',
      NSPhotoLibraryUsageDescription: 'Used to attach photos to posts.',
    },
  },
  android: {
    package: 'com.example.myapp',
    permissions: ['CAMERA', 'READ_MEDIA_IMAGES'],
  },
  plugins: [
    'expo-router',
    'expo-secure-store',
    ['expo-camera', { cameraPermission: 'Allow $(PRODUCT_NAME) to access your camera.' }],
  ],
  extra: {
    apiUrl: process.env.API_URL ?? 'http://localhost:3000',
    convexUrl: process.env.EXPO_PUBLIC_CONVEX_URL,
    eas: { projectId: '...' },
  },
})
```

## eas.json Template

```json
{
  "cli": { "version": ">= 10" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": { "API_URL": "http://localhost:3000" }
    },
    "preview": {
      "distribution": "internal",
      "env": { "API_URL": "https://staging.example.com" }
    },
    "production": {
      "autoIncrement": true,
      "env": { "API_URL": "https://api.example.com" }
    }
  },
  "submit": { "production": {} }
}
```

## Validation Checklist

- [ ] No hardcoded API URLs / project IDs in source — use `extra` or `EXPO_PUBLIC_*`
- [ ] No secrets in `EXPO_PUBLIC_*` (bundle-visible) — server-side only
- [ ] Every triggered iOS permission has an `NS*UsageDescription`
- [ ] Every triggered Android permission listed (or set by plugin)
- [ ] OTA never carries native dep changes — bump `runtimeVersion` + rebuild
- [ ] EAS profiles separate envs (no prod creds in dev profile)
- [ ] Dev Client used as soon as any non-Expo-SDK native lib is added
- [ ] `runtimeVersion` policy set (appVersion / fingerprint) — never omitted

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/expo-eas-submit.md` — App Store / Play submission, credentials
- `reference/expo-updates-strategy.md` — channels, rollback, A/B
- `reference/expo-plugins.md` — writing config plugins, mod hooks
