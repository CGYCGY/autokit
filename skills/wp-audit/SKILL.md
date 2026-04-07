---
name: wp-audit
description: Audits a WordPress site export (files/ + sqldump.sql + meta.json) and produces a structured report covering SEO, content, plugins, and sales funnel elements. Use when user asks to "audit wordpress export", "analyze wp export", "review wordpress content", "inspect wp dump", or points to a WP export folder.
argument-hint: <wp-export-directory>
allowed-tools: Read, Bash, Grep, Glob
user-invocable: true
---

# WP Audit

## Purpose

Analyze a WordPress export directory (files/, sqldump.sql, meta.json) and output a structured audit report covering site config, SEO health, published content, plugins, Elementor page structure, contact data, CTA/funnel patterns, and images.

## Variables

EXPORT_DIR: $ARGUMENTS
WORKFLOWS: ${CLAUDE_SKILL_DIR}/workflows

## Instructions

- Output the report as text to the conversation — do not write any files.
- If EXPORT_DIR is not provided, ask the user for the path before proceeding.
- SQL dump lines are extremely long — always use Bash (grep, node) to extract data, never the Read tool on sqldump.sql.
- Elementor JSON is MySQL-escaped inside INSERT lines — unescape before parsing.
- Flag any claim that cannot be verified from the export data — do not fabricate.
- Cross-reference phone numbers found across Chaty, Click-to-Chat, and form configs.

## Workflow

### Phase 1: Parse Export Structure

**Read:** `${CLAUDE_SKILL_DIR}/workflows/parse-structure.md`

1. Confirm EXPORT_DIR exists with expected artifacts (meta.json, sqldump.sql, files/).
2. Parse meta.json for DB prefix, site paths, credentials context.
3. Extract core wp_options: siteurl, home, blogname, blogdescription, permalink_structure, blog_public, show_on_front, page_on_front.

### Phase 2: SEO Audit

**Read:** `${CLAUDE_SKILL_DIR}/workflows/seo-audit.md`

1. Extract Yoast config options: wpseo, wpseo_titles, wpseo_social.
2. Check noindex flags, missing meta descriptions, social profiles, schema type, XML sitemap.
3. Extract per-page Yoast meta (_yoast_wpseo_title, _yoast_wpseo_metadesc, _yoast_wpseo_focuskw) for all published pages/posts.

### Phase 3: Content & Plugin Inventory

**Read:** `${CLAUDE_SKILL_DIR}/workflows/content-plugins.md`

1. Count published content by post_type (pages, posts, products, etc.).
2. Extract active_plugins list from wp_options.
3. Check robots.txt, .htaccess in files/. Check GA/GTM in theme header.php.
4. Check coming-soon/maintenance mode: seedprod_settings option.

### Phase 4: Elementor Page Map

**Read:** `${CLAUDE_SKILL_DIR}/workflows/elementor-map.md`

1. Extract _elementor_data for the homepage post ID (page_on_front).
2. Parse widget sequence in order: types, titles, editor text, images, links/URLs (especially wa.link tracking URLs), video embeds (Vimeo/YouTube).
3. Produce a Content Map showing section order.

### Phase 5: Contact Data & CTA Analysis

**Read:** `${CLAUDE_SKILL_DIR}/workflows/contact-cta.md`

1. Extract Chaty config (cht_social_phone, cht_social_whatsapp).
2. Extract Click-to-Chat config (ht_ctc_chat_options: phone, pre-filled message).
3. Extract FluentForm config: notification email, form fields/options.
4. Inventory CTAs from Elementor: count, link targets, tracking URL variety.

### Phase 6: Migration Risk Score

**Read:** `${CLAUDE_SKILL_DIR}/workflows/migration-risks.md`

1. Score migration complexity across 8 factors: page builder, WooCommerce, shortcodes, hard-coded URLs, content volume, multi-language, custom post types, forms.
2. Produce an overall risk level (Low / Medium / High) with a summary table.

### Phase 7: Images

**Read:** `${CLAUDE_SKILL_DIR}/workflows/images.md`

1. List original uploaded images — skip thumbnails (files matching -NNNxNNN dimension patterns).
2. Distinguish images referenced in Elementor data vs only present in media library.

## Supporting Files

- `workflows/parse-structure.md` - Export validation, meta.json parsing, core wp_options extraction
- `workflows/seo-audit.md` - Yoast option extraction and per-page meta audit
- `workflows/content-plugins.md` - Post counts, plugin list, robots/GA/coming-soon checks
- `workflows/elementor-map.md` - Elementor JSON extraction, unescaping, widget sequence parsing
- `workflows/contact-cta.md` - Chaty, Click-to-Chat, FluentForm extraction; CTA inventory
- `workflows/migration-risks.md` - Migration complexity scoring across 8 factors
- `workflows/images.md` - Media library listing, thumbnail filtering, Elementor cross-reference

## Report

Output a single Markdown report with these sections in order:

1. **Site Overview** — blogname, siteurl, tagline, permalink structure, coming-soon status
2. **Published Content** — post_type counts table
3. **SEO Audit** — Yoast config summary + flagged issues (noindex, missing metas, empty socials, schema, sitemap)
4. **Plugin Analysis** — active plugins list; flag SEO, page-builder, chat, forms, analytics plugins
5. **Content Map** — homepage section order from Elementor (widget type + heading/label per section)
6. **Contact Data Found** — phone numbers (cross-referenced), WhatsApp, notification email, pre-filled message
7. **CTA / Funnel Analysis** — CTA count, link targets, tracking URL types, funnel assessment
8. **Migration Risk Score** — overall risk level (Low/Medium/High) with per-factor breakdown table
9. **Images Available** — original image list; note Elementor-referenced vs media-only
10. **Recommendations** — flagged issues with suggested fixes; note anything unverifiable from export data
