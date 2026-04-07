# Validate WP Export

Determine whether the directory is a valid WordPress export and identify its format.

## Detection Rules

Check for these artifacts in order:

1. **WXR (XML)** — one or more `.xml` files containing `<wp:wxr_version>` or `<rss version="2.0" xmlns:wp=`
   - Use Grep to scan for the WXR namespace signature
   - Record filename(s) and approximate size

2. **Database dump** — `.sql` file(s) containing `wp_posts` or `wp_options` table definitions
   - Use Glob for `*.sql` then Grep for `wp_posts`

3. **Full file export** — presence of `wp-content/` directory with `uploads/`, `themes/`, or `plugins/` subdirectories
   - Use Glob for `wp-content/` tree

4. **Mixed** — any combination of the above

## Failure Cases

- Directory does not exist → report error, stop
- Directory exists but contains none of the above → report "Not a recognized WP export", stop
- Multiple XML files found → note all, use the largest for content extraction

## Output

Record:
- Export format (WXR / DB dump / full file / mixed)
- Key files identified (names and sizes where available)
- WXR version if found
