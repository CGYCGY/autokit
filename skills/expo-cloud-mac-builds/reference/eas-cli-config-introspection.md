# Env Validation Under eas-cli Config Introspection

## Symptom
`eas build`, `eas update`, `eas init`, or any eas-cli command throws from env-validation code (a Zod env schema, t3-env) while merely reading `app.config.ts` — before any build or bundling. The same vars are present at real runtime / on the build server; only the eas-cli introspection step fails. Surfaces as `expo config --json exited with non-zero code: 1`.

## Root cause
eas-cli evaluates the app config to introspect it (project id, runtime version, plugins) WITHOUT loading `.env*` files, so validation at config-eval time sees the vars as missing. There are TWO distinct introspection paths and they identify themselves differently:
- A spawned `expo config` subprocess: eas-cli sets `EXPO_NO_DOTENV` in its env.
- An in-process `@expo/config` read inside the eas-cli process itself: `EXPO_NO_DOTENV` is NOT set here — only `process.argv` (the eas-cli binary path) reveals the context.

This is why a first fix that only checks `EXPO_NO_DOTENV` works for `eas build` but still throws on `eas init` — the in-process path slips through.

## Fix
Warn-not-throw when EITHER signal indicates eas-cli; only collect issues and `console.warn`. Keep throwing in the real app and in normal local config reads so genuinely-missing vars fail loudly.

Detection: OR, not AND — either path alone must trigger the softening.
- `process.env.EXPO_NO_DOTENV` is set (the subprocess path), OR
- `process.argv` path contains an `eas` / `eas-cli` segment (the in-process path).

```ts
const underEasCli =
  !!process.env.EXPO_NO_DOTENV ||
  (process.argv[1] ?? "")
    .split(/[\\/]/)
    .some((seg) => seg === "eas" || seg === "eas-cli");
// when true: collect validation issues and console.warn instead of throwing
```

- Match argv segments exactly (`seg === "eas"`), not substring `.includes("eas")` — a path like `/Users/.../leasehold/...` would false-positive on a loose contains.
- Don't reduce this to AND to "be safe": the in-process read has no `EXPO_NO_DOTENV`, so AND silently reverts to throwing on `eas init`/`eas update`.
