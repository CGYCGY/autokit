# Theme & Plugin Extraction

Identify the active theme and installed plugins from the export.

## Theme Detection

Check in order:

1. **From wp-content/themes/**: Use Glob for `wp-content/themes/*/style.css`
   - Read each `style.css` header block (Theme Name, Version, Author)
   - Active theme: if SQL available, grep `wp_options` for `template` and `stylesheet` option values
   - If no SQL, list all themes found and note active theme as "unknown"

2. **From WXR**: Grep for `<wp:option name="template">` and `<wp:option name="stylesheet">` if present

## Plugin Detection

1. **From wp-content/plugins/**: Use Glob for `wp-content/plugins/*/` directories
   - For each plugin dir, check for main plugin file (matches directory name or contains `Plugin Name:`)
   - Use Grep to extract `Plugin Name:`, `Version:` from plugin headers
   - List all found plugins

2. **From SQL**: Grep `wp_options` inserts for `active_plugins` option — parse the serialized array for plugin paths

## Migration-Sensitive Plugin Flags

Flag these plugin categories in the output:
- **Page builders**: Elementor, Beaver Builder, Divi, WPBakery, Gutenberg (block-heavy)
- **WooCommerce**: signals e-commerce content requiring special handling
- **SEO plugins**: Yoast, RankMath — may have SEO meta to migrate
- **Form plugins**: Gravity Forms, WPForms, Contact Form 7 — forms won't migrate to static
- **Membership/auth**: MemberPress, Restrict Content Pro — not compatible with static sites
- **Custom post type plugins**: CPT UI, Toolset — signals non-standard content types

## Output

- Theme name and version
- Total plugin count
- Plugin list with version and any migration flags
