# Parse Export Structure

Validate the export directory and extract core site configuration.

## Step 1: Validate Artifacts

Check for these files in EXPORT_DIR:
- `meta.json` — export metadata (DB prefix, site paths)
- `sqldump.sql` — full database dump
- `files/` — WordPress file tree (should contain wp-content/)

If sqldump.sql is missing, report error and stop — all subsequent phases depend on it.
If meta.json is missing, note it and continue (use defaults where needed).
If files/ is missing, note it — phases requiring file access will be limited.

## Step 2: Parse meta.json

Use Read on meta.json (it is small and safe to read directly).

Extract:
- `db_prefix` (default: `wp_` if absent)
- `site_url` or equivalent path fields
- Any credential fields — do not include passwords in the report

## Step 3: Extract Core wp_options

SQL dump lines are very long. Use Bash grep to extract option rows safely:

```bash
grep -o "'option_name','[^']*'" sqldump.sql | head -100
```

For each target option, use a targeted grep pattern:

```bash
# siteurl
grep -o "'siteurl','[^']*'" sqldump.sql

# home
grep -o "'home','[^']*'" sqldump.sql

# blogname
grep -o "'blogname','[^']*'" sqldump.sql

# blogdescription
grep -o "'blogdescription','[^']*'" sqldump.sql

# permalink_structure
grep -o "'permalink_structure','[^']*'" sqldump.sql

# blog_public (1=indexed, 0=noindex)
grep -o "'blog_public','[^']*'" sqldump.sql

# show_on_front (page | posts)
grep -o "'show_on_front','[^']*'" sqldump.sql

# page_on_front (post ID of homepage)
grep -o "'page_on_front','[^']*'" sqldump.sql
```

Note the homepage post ID from `page_on_front` — needed for Phase 4 (Elementor map).

## Output

Record:
- Artifacts present/missing
- DB prefix
- siteurl, home, blogname, blogdescription
- permalink_structure
- blog_public value (flag if 0 — site set to discourage search engines)
- show_on_front and page_on_front (homepage post ID)
