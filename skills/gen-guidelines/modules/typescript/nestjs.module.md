---
module: nestjs
language: typescript
category: framework
requires: [typescript-conventions]
conflicts: [nextjs-app-router, express, hono]
---

# NestJS Module

## Detection

```bash
grep "\"@nestjs/core\":" package.json
find . -name "*.module.ts" -type f | head -5
grep -rn "@Module(" --include="*.ts" | head -3
```

## Pattern Extraction Commands

```bash
# Module structure
find src/ -name "*.module.ts" 2>/dev/null

# DI patterns
grep -rn "constructor(.*private readonly" --include="*.ts" | head -10

# Violations: direct instantiation
grep -rn "= new.*Service(\|= new.*Repository(" --include="*.ts" | grep -v node_modules

# Violations: missing decorators
find . -name "*.service.ts" -exec grep -L "@Injectable" {} \;
find . -name "*.controller.ts" -exec grep -L "@Controller" {} \;

# DTO validation coverage
find . -name "*dto.ts" -exec grep -L "class-validator\|@Is\|@Min\|@Max" {} \;
```

## Standards

| File Pattern | Decorator | DI Pattern |
|--------------|-----------|------------|
| `*.module.ts` | `@Module()` | imports/providers/exports |
| `*.controller.ts` | `@Controller()` | constructor injection |
| `*.service.ts` | `@Injectable()` | constructor injection |
| `*.guard.ts` | `@Injectable()` | implements CanActivate |
| `*dto.ts` | class-validator | validation decorators |

## Non-Obvious Anti-Patterns

```typescript
// Circular dependency via forwardRef overuse
@Module({
  imports: [forwardRef(() => UsersModule)],  // ❌ Code smell if common
})
// Fix: Extract shared logic to third module, or redesign boundaries

// Provider scope mismatch
@Injectable({ scope: Scope.REQUEST })
export class RequestScopedService {}

@Injectable()  // Default: SINGLETON
export class SingletonService {
  constructor(private reqService: RequestScopedService) {}  // ❌ Singleton holds request-scoped
}
// Fix: Make consumer same or narrower scope

// Missing async in controller returning Promise
@Get()
findAll() {  // ❌ Missing async - harder to debug if throws
  return this.service.findAll()
}
@Get()
async findAll() {  // ✅ Explicit async
  return this.service.findAll()
}

// ValidationPipe transform without DTO class
app.useGlobalPipes(new ValidationPipe({ transform: true }))
@Post()
create(@Body() data: { name: string }) {  // ❌ Plain object, no class
  // data is NOT validated - needs DTO class
}
@Post()
create(@Body() data: CreateUserDto) {  // ✅ DTO class with decorators
}

// @Inject for class providers (unnecessary)
constructor(@Inject(UsersService) private usersService: UsersService) {}  // ❌ Redundant
constructor(private readonly usersService: UsersService) {}  // ✅

// Guards/interceptors not in providers array
@Module({
  providers: [UsersService],  // ❌ Missing AuthGuard
})
@Controller()
@UseGuards(AuthGuard)  // AuthGuard must be in providers OR globally registered
export class UsersController {}
```

## Main.ts Template

```typescript
import { NestFactory } from '@nestjs/core'
import { ValidationPipe } from '@nestjs/common'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }))
  
  await app.listen(3000)
}
bootstrap()
```

## DTO Template

```typescript
import { IsString, IsEmail, IsNotEmpty, MinLength } from 'class-validator'
import { PartialType } from '@nestjs/mapped-types'

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  name: string

  @IsEmail()
  email: string
}

export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

## Validation Checklist

- [ ] No `new Service()` in constructors (use DI)
- [ ] No `forwardRef` overuse (redesign if common)
- [ ] Request-scoped providers not injected into singletons
- [ ] `@Body()` uses DTO classes, not plain types
- [ ] Guards/interceptors in providers or global
- [ ] Controllers use `async` for Promise-returning methods

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/nestjs-testing.md` — Test module setup, mocking providers
- `reference/nestjs-microservices.md` — Message patterns, transports
- `reference/nestjs-graphql.md` — Resolvers, schema-first vs code-first
