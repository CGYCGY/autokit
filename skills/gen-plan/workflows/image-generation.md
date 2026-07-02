# Image Generation

Fill or update the embedded images in an existing plan `.html` file. Images are produced by the **pi-image** service via its **gen-image** RPC driver — `gpt-image-2` on the Codex/ChatGPT subscription (no `OPENAI_API_KEY`). Pick the sub-workflow based on the incoming `USER_PROMPT`:

| Sub-workflow | When to call it |
| --- | --- |
| Create | The prompt asks to generate, fill, or add the plan's images from scratch (empty `{{...IMAGE` slots) |
| Update | The prompt asks to change, refine, regenerate, or replace images that already exist in the plan |

## Driver

Resolve the gen-image driver once (the pi-image checkout owns it):

```bash
GENI="bun ${PI_IMAGE_DIR:-/mnt/wsl/__data/project/private/pi-projects/pi-image}/.claude/skills/gen-image/tools/session.ts"
```

The driver speaks one JSON line per call (`kind`: `ok` | `result` | `reply` | `error`). Subcommands:
- `$GENI up` — boot one warm spoke for the whole batch.
- `$GENI send "<request>"` — generate/edit one image on the warm spoke; returns a `result` (`status` ok/failed, `out_path`, `bytes`) or a `reply` (a question — usually a missing absolute path).
- `$GENI down` — stop the spoke when the batch is done (always run this at the end).
- `$GENI generate "<request>"` — one-shot (boot + send + auto-down) for a single image.

Every request MUST name an **absolute** `out_path` (resolve `IMAGES_OUTPUT_DIR` to absolute). For an edit, also name the absolute `input_path`.

Shared rules for every image prompt:
- always request a wide landscape composition (e.g. `1536x1024`) at high quality
- convey the one or two core ideas of that section for a professional software engineer
- match the plan's synced visual identity (professional, focused, minimal)
- keep total words shown in the image under 10
- save images to `IMAGES_OUTPUT_DIR` (create it if missing)

## Create

1. Find slots - Grep the plan for `{{...IMAGE` placeholders (hero + per-phase). Each comment names the intended subject.
2. Write prompts - For each slot, write a prompt following the shared rules above.
3. Warm up - Run `$GENI up` once (one boot, reused for every slot — far faster than a cold spoke per image). Treat `up`/`down` as a bracket around the whole batch.
4. Generate - For each slot, run `$GENI send "<prompt>. Save it to <abs IMAGES_OUTPUT_DIR>/<file>.png. Wide 1536x1024, high quality."`. On a `reply`, supply the missing absolute path and re-send; on a `result` with `status:ok`, record `out_path`.
5. Tear down - Run `$GENI down` after the last slot (always, even on failure).
6. Embed - Replace each `<!-- {{...IMAGE: ...}} -->` placeholder with `<img src="<plan-name>/<file>.png" alt="...">`, keeping the existing `<figure>`/`<figcaption>`.
7. Report - List the images generated (path + bytes) and the slots filled.

## Update

1. Identify targets - From the `USER_PROMPT`, determine which embedded `<img>` images to change; resolve each to its absolute file path.
2. Write instruction - Write an edit instruction describing the change, following the shared rules above.
3. Edit - For one image, run `$GENI generate "Edit the image at <abs input.png>: <instruction>. Save it to <abs out.png>."`. For several, use `$GENI up` → one `send` per edit → `$GENI down`. Overwrite the existing file (or write a `-v2` sibling if keeping the original).
4. Verify embed - Confirm the `<img>` still points at the updated file; update `src`/`alt`/`<figcaption>` if the change warrants it.
5. Report - List the images updated and what changed.

## Fallback (no pi-image / codex)

If the gen-image driver is unavailable (no `pi`, no `codex` sign-in), fall back to the bundled API scripts, which need `OPENAI_API_KEY` (API-credit billed). The scripts live in this skill's own `scripts/` directory — resolve `SKILL_DIR` to this skill's base directory (the directory containing `SKILL.md`, given when the skill is invoked); do not run them relative to the project cwd:
- Create: `uv run "$SKILL_DIR/scripts/generate_gpt_image.py" "<prompt>" <output.png> --size 1536x1024 --quality high`
- Edit: `uv run "$SKILL_DIR/scripts/edit_gpt_image.py" "<instruction>" <output.png> <input.png> --size 1536x1024 --quality high`
