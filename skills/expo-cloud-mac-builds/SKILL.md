---
name: expo-cloud-mac-builds
description: Environment-level gotchas for building/testing an Expo + EAS app on a rented/cloud Mac and for EAS builds in general. Use when Metro is unreachable from a simulator behind cloud-Mac NAT, when eas credentials / Apple login fails as "wrong password" or hangs at PREPARE_CREDENTIALS, when eas-cli config introspection trips env validation, when EAS can't see .env.local vars, when the Xcode build dies in the Sentry upload phase, when a debug/dev APK won't run offline, or when brew-installed tools vanish from a Termius/SSH shell. Triggers: "metro not loading on simulator", "wrong apple password but it's correct", "eas build local fails credentials", "eas env push", "sentry build phase failing", "apk won't run without metro", "brew command not found over ssh".
---

# Expo Cloud-Mac & EAS Build Gotchas

## Purpose

Diagnose and fix environment-level failures that are specific to running Expo + EAS on a rented/cloud Mac (NAT, headless SSH, datacenter IP) and EAS builds in general — failures that look like app bugs but are actually host/credential/config-introspection artifacts.

## Instructions

Each rule below is a one-line index. Read the linked reference only for the symptom you hit.

- **Metro unreachable from simulator (cloud-Mac NAT):** set `REACT_NATIVE_PACKAGER_HOSTNAME=127.0.0.1`; `--localhost` binds IPv6 `[::1]` only. **Read:** `reference/metro-and-networking.md`
- **"Wrong password" on Apple login / `eas credentials` from the Mac:** datacenter IP is blocked by Apple, disguised as a password error; run Apple-auth steps from a home IP, not the Mac. **Read:** `reference/apple-credentials-session.md`
- **Cert import / `eas build --local` dies at PREPARE_CREDENTIALS over SSH:** SSH has no macOS keychain/security session; run in a GUI Terminal via AnyDesk/VNC. **Read:** `reference/apple-credentials-session.md`
- **Env validation throws during `eas-cli` config introspection:** eas-cli reads app config WITHOUT loading `.env`; detect eas-cli and warn-not-throw. **Read:** `reference/eas-cli-config-introspection.md`
- **EAS build can't see `.env.local` vars:** EAS copies the project respecting `.gitignore`, so `.env.local` is excluded; push via `eas env:push`, and EAS rejects empty-valued vars. **Read:** `reference/eas-env-and-gitignore.md`
- **Xcode build fails in the `@sentry/react-native` upload phase:** no Sentry org/token makes the upload phase fail the build; set `SENTRY_DISABLE_AUTO_UPLOAD=true` in every EAS profile until a real Sentry project exists. **Read:** `reference/sentry-build-phase.md`
- **Debug/dev build won't run offline, or iOS twin has no embedded bundle:** Android flavors + default `debuggableVariants` embed the JS bundle (runs offline); the iOS equivalent needs an EAS profile WITHOUT `developmentClient` to embed the bundle. **Read:** `reference/bundle-embedding-profiles.md`
- **`brew`/brew-installed tools "command not found" in a Termius/SSH shell:** Homebrew installer needs `NONINTERACTIVE=1`; persist `eval "$(brew shellenv)"` to `~/.zprofile` or tools vanish from interactive shells. **Read:** `reference/mac-bootstrap.md`

## Cookbook

### Metro / Simulator Networking
- **IF:** simulator/device can't reach Metro on a cloud Mac, or bundler URL points at an unreachable LAN IP
- **THEN:** apply `reference/metro-and-networking.md` (set `REACT_NATIVE_PACKAGER_HOSTNAME`, never `--localhost`)
- **EXAMPLES:** "metro not loading on simulator", "could not connect to development server", "bundler url is wrong on the cloud mac"

### Apple Credentials / Headless Session
- **IF:** Apple login reports a wrong password that is correct, OR `eas credentials` / `eas build --local` stalls or fails at PREPARE_CREDENTIALS / cert import over SSH
- **THEN:** apply `reference/apple-credentials-session.md` (run Apple-auth from home IP; run credential/local-build steps in a GUI Terminal)
- **EXAMPLES:** "wrong apple password but it's correct", "eas credentials fails on the rented mac", "eas build local hangs at prepare credentials", "cert import fails over ssh"

### EAS-CLI Config Introspection
- **IF:** `eas build` / `eas update` / any eas-cli invocation throws from env-validation code while reading app config
- **THEN:** apply `reference/eas-cli-config-introspection.md` (detect eas-cli via `EXPO_NO_DOTENV` + argv, warn instead of throw)
- **EXAMPLES:** "eas build fails on env validation", "missing env var during eas config read", "t3-env throws when eas-cli loads app.config"

### EAS Environment Variables
- **IF:** a var present in `.env.local` is undefined inside the EAS build, or `eas env:push` rejects a var
- **THEN:** apply `reference/eas-env-and-gitignore.md` (push to EAS environments; remove/placeholder empty-valued vars)
- **EXAMPLES:** "eas build env is empty", "env var missing in eas build", "eas env push rejected my variable"

### Sentry Build Phase
- **IF:** the Xcode/EAS build fails inside a Sentry / source-map upload run-script phase
- **THEN:** apply `reference/sentry-build-phase.md` (set `SENTRY_DISABLE_AUTO_UPLOAD=true` in every EAS profile)
- **EXAMPLES:** "sentry build phase failing", "source map upload failed the build", "react-native-xcode sentry script error"

### Bundle Embedding / Offline Builds
- **IF:** a debug/dev build must run without Metro, or the iOS counterpart of an offline Android debug APK ships without a JS bundle
- **THEN:** apply `reference/bundle-embedding-profiles.md` (Android flavor/debuggableVariants vs an iOS non-dev-client EAS profile)
- **EXAMPLES:** "apk won't run without metro", "offline debug build", "ios build has no js bundle", "need a non-dev-client profile"

### Mac Bootstrap
- **IF:** setting up a fresh/cloud Mac headlessly, or brew-installed tools are missing in interactive (Termius/SSH) shells
- **THEN:** apply `reference/mac-bootstrap.md` (`NONINTERACTIVE=1` installer; persist `brew shellenv` to `~/.zprofile`)
- **EXAMPLES:** "brew command not found over ssh", "set up homebrew on the rented mac noninteractively", "node missing in termius shell"

## Supporting Files

- `reference/metro-and-networking.md` — Metro hostname advertising under cloud-Mac NAT
- `reference/apple-credentials-session.md` — datacenter-IP Apple block + headless-SSH keychain/security session
- `reference/eas-cli-config-introspection.md` — env validation under eas-cli config reads (warn-not-throw + detection)
- `reference/eas-env-and-gitignore.md` — `.gitignore`-excluded env files + `eas env:push` + empty-value rejection
- `reference/sentry-build-phase.md` — disabling Sentry auto-upload in EAS profiles
- `reference/bundle-embedding-profiles.md` — Android flavor/debuggableVariants vs iOS non-dev-client bundle embedding
- `reference/mac-bootstrap.md` — Homebrew noninteractive install + persistent shellenv
