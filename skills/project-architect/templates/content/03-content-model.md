# Content Model

Astro Content Collections. Each collection has a Zod schema in `src/content/config.ts` and content files (MDX/Markdown) in `src/content/{collection}/`.

## Collections Overview

| Collection | Purpose | Format |
|---|---|---|
| | | MDX / Markdown |

## Collection Schemas
<!-- Repeat per collection. -->

### Collection: [name]

**Path:** `src/content/[name]/`
**Format:** MDX / Markdown

| Frontmatter field | Zod type | Required | Notes |
|---|---|---|---|
| title | z.string() | Yes | |
| description | z.string() | Yes | SEO |
| publishedAt | z.coerce.date() | Yes | |
| | | | |

#### Slug Strategy
<!-- File-based by default. Override in collection config if needed. -->

## References Between Collections
<!-- e.g., a "post" referencing an "author" via `reference("authors")`. -->

| From | Field | To |
|---|---|---|
| | | |

## Asset Strategy
<!-- Where images/videos live, optimization approach (Astro Image, Sharp). -->

## SEO Defaults
<!-- Site-wide title template, OG defaults, sitemap, robots. -->
