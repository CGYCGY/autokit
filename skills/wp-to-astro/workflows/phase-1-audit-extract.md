# Phase 1: Audit & Extract

## Goal

Load wp-audit output and extract all structured data needed for migration.

## Steps

### 1. Locate wp-audit Output

Check for wp-audit report in these locations (in order):
1. `<WP_EXPORT>/wp-audit-report.json`
2. `<WP_EXPORT>/wp-audit-report.md`
3. Any `wp-audit*.json` or `wp-audit*.md` in WP_EXPORT directory

If not found: invoke the `wp-audit` skill with WP_EXPORT path before continuing.

### 2. Extract Required Data

From wp-audit output, collect and store the following for use in later phases:

**Site Identity**
- `site_domain`: Canonical site URL (e.g. `https://example.com`) — used for absolute OG/JSON-LD URLs
- `site_name`: Business name
- `site_tagline`

**Contact Data** (must be real — never fabricated)
- `phone`: Primary phone number
- `whatsapp`: WhatsApp number (digits only for wa.link)
- `whatsapp_url`: Full `wa.link/...` URL
- `email`: Contact email

**Tracking & Analytics**
- `gtm_id`: Google Tag Manager container ID (e.g. `GTM-XXXXXX`)

**Page Structure**
- `nav_items`: Array of {label, href} for navigation
- `pages`: Array of page objects with section order preserved
- `section_order`: Per-page list of Elementor sections in render order

**CTA Data**
- `cta_urls`: All tracked CTA URLs (wa.link, tel:, mailto:)
- `cta_texts`: Original button labels (preserve for variation)

**Assets**
- `image_paths`: Full paths to original uploads (exclude thumbnails — those end in `-NNNxNNN.ext`)
- `post_count`: Number of blog posts to migrate

**Cross-sell**
- `crosssell_sections`: Any sections referencing other projects/sites

### 3. Validate Completeness

Before proceeding to Phase 2, confirm all required fields are populated:
- `site_domain`, `site_name`, `phone`, `whatsapp_url`, `gtm_id`

If any are missing: search WP export XML/JSON directly for the values, or note as "requires manual fill" in the report.
