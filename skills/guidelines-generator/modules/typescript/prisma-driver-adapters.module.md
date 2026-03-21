---
module: prisma-driver-adapters
language: typescript
category: orm
requires: [typescript-conventions]
conflicts: []
---

# Prisma 7 Driver Adapters Module

## Detection

```bash
grep "\"@prisma/client\":" package.json
grep "\"prisma\":" package.json
find . -name "schema.prisma" -exec grep "engineType" {} \;
grep "\"@prisma/adapter-" package.json
```

## Pattern Extraction Commands

```bash
# Check engineType in schema
find . -name "schema.prisma" -exec grep "engineType" {} \;

# Check for custom output path
find . -name "schema.prisma" -exec grep "output" {} \;

# Detect adapter usage in service files
grep -rn "PrismaPg\|PrismaNeon\|PrismaPlanetscale" --include="*.ts" | grep -v node_modules

# Find utility functions using PrismaClient
grep -rn "prisma: PrismaClient" --include="*.ts" | grep -v node_modules

# Check tsconfig paths for @prisma/client alias
grep -A 5 "\"paths\":" tsconfig.json | grep "@prisma/client"

# Violations: engineType = "library"
find . -name "schema.prisma" -exec grep "engineType.*library" {} \;

# Violations: PrismaService without adapter
grep -A 10 "extends PrismaClient" --include="*.service.ts" -r | grep -L "adapter"
```

## Standards

| Component | Required Pattern | Anti-Pattern |
|-----------|------------------|--------------|
| Schema | `engineType = "client"` | `engineType = "library"` |
| Schema | `output = "../generated/prisma"` | No custom output path |
| Service | `new PrismaPg()` in constructor | `super()` without adapter |
| tsconfig.json | `"@prisma/client": ["generated/prisma/client"]` | No path alias |
| Utility functions | `PrismaClient \| PrismaTransactionClient` | `PrismaClient` only |

## Non-Obvious Anti-Patterns

```typescript
// PrismaService extending without adapter (looks normal, breaks $transaction)
@Injectable()
export class PrismaService extends PrismaClient {
  constructor() {
    super({
      log: ['query', 'info', 'warn', 'error'],
    });  // ❌ Missing adapter - $transaction will fail silently in production
  }
}
// Fix: Pass adapter instance to super()

// Utility functions typed as PrismaClient failing inside transactions
import { PrismaClient } from '@prisma/client';

export async function generateNumber(
  prisma: PrismaClient,  // ❌ Type too narrow - fails when called with tx
  type: string
): Promise<string> {
  return await prisma.$transaction(async (tx) => {
    // $transaction may not exist on adapter-backed client
  });
}
// Fix: Accept PrismaClient | PrismaTransactionClient and check for $transaction

// Missing tsconfig path alias (module resolution fails)
// tsconfig.json without paths
{
  "compilerOptions": {
    // ❌ No "@prisma/client" alias - imports fail
  }
}
// Fix: Add path alias to generated client

// engineType = "library" silently breaking driver adapters
generator client {
  provider   = "prisma-client-js"
  engineType = "library"  // ❌ Incompatible with adapters - no error, just broken behavior
}
// Fix: Use engineType = "client"

// Value import instead of type import in utilities
import { PrismaClient } from '@prisma/client';  // ❌ Bundle size impact
export function util(prisma: PrismaClient) {}
// Fix: import type { PrismaClient }
```

## Schema Template

```prisma
generator client {
  provider   = "prisma-client-js"
  output     = "../generated/prisma"
  engineType = "client"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

## PrismaService Template

```typescript
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call
    const adapter = new PrismaPg({
      connectionString: process.env.DATABASE_URL as string,
    });

    super({
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      adapter,
      log:
        process.env.NODE_ENV === 'development'
          ? ['query', 'info', 'warn', 'error']
          : ['warn', 'error'],
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

## Transaction-Aware Utility Template

```typescript
import type { PrismaClient } from '@prisma/client';

type PrismaTransactionClient = Omit<
  PrismaClient,
  '$connect' | '$disconnect' | '$on' | '$transaction' | '$use' | '$extends'
>;

export async function generateNumber(
  prisma: PrismaClient | PrismaTransactionClient,
  type: string
): Promise<string> {
  // Check if we're already in a transaction
  if (!('$transaction' in prisma)) {
    // Inside transaction - use prisma directly
    const seq = await prisma.numberSequence.update({
      where: { type },
      data: { currentNum: { increment: 1 } },
    });
    return formatNumber(seq);
  }

  // Outside transaction - create one
  return await prisma.$transaction(async (tx) => {
    const seq = await tx.numberSequence.update({
      where: { type },
      data: { currentNum: { increment: 1 } },
    });
    return formatNumber(seq);
  });
}
```

## tsconfig.json Paths

```json
{
  "compilerOptions": {
    "paths": {
      "@prisma/client": ["generated/prisma/client"]
    }
  }
}
```

## Validation Checklist

- [ ] Schema has `engineType = "client"`
- [ ] Schema has custom `output` path
- [ ] PrismaService passes adapter to `super()`
- [ ] tsconfig.json has `@prisma/client` path alias
- [ ] Utility functions accept both PrismaClient and transaction client
- [ ] `bun prisma generate` completes without errors
- [ ] No `$transaction is not a function` errors in runtime

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/prisma-docker-setup.md` — Docker configuration, hot-reload setup, volume mounts
- `reference/prisma-testing.md` — Bun test runner mocking, adapter mocking, jest.mock() factory functions
