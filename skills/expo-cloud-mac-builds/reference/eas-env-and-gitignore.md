# EAS Build Env Vars vs .gitignore

## Symptom
A variable defined in `.env.local` (or another git-ignored env file) is `undefined` inside an EAS build, even though it works locally. Or `eas env:push` rejects a variable.

## Root cause
EAS Build uploads the project by copying it while respecting `.gitignore`. Git-ignored files — including `.env.local` — are never sent to the build worker, so any var only present there is absent at build/bundle time. EAS does not read your local dotenv files for the build.

## Fix
Push the vars into EAS environments instead of relying on local files.

```bash
# push a whole file's vars into an EAS environment
eas env:push --environment production --path .env.local
# or set individually
eas env:create --environment production --name FOO --value "bar"
```

- Vars live per EAS environment (`development` / `preview` / `production`); push to each environment the corresponding build profile uses.
- EAS rejects empty-valued vars. Any `KEY=` (no value) in the pushed file fails the push — remove the line or give it a real placeholder value before pushing.
- This is the intended split: `.env.local` for local runtime, EAS environments for build-time. Keep `.env.local` git-ignored; don't commit secrets to un-ignore them.
- After changing EAS env vars, re-run the build — values are baked at build time, not pulled live.
