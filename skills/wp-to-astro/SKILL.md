---
name: wp-to-astro
description: Converts a WordPress site export into an Astro static site. Scaffolds Astro project, migrates content, components, images, and SEO from WP data. Use when user asks to "migrate wordpress to astro", "convert wp export", "build astro from wordpress", "migrate wp site".
argument-hint: <wp-export-path> <target-directory>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
context: fork
user-invocable: true
---

# WP to Astro

## Purpose

Convert a WordPress site export into a production-ready Astro static site with Tailwind v4, React islands, SEO, blog, and CTA funnel preservation.

## Variables

USER_INPUT: $ARGUMENTS
WP_EXPORT: $0
TARGET_DIR: $1
WORKFLOWS: ${CLAUDE_SKILL_DIR}/workflows

## Instructions

### Prerequisites
- Run `wp-audit` on the WP export first. This skill depends on wp-audit output.
- If wp-audit has not been run, run it now before proceeding: invoke `wp-audit <WP_EXPORT>`.
- Load the wp-audit findings (structured JSON or markdown report) before any phase.

### Content Rules
- NEVER fabricate content: no invented stats, fake tenure claims, placeholder labels.
- NEVER use placeholder phone/email — extract real contact data from wp-audit findings.
- NEVER consolidate CTA sections — preserve the Value → CTA → Value → CTA funnel pattern exactly.
- OG images and JSON-LD MUST use absolute URLs matching the actual site domain from wp-audit.

### Technical Rules
- Tailwind v4: use `@tailwindcss/vite` plugin in `vite.plugins` and `@import "tailwindcss"` in CSS. Do NOT use `@astrojs/tailwind` (deprecated).
- ContactForm must be a React island with `client:visible`. Do not duplicate section wrappers.
- CTA button text should vary — mix value-focused and action-focused wording.
- All images: copy originals from WP uploads only (skip thumbnails).

## Workflow

### Phase 1: Audit & Extract
**Read:** `${WORKFLOWS}/phase-1-audit-extract.md`

1. Confirm wp-audit output is available; if not, invoke wp-audit first.
2. Extract: site domain, contact data, GTM ID, CTA URLs, page structure, section order.
3. Inventory: images (originals only), blog posts, nav items, cross-sell references.

### Phase 2: Scaffold Astro Project
**Read:** `${WORKFLOWS}/phase-2-scaffold.md`

1. Init Astro project in TARGET_DIR with Bun.
2. Install: `astro`, `@astrojs/react`, `@astrojs/sitemap`, `@astrojs/mdx`, `@tailwindcss/vite`, `tailwindcss`, `react`, `react-dom`.
3. Configure `astro.config.mjs`: react(), sitemap(), mdx() integrations; `@tailwindcss/vite` in vite.plugins; set `site` URL.
4. Create `src/styles/global.css` with `@import "tailwindcss"`.

### Phase 3: Layout & SEO
**Read:** `${WORKFLOWS}/phase-3-layout-seo.md`

1. Create `src/layouts/Layout.astro` with: title/description/canonical/robots meta, Open Graph (absolute URLs), Twitter card, JSON-LD structured data, GTM script, global CSS import, favicon.
2. Create Navbar and Footer components using real nav items and contact data.
3. Create mobile sticky bar (Call + WhatsApp) and floating WhatsApp button using real wa.link URL.

### Phase 4: Pages & Components
**Read:** `${WORKFLOWS}/phase-4-pages-components.md`

1. Map each Elementor section → Astro component, preserving exact section order.
2. Create reusable `CtaStrip` component with tracked CTA URLs from wp-audit.
3. Preserve cross-sell sections linking to other projects if present in original.
4. Create `src/pages/404.astro`.

### Phase 5: Blog & Images
**Read:** `${WORKFLOWS}/phase-5-blog-images.md`

1. Copy original images from WP uploads to `public/images/` (skip thumbnails).
2. Set up blog content collection: `src/content.config.ts` with glob loader.
3. Create `src/pages/blog/[slug].astro` and `src/pages/blog/index.astro` (both include Navbar and Footer).
4. Migrate WP posts as MDX files in `src/content/blog/`.

### Phase 6: Build & Verify
1. Run `bun run build` in TARGET_DIR.
2. Fix any build errors before reporting done.

## Supporting Files

- `workflows/phase-1-audit-extract.md` - wp-audit loading and data extraction
- `workflows/phase-2-scaffold.md` - Astro project init and dependency setup
- `workflows/phase-3-layout-seo.md` - Layout, SEO meta, GTM, navigation
- `workflows/phase-4-pages-components.md` - Component mapping and CTA preservation
- `workflows/phase-5-blog-images.md` - Blog collection and image migration

## Report

- Show generated file tree of TARGET_DIR (top 2 levels)
- Confirm: build passed, pages created, images copied, blog posts migrated
- List any manual steps remaining (e.g. verify GTM ID, test contact form)
