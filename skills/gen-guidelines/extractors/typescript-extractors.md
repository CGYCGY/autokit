# TypeScript/JavaScript Code Extractors

This file defines extraction logic for analyzing TypeScript and JavaScript codebases.

## General Utilities

### Find TypeScript/JavaScript Files
```bash
# Find all TypeScript files
find . -name "*.ts" -o -name "*.tsx" -not -path "*/node_modules/*" -not -path "*/dist/*" -not -path "*/build/*"

# Find specific file types
find . -name "*.tsx" -not -path "*/node_modules/*"  # React components
find . -name "*.ts" -not -path "*/node_modules/*" -not -name "*.test.ts"  # Non-test TS files
```

### Parse package.json
```bash
# Get project dependencies
grep -A100 "\"dependencies\":" package.json | grep "\"" | head -20

# Get dev dependencies
grep -A100 "\"devDependencies\":" package.json | grep "\"" | head -20

# Check for specific packages
grep "\"react\"\|\"next\"\|\"zustand\"\|\"zod\"" package.json
```

### Search Imports
```bash
# Find all imports
grep -rn "^import" --include="*.ts" --include="*.tsx" | head -50

# Find specific package imports
grep -rn "from ['\"]react['\"]" --include="*.tsx"
grep -rn "from ['\"]zustand['\"]" --include="*.ts"
grep -rn "from ['\"]@/" --include="*.ts" --include="*.tsx"  # Path aliases

# Find type-only imports
grep -rn "import type {" --include="*.ts" --include="*.tsx"
```

## Pattern Extractors

### Extract Type Definitions
```bash
# Find all interface definitions
grep -rn "^export interface\|^interface" --include="*.ts" --include="*.tsx"

# Find all type aliases
grep -rn "^export type\|^type" --include="*.ts" --include="*.tsx"

# Find enum definitions
grep -rn "^export enum\|^enum" --include="*.ts"

# Find string literal unions
grep -rn "= '.*' | '.*'" --include="*.ts"
```

### Extract React Components
```bash
# Find function components
grep -rn "^export function.*{" --include="*.tsx"

# Find forwardRef components
grep -rn "forwardRef<" --include="*.tsx"

# Find "use client" directives
grep -rn "^\"use client\"" --include="*.tsx"

# Find component props interfaces
grep -rn "interface.*Props" --include="*.tsx"
```

### Extract Next.js Patterns
```bash
# Find App Router files
find app/ -name "page.tsx" -o -name "layout.tsx" -o -name "route.ts" 2>/dev/null

# Find metadata exports
grep -rn "export const metadata\|export async function generateMetadata" app/ --include="*.tsx"

# Find API route handlers
grep -rn "export async function (GET|POST|PUT|DELETE)" app/api/ --include="*.ts"
```

### Extract State Management
```bash
# Find Zustand stores
grep -rn "create<.*>()()" --include="*.ts"
grep -rn "persist(" --include="*.ts"

# Find useState usage
grep -rn "useState<" --include="*.tsx"

# Find useEffect usage
grep -rn "useEffect(" --include="*.tsx"

# Find custom hooks
grep -rn "^export function use[A-Z]" --include="*.ts" --include="*.tsx"
```

### Extract Styling Patterns
```bash
# Find Tailwind className usage
grep -ro 'className="[^"]*"' --include="*.tsx" | head -30

# Find cn() utility usage
grep -rn "cn(" --include="*.tsx" | wc -l

# Find CVA usage
grep -rn "cva(" --include="*.tsx"
grep -rn "VariantProps<typeof" --include="*.tsx"

# Find CSS variables
grep -rn "--color-" app/globals.css styles/globals.css 2>/dev/null
```

### Extract Validation Patterns
```bash
# Find Zod schemas
grep -rn "z\\.object({" --include="*.ts" --include="*.tsx"

# Find React Hook Form usage
grep -rn "useForm<.*>({" --include="*.tsx"
grep -rn "zodResolver(" --include="*.tsx"

# Find type inference
grep -rn "z\\.infer<typeof" --include="*.ts"

# Find validation decorators (NestJS)
grep -rn "@Is.*(\|@Min(\|@Max(" --include="*.ts"
```

### Extract React Native Patterns
```bash
# Primitive usage (RN-specific)
grep -rn "<View\|<Text\|<Pressable\|<ScrollView\|<FlatList\|<SectionList\|<Image" --include="*.tsx" | head -20

# Platform branching
grep -rn "Platform\.OS\|Platform\.select" --include="*.tsx"
find . -name "*.ios.tsx" -o -name "*.android.tsx" -o -name "*.native.tsx" 2>/dev/null

# Legacy touchables (anti-pattern signal)
grep -rn "<TouchableOpacity\|<TouchableHighlight\|<TouchableWithoutFeedback" --include="*.tsx"

# Reanimated + Gesture Handler
grep -rn "useSharedValue\|useAnimatedStyle\|runOnJS\|runOnUI\|'worklet'" --include="*.tsx"
grep -rn "Gesture\.\|GestureDetector" --include="*.tsx"

# Safe area pattern
grep -rn "useSafeAreaInsets\|SafeAreaView\|SafeAreaProvider" --include="*.tsx"

# List perf signals
grep -rn "keyExtractor=\|renderItem=" --include="*.tsx" | head -10
grep -rn "<ScrollView" --include="*.tsx" -A5 | grep "\.map(" | head -5  # ScrollView+map anti-pattern
```

### Extract Expo Router Patterns
```bash
# File-based route inventory
find app/ -name "*.tsx" 2>/dev/null | sort

# Special files
find app/ -name "_layout.tsx" -o -name "+not-found.tsx" -o -name "+html.tsx" 2>/dev/null

# Route groups / dynamic segments
find app/ -type d -name "(*)" 2>/dev/null         # groups
find app/ -name "\[*\].tsx" 2>/dev/null            # dynamic
find app/ -name "\[\.\.\.*\].tsx" 2>/dev/null     # catch-all

# Navigator types in layouts
grep -rn "<Stack\b\|<Tabs\b\|<Drawer\b\|<Slot\b" app/ --include="_layout.tsx"

# Search params consumption
grep -rn "useLocalSearchParams\|useGlobalSearchParams\|useSegments\|useRouter\|usePathname" --include="*.tsx"

# Typed routes flag
grep -rn "typedRoutes" app.json app.config.* 2>/dev/null
```

### Extract Tamagui Patterns
```bash
# Tamagui import surface
grep -rn "from ['\"]tamagui['\"]\|from ['\"]@tamagui/" --include="*.ts" --include="*.tsx" | head -10

# styled() definitions
grep -rn "styled(" --include="*.tsx" | grep -v node_modules

# Token-discipline check (tokens vs raw)
echo "Token refs:"; grep -rEn "\\\$(color|space|size|radius|font|shadowColor)" --include="*.tsx" | wc -l
echo "Raw hex/rgb in JSX:"; grep -rEn "color=['\"]?#|bg=['\"]?#|backgroundColor:[[:space:]]*['\"]?#" --include="*.tsx" | wc -l

# StyleSheet leakage in a Tamagui project
grep -rn "StyleSheet\.create" --include="*.tsx" | grep -v node_modules

# Theme + media
grep -rn "useTheme\|useThemeName\|useMedia" --include="*.tsx"
```

### Extract NativeWind Patterns
```bash
# className adoption on RN primitives
grep -rn "className=" --include="*.tsx" | wc -l

# cn() utility
grep -rn "export function cn\|export const cn" --include="*.ts"

# Platform-prefix usage
grep -rEn "(ios|android|web|native):" --include="*.tsx" | head -10

# hover: anti-pattern (no-op on mobile)
grep -rEn "hover:|group-hover:" --include="*.tsx" | head -5

# Arbitrary color anti-pattern
grep -rEn "(bg|text|border)-\[#" --include="*.tsx" | head -5

# space-* vs gap-* on RN
grep -rn "space-x-\|space-y-" --include="*.tsx" | wc -l
grep -rn "gap-" --include="*.tsx" | wc -l
```

### Extract Sentry RN Patterns
```bash
# Init location + presence
grep -rB2 "Sentry\.init" --include="*.tsx" --include="*.ts" | head -20

# Routing instrumentation
grep -rn "reactNavigationIntegration\|routingInstrumentation" --include="*.ts" --include="*.tsx"

# Root wrap
grep -rn "Sentry\.wrap" --include="*.tsx"

# Anti-pattern: hardcoded DSN
grep -rEn "dsn:\s*['\"]https://[^$]" --include="*.ts" --include="*.tsx"

# Anti-pattern: tracesSampleRate 1.0 without __DEV__ guard
grep -rB2 "tracesSampleRate:\s*1\.0" --include="*.ts" --include="*.tsx" | grep -v "__DEV__"

# PII scrubbing presence
grep -rn "beforeSend" --include="*.ts" --include="*.tsx"

# captureException coverage
grep -rn "Sentry\.captureException\|Sentry\.captureMessage" --include="*.ts" --include="*.tsx" | wc -l

# Sourcemap upload config
grep "SENTRY_AUTH_TOKEN" eas.json .env* 2>/dev/null
grep "@sentry/react-native/expo" app.json app.config.* 2>/dev/null
```

### Extract Convex Patterns
```bash
# Convex install + dir
grep "\"convex\":" package.json
test -d convex && ls -la convex/

# Schema
test -f convex/schema.ts && grep -n "defineTable\|\\.index(" convex/schema.ts

# Function classification
echo "Queries:"; grep -rn "= query(" convex/ --include="*.ts" 2>/dev/null | wc -l
echo "Mutations:"; grep -rn "= mutation(" convex/ --include="*.ts" 2>/dev/null | wc -l
echo "Actions:"; grep -rn "= action(" convex/ --include="*.ts" 2>/dev/null | wc -l
echo "Internal:"; grep -rn "internalQuery\|internalMutation\|internalAction" convex/ --include="*.ts" 2>/dev/null | wc -l

# Validator coverage
grep -rn "args: {" convex/ --include="*.ts" | wc -l
grep -rn "returns:" convex/ --include="*.ts" | wc -l

# Anti-patterns
grep -rn "v\\.string()" convex/ --include="*.ts" | grep -i "id\b"   # FK as string instead of v.id()
grep -rn "ctx\\.db\\.query.*\\.filter(" convex/ --include="*.ts"   # filter without index
grep -rn "fetch(" convex/ --include="*.ts" | grep -v "action"      # fetch outside action
grep -rn "ctx\\.auth\\.getUserIdentity" convex/ --include="*.ts" | head -5  # null check audit

# Client consumption
grep -rn "useQuery\|useMutation\|useAction\|usePaginatedQuery" --include="*.tsx" | head -10
grep -rEn "useQuery\(.*['\"]skip['\"]" --include="*.tsx"  # skip pattern
```

### Extract NestJS Patterns
```bash
# Find modules
grep -rn "@Module({" --include="*.module.ts"

# Find controllers
grep -rn "@Controller(" --include="*.controller.ts"

# Find services
grep -rn "@Injectable()" --include="*.service.ts"

# Find DTOs
find . -path "*/dto/*.ts" -o -name "*dto.ts"

# Find route decorators
grep -rn "@Get(\|@Post(\|@Put(\|@Delete(" --include="*.ts"
```

### Extract Constants and Enums
```bash
# Find const exports
grep -rn "^export const" --include="*.ts"

# Find traditional enums
grep -rn "^export enum" --include="*.ts"

# Find string literal unions (modern approach)
grep -rn "export type.*= '.*' |" --include="*.ts"
```

## Directory Structure Analysis

### Common Directories
```bash
# Find directory structure
tree -d -L 3 src/ 2>/dev/null || find src/ -type d -maxdepth 3 2>/dev/null

# Find specific directories
find . -type d -name "components" -o -name "lib" -o -name "types" -o -name "app"

# List files in key directories
ls -la src/types/ 2>/dev/null
ls -la src/lib/ 2>/dev/null
ls -la src/components/ 2>/dev/null
ls -la app/ 2>/dev/null
```

### File Organization
```bash
# Count files by type
find src/ -name "*.tsx" | wc -l
find src/ -name "*.ts" | wc -l

# Find barrel files (index.ts)
find . -name "index.ts" -o -name "index.tsx"

# Find test files
find . -name "*.test.ts" -o -name "*.spec.ts"
```

## Reading Code

Use the Read tool to examine files:

```
Read(file_path)
```

Then extract relevant code sections using line numbers from grep results.

## Pattern Grouping

After extracting, group similar patterns:
1. Read multiple example files
2. Identify common structure
3. Note variations
4. Count usage frequency
5. Compare with industry standards

## Framework Detection

### Detect React
```bash
# Check package.json
grep "\"react\":" package.json

# Find JSX/TSX files
find . -name "*.tsx" | head -5
```

### Detect Next.js
```bash
# Check for Next.js
grep "\"next\":" package.json

# Find App Router
find . -type d -name "app" -path "*/src/app" -o -path "*/app"

# Find Next config
find . -name "next.config.*"
```

### Detect React Native / Expo
```bash
# RN core
grep "\"react-native\":" package.json

# Expo (managed)
grep "\"expo\":" package.json

# Expo Router
grep "\"expo-router\":" package.json

# Config files
find . -maxdepth 2 -name "app.json" -o -name "app.config.*" -o -name "metro.config.*"

# Platform-specific files (strong RN signal)
find . -name "*.ios.tsx" -o -name "*.android.tsx" -o -name "*.native.tsx" 2>/dev/null | head -5

# EAS
test -f eas.json && echo "EAS configured"
```

### Detect Convex
```bash
grep "\"convex\":" package.json
test -d convex && echo "convex/ dir present"
test -f convex/schema.ts && echo "convex schema defined"
```

### Detect Observability
```bash
# Sentry RN
grep "\"@sentry/react-native\":" package.json
grep -rn "Sentry\.init" --include="*.ts" --include="*.tsx" | head -3

# PostHog RN (no dedicated module yet — flag in conventions)
grep "\"posthog-react-native\":" package.json
grep -rn "PostHogProvider\|usePostHog" --include="*.tsx" | head -3
```

### Detect Tooling (Bun / Biome — affects conventions doc)
```bash
test -f bun.lockb && echo "package manager: Bun"
test -f pnpm-lock.yaml && echo "package manager: pnpm"
test -f yarn.lock && echo "package manager: Yarn"
test -f package-lock.json && echo "package manager: npm"

test -f biome.json -o -f biome.jsonc && echo "linter/formatter: Biome"
test -f .eslintrc.json -o -f .eslintrc.js -o -f eslint.config.js && echo "linter: ESLint"
test -f .prettierrc -o -f .prettierrc.json && echo "formatter: Prettier"

test -f lefthook.yml -o -f lefthook.yaml && echo "git hooks: Lefthook"
test -d .husky && echo "git hooks: Husky"
```

### Detect NestJS
```bash
# Check for NestJS packages
grep "@nestjs" package.json

# Find nest-cli.json
find . -name "nest-cli.json"

# Find module files
find . -name "*.module.ts"
```

### Detect State Management
```bash
# Zustand
grep "\"zustand\":" package.json

# Redux
grep "\"@reduxjs/toolkit\"\|\"redux\"" package.json

# MobX
grep "\"mobx\":" package.json
```

### Detect Styling
```bash
# Tailwind CSS (web)
grep "\"tailwindcss\":" package.json
find . -name "tailwind.config.*"

# NativeWind (Tailwind for RN)
grep "\"nativewind\":" package.json

# Tamagui (RN + web style-props)
grep "\"tamagui\":\|\"@tamagui/" package.json
find . -name "tamagui.config.*"

# Styled Components
grep "\"styled-components\":" package.json

# Emotion
grep "\"@emotion\":" package.json
```

### Detect Validation
```bash
# Zod
grep "\"zod\":" package.json

# Yup
grep "\"yup\":" package.json

# Joi
grep "\"joi\":" package.json

# class-validator (NestJS)
grep "\"class-validator\":" package.json
```

## Output Format

Return extracted patterns as:

```json
{
  "patternName": "React Component Declaration",
  "variations": [
    {
      "id": "A",
      "description": "Named function export with props interface",
      "files": ["components/Button.tsx:15", "components/Card.tsx:8"],
      "count": 45,
      "example": "export function Button({ variant, size }: ButtonProps) { ... }"
    },
    {
      "id": "B",
      "description": "Default export (anti-pattern)",
      "files": ["components/OldButton.tsx:5"],
      "count": 3,
      "example": "export default function Button() { ... }"
    }
  ],
  "recommendation": "Use variation A (named function exports)"
}
```

## Language-Specific Considerations

### TypeScript vs JavaScript
```bash
# Check if project uses TypeScript
find . -name "tsconfig.json"

# Check strictness level
grep "\"strict\":" tsconfig.json

# Find any JavaScript files
find src/ -name "*.js" -o -name "*.jsx"
```

### Module System
```bash
# ESM imports
grep -rn "^import.*from" --include="*.ts" | head -5

# CommonJS (legacy)
grep -rn "require(" --include="*.ts" | head -5
grep -rn "module.exports\|exports\\." --include="*.ts"
```

## Best Practices Checks

### Check for Anti-Patterns
```bash
# Check for 'any' type usage
grep -rn ": any\|<any>" --include="*.ts" --include="*.tsx"

# Check for inline styles
grep -rn "style={{" --include="*.tsx"

# Check for traditional enums
grep -rn "^enum " --include="*.ts"

# Check for missing type imports
grep -rn "^import {.*[A-Z]" --include="*.tsx" | grep -v "import type"
```

### Check for Good Patterns
```bash
# Check for path aliases usage
grep -rn "from ['\"]@/" --include="*.ts" --include="*.tsx" | wc -l

# Check for type-only imports
grep -rn "import type {" --include="*.ts" --include="*.tsx" | wc -l

# Check for cn() usage
grep -rn "cn(" --include="*.tsx" | wc -l
```
