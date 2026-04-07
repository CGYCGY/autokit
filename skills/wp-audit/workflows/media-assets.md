# Media & Assets Audit

Inventory the uploads directory and check for broken media references.

## Uploads Directory

Target: `<EXPORT_DIR>/wp-content/uploads/`

If directory exists:
1. Use Bash to count total files: `find wp-content/uploads -type f | wc -l`
2. Use Bash to estimate total size: `du -sh wp-content/uploads`
3. Use Bash to count by extension:
   ```
   find wp-content/uploads -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
   ```
   Report top file types (jpg, png, gif, pdf, mp4, svg, etc.)

If directory does not exist, note "uploads directory not present in export."

## Media References in Content

If WXR is available:
1. Use Grep to find `<wp:attachment_url>` entries — count total media attachments declared
2. Use Grep to find hard-coded domain URLs in `<content:encoded>` blocks (patterns like `http://` or `https://` followed by a domain)
3. Compare attachment count to files in uploads — flag discrepancy as missing media

If only SQL:
- Grep `wp_posts` insert lines for `post_type='attachment'` to count attachments
- Note media file check is not possible without the uploads directory

## Output

- Total upload files: N
- Total upload size: X MB/GB
- File type breakdown (top 5+)
- Attachment records declared: N
- Missing files (declared but not in uploads): N
- External media references: N (URLs pointing outside the export)
