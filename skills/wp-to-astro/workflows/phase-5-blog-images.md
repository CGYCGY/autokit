# Phase 5: Blog & Images

## Goal

Migrate WordPress blog posts as MDX content and copy original images to the Astro public directory.

## Steps

### 1. Copy Original Images

From `image_paths` in wp-audit (WP uploads directory):

```bash
# Copy originals only — skip thumbnails (files matching -NNNxNNN.ext pattern)
find <WP_EXPORT>/wp-content/uploads -type f \
  ! -regex '.*-[0-9]+x[0-9]+\.[a-z]+' \
  -exec cp {} <TARGET_DIR>/public/images/ \;
```

Preserve original filenames. If name collisions exist, prefix with year-month from WP upload path.

### 2. Set Up Content Collection

Create `src/content.config.ts`:

```ts
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string().optional(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    image: z.string().optional(),
  }),
});

export const collections = { blog };
```

### 3. Migrate WP Posts to MDX

For each WP blog post from wp-audit:
1. Convert post title, date, excerpt, and body to MDX frontmatter + content.
2. Save as `src/content/blog/<slug>.mdx`.
3. Update internal image references to `/images/<filename>` (matching copied files).
4. Remove WP shortcodes that have no Astro equivalent (log removed shortcodes in report).

MDX frontmatter template:
```mdx
---
title: "<POST_TITLE>"
description: "<EXCERPT>"
pubDate: <YYYY-MM-DD>
image: "/images/<FEATURED_IMAGE_FILENAME>"
---
```

### 4. Create Blog Index Page

Create `src/pages/blog/index.astro`:
- Import Layout, Navbar, Footer.
- Use `getCollection('blog')` to list all posts sorted by `pubDate` descending.
- Render title, date, description, and link for each post.

### 5. Create Blog Post Page

Create `src/pages/blog/[slug].astro`:
- Import Layout, Navbar, Footer.
- Use `getStaticPaths()` with `getCollection('blog')`.
- Render post with `<Content />` component from `entry.render()`.
- Pass post title and description to Layout for per-post SEO.
- Canonical URL: `${SITE_DOMAIN}/blog/${slug}`.
