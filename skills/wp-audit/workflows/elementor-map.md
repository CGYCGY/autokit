# Elementor Page Map

Extract and parse the Elementor widget sequence for the homepage.

## Step 1: Get Homepage Post ID

From Phase 1, `page_on_front` gives the homepage post ID (e.g., 42).

## Step 2: Extract _elementor_data

The `_elementor_data` postmeta value is a large JSON blob stored as a MySQL-escaped string inside an INSERT INTO wp_postmeta line. Do NOT use the Read tool on sqldump.sql.

```bash
# Extract the raw _elementor_data for the homepage post ID
grep "_elementor_data" sqldump.sql | grep "^([0-9]*,42," | head -1
```

Or use node for reliable extraction:

```bash
node -e "
const fs = require('fs');
const sql = fs.readFileStaticSync('sqldump.sql', 'utf8');  // WARNING: large file
// Instead, stream or use grep output piped to node
" 
```

Preferred approach — pipe grep output into node:

```bash
grep "'_elementor_data'" sqldump.sql | grep ",<POST_ID>," | \
node -e "
const chunks = [];
process.stdin.on('data', d => chunks.push(d));
process.stdin.on('end', () => {
  const line = chunks.join('');
  // Extract value between the last pair of single quotes
  const match = line.match(/'_elementor_data','([\s\S]*?)'\)(\s*,\s*\(|;)/);
  if (match) {
    const escaped = match[1];
    // Unescape MySQL: replace \\\" with \" and \\\\ with \\
    const json = escaped.replace(/\\\\\"/g, '\"').replace(/\\\\\\\\/g, '\\\\');
    console.log(json);
  }
});
"
```

## Step 3: Parse Widget Sequence

Parse the unescaped JSON. Elementor data is nested: sections → columns → widgets.

Walk the tree in order and for each widget extract:
- `widgetType` (heading, text-editor, image, button, video, spacer, etc.)
- `settings.title` or `settings.editor` (text content)
- `settings.link.url` — any link URL (flag wa.link tracking URLs)
- `settings.image.url` or `settings.image.id` — image reference
- `settings.youtube_url` or `settings.vimeo_url` — video embeds
- For button widgets: `settings.text` (button label) + `settings.link.url`

## Step 4: Build Content Map

Produce a flat ordered list:

```
Section 1: [section label or first heading]
  - heading: "Welcome to..."
  - text-editor: "We offer..."
  - button: "Contact Us" → https://wa.link/xxxxx

Section 2: [next section]
  - image: filename.jpg
  - heading: "Our Services"
  ...
```

Flag:
- wa.link or bit.ly or other tracking URLs (list all unique tracking URLs found)
- Video embeds (Vimeo/YouTube IDs)
- Number of CTA buttons total

## Output

- Content Map (section-by-section widget list)
- All unique link URLs found (highlight tracking URLs)
- Video embed IDs
- Total CTA button count
