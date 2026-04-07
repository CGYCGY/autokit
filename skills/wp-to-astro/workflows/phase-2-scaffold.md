# Phase 2: Scaffold Astro Project

## Goal

Initialize a fresh Astro project in TARGET_DIR with all required integrations and Tailwind v4 setup.

## Steps

### 1. Initialize Astro

```bash
cd <TARGET_DIR_PARENT>
bun create astro@latest <TARGET_DIR_BASENAME> -- --template minimal --no-install --no-git
cd <TARGET_DIR>
```

If TARGET_DIR already exists and has files, skip init and proceed to dependency install.

### 2. Install Dependencies

```bash
bun add astro @astrojs/react @astrojs/sitemap @astrojs/mdx react react-dom
bun add -d @tailwindcss/vite tailwindcss
```

### 3. Configure astro.config.mjs

Write `astro.config.mjs` with:

```js
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import mdx from '@astrojs/mdx';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: '<SITE_DOMAIN>',  // from wp-audit: site_domain
  integrations: [react(), sitemap(), mdx()],
  vite: {
    plugins: [tailwindcss()],
  },
});
```

### 4. Create Global CSS

Write `src/styles/global.css`:

```css
@import "tailwindcss";
```

Do NOT use `@tailwind base;` / `@tailwind components;` / `@tailwind utilities;` — that is Tailwind v3 syntax.
Do NOT install or reference `@astrojs/tailwind` — it is deprecated.

### 5. TypeScript Config

Ensure `tsconfig.json` has `"strictNullChecks": true` and `"jsx": "react-jsx"` in compilerOptions.

### 6. Create Directory Structure

```
src/
  components/
  layouts/
  pages/
    blog/
  content/
    blog/
  styles/
    global.css
public/
  images/
```
