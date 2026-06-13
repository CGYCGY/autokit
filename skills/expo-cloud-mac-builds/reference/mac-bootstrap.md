# Cloud-Mac Bootstrap (Homebrew, headless)

## Symptom
`brew` or brew-installed tools (`node`, `bun`, `watchman`, …) report "command not found" in an interactive SSH/Termius shell, even though the install "succeeded". Or the Homebrew installer hangs waiting for input during automated/headless setup.

## Root cause
- The Homebrew installer is interactive by default — it pauses for a confirmation keypress, which stalls a headless/SSH bootstrap.
- After install, `brew` is not on `PATH` until `brew shellenv` is evaluated. On Apple Silicon, Homebrew lives in `/opt/homebrew`, which is not on the default `PATH`. The installer only updates the current shell; new interactive shells (Termius, fresh SSH) don't inherit it unless it's persisted to a login profile.

## Fix
Run the installer non-interactively and persist the shellenv to the zsh login profile.

```bash
# non-interactive install (no keypress prompt)
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# persist brew to PATH for every future login shell, then load it now
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

- Use `~/.zprofile` (zsh login-shell profile) — macOS uses zsh, and login shells (what SSH/Termius open) source `.zprofile`. Putting it only in the installer's current shell loses it on next login.
- `NONINTERACTIVE=1` is required for the install to complete unattended over SSH.
- After this, brew-installed tools resolve in every new interactive shell.
