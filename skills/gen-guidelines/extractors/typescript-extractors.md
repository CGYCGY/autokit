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
# Tailwind CSS
grep "\"tailwindcss\":" package.json
find . -name "tailwind.config.*"

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
