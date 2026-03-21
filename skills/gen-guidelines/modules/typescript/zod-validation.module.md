---
module: zod-validation
language: typescript
category: validation
requires: [react-components]
conflicts: [yup, joi]
---

# Zod + React Hook Form Module

## Detection

```bash
grep "\"zod\":" package.json
grep "\"react-hook-form\":" package.json
grep -rn "zodResolver(" --include="*.tsx"
```

## Pattern Extraction Commands

```bash
# Schema patterns
grep -rn "const.*Schema = z\.object" --include="*.ts" | head -5

# Type inference usage
grep -rn "z\.infer<typeof" --include="*.ts"

# Form setup pattern
grep -A10 "useForm<" --include="*.tsx" | head -20

# Missing valueAsNumber (violations)
grep -B2 "type=\"number\"" --include="*.tsx" | grep -v "valueAsNumber"
```

## Standards

| Pattern | Standard |
|---------|----------|
| Schema naming | `{feature}Schema` suffix |
| Type derivation | `z.infer<typeof schema>` |
| Form resolver | `zodResolver(schema)` |
| Number inputs | `{ valueAsNumber: true }` |
| Error messages | Always provide custom messages |

## Non-Obvious Anti-Patterns

```typescript
// Schema vs runtime type mismatch with coercion
const schema = z.object({
  count: z.number()  // Expects number
})
<input type="number" {...register("count")} />  // ❌ Sends string!
// Fix: Use valueAsNumber OR z.coerce
<input type="number" {...register("count", { valueAsNumber: true })} />  // ✅
// OR
const schema = z.object({ count: z.coerce.number() })  // ✅ Coerces string

// Refinement running on invalid base type
const schema = z.object({
  items: z.array(z.string()).refine(
    arr => arr.length > 0,  // ❌ Runs even if items is undefined
    "At least one item"
  )
})
// Fix: Chain after type validation
const schema = z.object({
  items: z.array(z.string()).min(1, "At least one item")  // ✅
})

// watch() without dependency array causes infinite loops
const value = watch("field")
useEffect(() => {
  setValue("other", compute(value))  // ❌ setValue triggers re-render
}, [value])  // And watch returns new ref
// Fix: Use watch callback or debounce

// reset() doesn't trigger validation
reset({ field: invalidValue })  // ❌ No validation error shown
// Fix: Trigger validation after reset
reset({ field: value })
trigger()  // ✅

// Nested error access without optional chaining
{errors.items[index].name.message}  // ❌ Runtime error if undefined
{errors.items?.[index]?.name?.message}  // ✅
```

## Form Template

```typescript
const formSchema = z.object({
  name: z.string().min(1, "Name required"),
  count: z.number().min(1, "At least 1"),
})
type FormData = z.infer<typeof formSchema>

export function MyForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: { name: "", count: 1 },
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input {...register("name")} />
      {errors.name && <span className="text-destructive">{errors.name.message}</span>}
      
      <Input type="number" {...register("count", { valueAsNumber: true })} />
      {errors.count && <span className="text-destructive">{errors.count.message}</span>}
    </form>
  )
}
```

## Validation Checklist

- [ ] All `.min()/.max()/.regex()` have error messages
- [ ] Number inputs use `valueAsNumber: true` OR schema uses `z.coerce`
- [ ] Types derived with `z.infer<>`, no duplicate interfaces
- [ ] Nested error access uses optional chaining (`?.`)
- [ ] `watch()` values used carefully to avoid infinite loops

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/zod-advanced.md` — discriminated unions, transforms, custom refinements
- `reference/form-arrays.md` — useFieldArray patterns
