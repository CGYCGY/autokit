# Images

List original uploaded images and cross-reference with Elementor usage.

## Step 1: List Original Images from Media Library

Target: `files/wp-content/uploads/`

Use bash to list image files, excluding WordPress-generated thumbnails:

```bash
find files/wp-content/uploads -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.svg" \) | \
grep -v -E "\-[0-9]+x[0-9]+\." | \
sort
```

The pattern `-[0-9]+x[0-9]+\.` matches WP thumbnail variants like `-300x200.jpg` — exclude these.

List the originals with their relative paths from uploads/.

## Step 2: Cross-Reference with Elementor Data

From the Elementor widget data collected in Phase 4, collect all image filenames or URLs referenced.

For each image in the Elementor widget list:
- Extract the filename from the URL (last path segment)
- Check if it appears in the originals list from Step 1

Categorize each original image as:
- **Used in Elementor** — appears in Elementor widget data for the homepage
- **Media library only** — uploaded but not referenced in Elementor homepage data
- **Referenced but missing** — in Elementor data but file not found in uploads

## Step 3: Additional Image References

Also check:
```bash
# Images referenced in other pages/posts (non-homepage Elementor data)
grep "_elementor_data" sqldump.sql | grep -o '"url":"[^"]*\.\(jpg\|jpeg\|png\|webp\|gif\)[^"]*"' | \
sed 's|.*uploads/||;s|"||g' | sort -u
```

Note any images referenced in other pages that are not in the homepage Elementor data.

## Output

- Total original images: N
- List of originals (filename | dimensions if detectable | used-in-elementor flag)
- Images used in Elementor homepage: N
- Images in media library only (not in homepage): list
- Missing images (referenced but file absent): list
