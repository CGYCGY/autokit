# Codanna Setup

## Initialize and Index

```bash
codanna init
codanna index .
```

To index specific directories instead:
```bash
codanna index src lib tests
```

## Re-index After Code Changes

```bash
codanna index .
```

## Add .codanna/ to .gitignore

```bash
echo ".codanna/" >> .gitignore
```
