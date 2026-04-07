# Content Inventory

Extract post, page, and taxonomy counts from the export.

## From WXR (XML)

Use Grep on the WXR file(s):

- **Posts**: count `<wp:post_type>post</wp:post_type>` occurrences
- **Pages**: count `<wp:post_type>page</wp:post_type>` occurrences
- **Custom Post Types**: grep `<wp:post_type>` and list all distinct values excluding `post`, `page`, `attachment`, `revision`, `nav_menu_item`
- **Published**: count `<wp:status>publish</wp:status>`
- **Draft**: count `<wp:status>draft</wp:status>`
- **Trashed**: count `<wp:status>trash</wp:status>`
- **Categories**: count `<wp:term_taxonomy>category</wp:term_taxonomy>`
- **Tags**: count `<wp:term_taxonomy>post_tag</wp:term_taxonomy>`
- **Custom taxonomies**: list distinct `<wp:term_taxonomy>` values excluding category, post_tag, nav_menu, link_category, post_format

Use Bash with grep -c for fast counts on large files.

## From Database Dump (.sql)

Use Grep on `.sql` file(s):

- Post counts: grep `INSERT INTO.*wp_posts` lines, then parse `post_type` and `post_status` columns
- Taxonomy counts: grep `INSERT INTO.*wp_term_taxonomy` lines, parse `taxonomy` column
- Note: SQL parsing is approximate — flag counts as "~N (from SQL scan)"

## Fallback

If neither WXR nor SQL is available but `wp-content/` exists, report content inventory as "unavailable — no XML or SQL export found."
