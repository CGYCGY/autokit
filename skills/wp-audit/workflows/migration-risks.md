# Migration Risk Scoring

## Purpose

Score the complexity of migrating this WordPress site to a static framework (e.g., Astro). Produces a risk level (Low / Medium / High) with specific flags.

## Procedure

### 1. Check Page Builder

Grep active_plugins for page builders:

| Plugin | Risk | Reason |
|---|---|---|
| `elementor` | Medium | Content in proprietary JSON, extractable but requires parsing |
| `wpbakery` / `js_composer` | High | Shortcode-based, no structured data to parse |
| `divi` | High | Proprietary shortcodes + builder format |
| `beaver-builder` | High | Custom modules, no standard extraction |
| None (Gutenberg only) | Low | Block content is mostly HTML |

### 2. Check WooCommerce

Grep active_plugins for `woocommerce`:
- **If found:** flag High — static sites can't handle cart/checkout natively. Check product count in published posts. Note: if products are few and site is primarily a landing page, downgrade to Medium.
- **If not found:** no flag.

### 3. Check Shortcode Usage

Search post_content in the posts INSERT for shortcode patterns `\[[\w]+`:
- Count unique shortcode tags
- **0 shortcodes:** Low
- **1-5 shortcodes from known plugins (contact-form-7, gallery, etc.):** Medium — need manual replacement
- **6+ or custom shortcodes:** High — significant manual work

### 4. Check Hard-coded URLs

Search post_content and _elementor_data for the site domain:
- Count occurrences of the siteurl domain in content
- **0-10:** Low — minimal search-replace needed
- **11-50:** Medium
- **50+:** High — extensive content rewriting

### 5. Check Content Volume

From the published content counts:
- **1-5 pages, 0 posts:** Low — small site, quick migration
- **5-20 pages, 0-10 posts:** Medium
- **20+ pages or 10+ posts:** High — significant content to migrate

### 6. Check Multi-language

Grep active_plugins for `polylang`, `wpml`, `translatepress`:
- **If found:** High — need to handle language routing, translated content pairs
- **If not found:** no flag

### 7. Check Custom Post Types

From the post_type counts, identify non-standard types (not page/post/attachment/revision/nav_menu_item):
- **0 custom types:** Low
- **1-3 custom types with few entries:** Medium
- **4+ custom types or types with many entries:** High — complex content model

### 8. Check Forms

Grep active_plugins for form plugins (fluentform, contact-form-7, wpforms, gravityforms, forminator):
- **If found:** Medium — forms need a backend replacement (Resend, Web3Forms, etc.)
- **If not found:** Low

## Scoring

Combine all flags into a final score:

```
HIGH if:   any single flag is High
MEDIUM if: 2+ flags are Medium and none are High
LOW if:    all flags are Low or only 1 Medium flag
```

## Output Format

```
## Migration Risk Score: [HIGH / MEDIUM / LOW]

| Factor              | Risk   | Detail                              |
|---------------------|--------|-------------------------------------|
| Page Builder        | Medium | Elementor (65 widgets on homepage)  |
| WooCommerce         | —      | Not detected                        |
| Shortcodes          | Low    | 0 shortcodes in content             |
| Hard-coded URLs     | Medium | 23 domain references in content     |
| Content Volume      | Low    | 1 page, 0 posts                     |
| Multi-language      | —      | Not detected                        |
| Custom Post Types   | Low    | 0 custom content types              |
| Forms               | Medium | FluentForm detected                 |

**Overall: MEDIUM** — Elementor content extraction + form replacement needed.
```
