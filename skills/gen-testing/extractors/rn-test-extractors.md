# React Native / Expo E2E Test Extractors

## RN/Expo Project Detection

```bash
# React Native CLI
grep -E '"react-native":' package.json
ls ios/ android/ 2>/dev/null
ls react-native.config.js metro.config.js 2>/dev/null

# Expo
grep -E '"expo":' package.json
ls app.json app.config.js app.config.ts 2>/dev/null
```

| Signal | Project Type |
|--------|--------------|
| `ios/` + `android/` dirs, no `app.json` | RN CLI (bare) |
| `app.json` + `expo` dep, no native dirs | Expo managed |
| `app.json` + `expo` + native dirs | Expo prebuild / bare workflow |

**Record:** `bare` vs `managed` — Detox requires bare workflow; Maestro works with either.

## Framework Detection

### Detox

```bash
# Dependency
grep -E '"detox"' package.json

# Config files (any of these)
ls .detoxrc.js .detoxrc.json detox.config.js detox.config.json 2>/dev/null

# Convention folder
ls e2e/ 2>/dev/null
ls e2e/jest.config.js e2e/config.json 2>/dev/null
```

**Record:**
- Config location
- Configurations defined (`ios.sim.debug`, `android.emu.release`, etc.)
- Test runner (Jest is standard; Mocha legacy)

### Maestro

```bash
# Flow folder (most common)
ls .maestro/ maestro/ 2>/dev/null
find . -path ./node_modules -prune -o -name "*.yaml" -print | xargs grep -l "appId:" 2>/dev/null | head -5

# CI usage
grep -r "maestro test" .github/ .gitlab-ci.yml 2>/dev/null
```

**Record:**
- Flow directory
- `appId` (bundle ID for iOS, package name for Android)

## Test File Discovery

### Detox

```bash
# Standard e2e folder
find e2e/ -name "*.test.js" -o -name "*.test.ts" -o -name "*.e2e.ts" 2>/dev/null

# Count
find e2e/ -name "*.test.*" 2>/dev/null | wc -l
```

**Example pattern:**
```typescript
describe('Login flow', () => {
  beforeAll(async () => {
    await device.launchApp({ permissions: { notifications: 'YES' } });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('signs in with valid credentials', async () => {
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('hunter2');
    await element(by.id('submit-btn')).tap();
    await expect(element(by.id('home-screen'))).toBeVisible();
  });
});
```

**Matcher conventions to extract:**
- `by.id('testID')` — requires `testID` prop on RN components
- `by.text('...')` — text matching, locale-fragile
- `by.label('...')` — accessibility label (iOS), accessibilityLabel (Android)
- `by.type('RCTTextInput')` — native component type

```bash
# Which matcher style dominates?
grep -rEho "by\.(id|text|label|type)\(" e2e/ | sort | uniq -c | sort -rn
```

### Maestro

```bash
# Find flow files
find .maestro/ maestro/ -name "*.yaml" -o -name "*.yml" 2>/dev/null
```

**Example flow:**
```yaml
appId: com.example.myapp
---
- launchApp
- tapOn:
    id: "email-input"
- inputText: "test@example.com"
- tapOn:
    id: "password-input"
- inputText: "hunter2"
- tapOn: "Sign in"
- assertVisible:
    id: "home-screen"
```

**Selector conventions to extract:**
- `id:` — matches `testID` (RN) or accessibility id
- `text:` — raw text
- Plain string after `tapOn:` — text shorthand

```bash
# Selector style distribution
grep -rEho "(tapOn|assertVisible|inputText): *(.*)$" .maestro/ | head -20
```

**Subflows / shared steps:**
```bash
# Look for runFlow imports
grep -r "runFlow:" .maestro/ | head -5
```

## Build & Run Commands

### Detox

```bash
# Extract configurations from .detoxrc.js
grep -E "configurations|'ios\.|'android\." .detoxrc.js .detoxrc.json 2>/dev/null

# Find build/test scripts in package.json
grep -E '"e2e:|"detox:' package.json
```

**Typical command shape:**
```bash
# Build once per app change
detox build -c ios.sim.debug

# Run tests
detox test -c ios.sim.debug
detox test -c android.emu.debug --headless
```

**Record:**
- Default configuration name
- Whether CI uses release or debug builds
- Headless flag usage

### Maestro

```bash
# Find maestro commands in scripts/CI
grep -rE "maestro test" package.json .github/ scripts/ 2>/dev/null
```

**Typical command shape:**
```bash
# Local
maestro test .maestro/

# Single flow
maestro test .maestro/login.yaml
```

## Setup Patterns

### Detox Init Hooks

```bash
# Global setup
ls e2e/init.ts e2e/init.js e2e/globalSetup.ts 2>/dev/null
cat e2e/init.ts 2>/dev/null | head -20
```

**Common patterns to record:**
- `device.launchApp` permission grants
- Mock server boot (often MSW or local Express)
- Deep-link reset

### Maestro `onFlowStart` / Hooks

```bash
# Look for config.yaml or hooks
ls .maestro/config.yaml 2>/dev/null
grep -l "onFlowStart\|onFlowComplete" .maestro/ -r 2>/dev/null
```

## Mocking & Test Data

E2E mocking strategies in RN — record which is in use:

| Strategy | Signal |
|---------|--------|
| MSW with `__DEV__` flag | `msw` in deps + `if (__DEV__)` in entry file |
| Detox `device.launchApp` with mock URL | env var override in `init.ts` |
| Local Express mock server | `e2e/mock-server.ts` or similar |
| No mocking (hits staging) | env points at non-prod backend |

```bash
grep -rE "process\.env\.E2E|__DEV__.*mock|msw" e2e/ src/ App.tsx index.js 2>/dev/null | head -10
```

## CI Integration

```bash
# GitHub Actions
grep -rEl "detox|maestro" .github/workflows/ 2>/dev/null

# EAS Build (Expo)
ls eas.json 2>/dev/null
grep -E "buildType|distribution" eas.json 2>/dev/null
```

**Record:**
- Where binaries are built (EAS, local, Fastlane)
- Which simulator/emulator image CI uses
- Whether a device farm (BrowserStack / Sauce Labs) is wired in

## Test ID Convention

Critical for both Detox and Maestro — extract the project's `testID` style:

```bash
# Count testID usage
grep -rEho "testID=[\"'][^\"']+[\"']" src/ app/ | sort -u | head -20

# Naming convention check
grep -rEho "testID=[\"'][^\"']+[\"']" src/ app/ | grep -cE "kebab-case|camelCase|snake_case"
```

**Common conventions:**
- `screen-element` (kebab): `login-email-input`
- `screenElement` (camel): `loginEmailInput`
- Hierarchical: `LoginScreen.EmailInput`

## Output Template

```markdown
## React Native E2E Patterns

### Project Type
- Workflow: [bare / managed / prebuild]
- Platforms: [iOS, Android]

### E2E Frameworks
- Primary: [Detox / Maestro]
- Configurations: [ios.sim.debug, android.emu.release]

### Test Authoring
- Selector style: testID-first (`by.id(...)` / Maestro `id:`)
- testID style: kebab-case
- testID shape: `screen-element`

### Build & Run
- Build: `detox build -c ios.sim.debug`
- Run: `detox test -c ios.sim.debug`
- CI: GitHub Actions on macos-latest, EAS for binaries

### Mocking
- Strategy: MSW behind `__DEV__` guard
- Mock server entry: `src/mocks/server.ts`

### Example
From `e2e/login.test.ts:12`:
\`\`\`typescript
it('signs in with valid credentials', async () => {
  await element(by.id('email-input')).typeText('test@example.com');
  await element(by.id('submit-btn')).tap();
  await expect(element(by.id('home-screen'))).toBeVisible();
});
\`\`\`
```

## Skipping Rules

- **Skip Detox section** if no `detox` dep and no `e2e/` folder.
- **Skip Maestro section** if no `.maestro/` or `maestro/` folder and no `maestro` CI references.
- **If RN/Expo not detected at all:** do not load this file — return to `typescript-test-extractors.md` for web e2e (Playwright/Cypress).
