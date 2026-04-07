# Content & Plugin Inventory

Count published content by type and extract plugin list.

## Step 1: Published Post Counts by Type

Use bash to extract post_type and post_status from wp_posts INSERT lines:

```bash
# Extract all published posts with their types
grep -o ",'publish','[^']*','[^']*'" sqldump.sql | grep -o ",'[^']*'$" | sort | uniq -c | sort -rn
```

If that pattern is unreliable due to column ordering, use a node one-liner to parse the INSERT:

```bash
node -e "
const fs = require('fs');
const sql = fs.readFileSync('sqldump.sql', 'utf8');
const matches = [...sql.matchAll(/INSERT INTO \`wp_posts\`[^;]+/g)];
// parse post_type and post_status columns from VALUES rows
"
```

Count by post_type for status = 'publish' only. Exclude: revision, nav_menu_item, attachment.

## Step 2: Active Plugins

```bash
grep -o "'active_plugins','[^']*'" sqldump.sql
```

The value is a PHP serialized array. Extract plugin slugs with:

```bash
grep -o "active_plugins" sqldump.sql | head -1  # confirm present
grep "'active_plugins'" sqldump.sql | grep -o '"[^/"]*/[^"]*\.php"' | sed 's/"//g'
```

List all plugin slugs. Flag by category:
- **SEO**: yoast-seo, rank-math, all-in-one-seo
- **Page builder**: elementor, elementor-pro, beaver-builder, divi, js_composer
- **Chat/contact**: chaty, ht-whatsapp, click-to-chat, wp-whatsapp
- **Forms**: fluentform, gravityforms, wpforms, contact-form-7
- **Analytics**: google-site-kit, monsterinsights, gtm4wp
- **Coming soon**: seedprod, coming-soon-pro, maintenance

## Step 3: robots.txt and .htaccess

Use Glob/Read to check:
- `files/robots.txt` — read and report contents if present
- `files/.htaccess` — check for redirect rules, maintenance redirects

## Step 4: GA/GTM in Theme

```bash
grep -r "GTM-\|UA-\|G-[A-Z0-9]" files/wp-content/themes/ 2>/dev/null | head -20
```

Note which theme file contains tracking code and the tracking ID(s) found.

## Step 5: Coming Soon / Maintenance Mode

```bash
grep -o "'seedprod_settings','[^']*'" sqldump.sql
```

If present, check `enabled` field inside the serialized value.
Also check for SeedProd or MaintenanceMode plugin in active_plugins.

## Output

- Content counts table: post_type | published count
- Active plugins list with category flags
- robots.txt contents (or "not found")
- GA/GTM tracking IDs found (or "none detected")
- Coming soon status: enabled/disabled
