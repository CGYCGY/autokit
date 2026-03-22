# Theme System Review

## What This Checks

Theme architecture, semantic token usage, dark mode contrast, and config alignment.

## 1. Theme Architecture

### Rules
- ThemeProvider must be centralized — one provider, not scattered theme logic in components
- Theme toggle must sync both `data-theme` attribute AND `.dark` class on `<html>` for Tailwind compatibility
- ThemeProvider must wrap above the router so all pages (login, error, etc.) receive theme context

### How to Check
1. Search for ThemeProvider: `grep -r "ThemeProvider\|useTheme\|data-theme" src/`
2. Read the ThemeProvider implementation — verify it sets both `data-theme` and `.dark` class
3. Read the root entry point (App.tsx / main.tsx) — verify ThemeProvider wraps above the router
4. Search for competing theme logic: `grep -rn "applyTheme\|setTheme\|toggleTheme" src/ --include="*.tsx"` — should only appear in ThemeProvider

### Anti-patterns
- Theme state owned by a layout component instead of a dedicated provider
- Components that import theme colors directly or contain inline dark/light conditionals
- Multiple theme contexts or providers
- Login/error pages rendering outside the theme context

## 2. Semantic Tokens

### Rules
- Zero hardcoded Tailwind color classes in component files (`.tsx`, `.jsx`)
- Zero `dark:` overrides in component files — all dark mode colors controlled from CSS variables
- All color definitions live in one CSS file via `:root` / `[data-theme="dark"]` / `.dark` selectors

### Search Patterns (violations)
```
# Hardcoded color classes
text-(stone|gray|slate|zinc|neutral|red|blue|green|yellow|orange|purple|pink|amber|emerald|teal|cyan|sky|indigo|violet|fuchsia|rose|lime)-\d+
bg-(stone|gray|slate|zinc|neutral|red|blue|green|yellow|orange|purple|pink|amber|emerald|teal|cyan|sky|indigo|violet|fuchsia|rose|lime)-\d+
border-(stone|gray|slate|zinc|neutral|red|blue|green|yellow|orange|purple|pink|amber|emerald|teal|cyan|sky|indigo|violet|fuchsia|rose|lime)-\d+

# dark: overrides in components
dark: prefix in any .tsx/.jsx file
```

### Correct Tokens
| Need | Use |
|---|---|
| Primary text | `text-foreground` |
| Secondary/muted text | `text-muted-foreground` |
| Primary brand color | `text-primary` |
| Page background | `bg-background` |
| Card/panel background | `bg-card` |
| Subtle background | `bg-secondary` |
| Borders/dividers | `border-border` or `bg-border` |
| Input borders | `border-input` |
| Hover background | `hover:bg-secondary` |
| Hover text | `hover:text-foreground` |

## 3. Dark Mode Contrast (WCAG AA)

### Rules
- Normal text: minimum 4.5:1 contrast ratio
- Large text (18px+ or 14px+ bold): minimum 3:1
- Flag any HSL foreground token in dark theme with lightness below 55%

### Common Failure Points
- Sidebar navigation text against sidebar background
- Section labels (small uppercase text)
- Card subtitles and "vs last week" style secondary text
- `--muted-foreground` values — often set too low
- Placeholder text and disabled states
- Logo text parts that use foreground instead of a visible color

### How to Check
1. Read dark mode CSS variable definitions
2. For each foreground token, check lightness value:
   - `--foreground`: should be 85%+ lightness
   - `--muted-foreground`: should be 60%+ lightness
   - `--secondary-foreground`: should be 80%+ lightness
   - `--card-foreground`: should be 85%+ lightness
3. Check `--border` lightness — should be 25%+ for card/page separation visibility

## 4. Config Alignment

### Rules
- `tailwind.config` `darkMode` must match ThemeProvider's DOM mechanism
- CSS variable selectors must match too
- All three must agree: Tailwind config, ThemeProvider, CSS selectors

### Alignment Matrix
| ThemeProvider sets | tailwind.config darkMode | CSS selector |
|---|---|---|
| `.dark` class | `["class"]` | `.dark { ... }` |
| `data-theme` attr | `["selector", '[data-theme="dark"]']` | `[data-theme="dark"] { ... }` |
| Both (recommended) | `["class"]` | `[data-theme="dark"], .dark { ... }` |

### Also Verify
- `theme.extend.colors` in Tailwind config references CSS variables (`hsl(var(--primary))`) not hardcoded hex/rgb values

## Severity Levels

| Severity | Condition |
|---|---|
| Critical | Theme toggle broken (class/attr mismatch), config misalignment, ThemeProvider missing |
| Warning | Hardcoded colors in components, `dark:` overrides, contrast below WCAG AA |
| Info | Minor token inconsistencies, contrast borderline (4.5-5:1) |
