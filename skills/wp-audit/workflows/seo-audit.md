# SEO Audit

Extract Yoast SEO configuration and per-page meta data.

## Step 1: Yoast Global Options

Use targeted bash greps for each Yoast option (SQL lines are very long):

```bash
# Main Yoast config
grep -o "'wpseo','[^']*'" sqldump.sql

# Title/meta templates and noindex settings
grep -o "'wpseo_titles','[^']*'" sqldump.sql

# Social profiles
grep -o "'wpseo_social','[^']*'" sqldump.sql
```

The values are PHP-serialized strings. Extract key fields by pattern-matching within the serialized blob:

### From wpseo:
- `indexing_mode` — check for noindex-related values
- `xmlsitemap` — sitemap enabled (1) or disabled (0)
- `company_or_person` — schema type ("company" or "person")
- `company_name`, `company_logo` — schema org data

### From wpseo_titles:
- `noindex-post` — if "on", posts are noindexed globally
- `noindex-page` — if "on", pages are noindexed globally
- `noindex-tax-category` — categories noindexed
- `noindex-tax-post_tag` — tags noindexed
- `metadesc-home-wpseo` — homepage meta description template

### From wpseo_social:
- `facebook_site`, `twitter_site`, `instagram_url`, `linkedin_url` — check for empty values

## Step 2: Per-Page Yoast Meta

Extract postmeta rows for published posts/pages. Use bash to extract all _yoast_ postmeta:

```bash
grep "_yoast_wpseo_" sqldump.sql | grep -o "([0-9]*,'_yoast_wpseo_[^']*','[^']*')" | head -500
```

For each published page/post (from post IDs in wp_posts), collect:
- `_yoast_wpseo_title` — custom title (blank = using template)
- `_yoast_wpseo_metadesc` — custom meta description (blank = missing)
- `_yoast_wpseo_focuskw` — focus keyphrase

## Step 3: Flag Issues

Produce an issues list:

- **[CRITICAL]** `blog_public` = 0 — site set to discourage search engines
- **[CRITICAL]** `noindex-post` or `noindex-page` = "on" — all posts or pages blocked
- **[HIGH]** Homepage meta description blank or empty
- **[HIGH]** No focus keyphrase on key pages
- **[MEDIUM]** Empty social profiles (list which ones)
- **[MEDIUM]** Schema type not configured (company_or_person empty)
- **[LOW]** XML sitemap disabled
- **[INFO]** Pages with no custom title (using template only)

## Output

- Yoast config summary (sitemap, schema, social status)
- Per-page meta table: post title | custom SEO title | meta desc | focus kw
- Flagged issues list with severity
