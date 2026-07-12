# Contributing to KickLicks

## Issues
Open an issue with: REAPER version, drum VST, bass VST, what you did, what happened, and your KickLicks settings (a GUI screenshot is ideal).

## Pull requests
1. Fork and branch (`git checkout -b fix/short-description`).
2. Keep `KickLicks.jsfx` self-contained (no external deps).
3. If behavior changes, update README.md / SETUP_GUIDE.md to match.
4. Open a PR with a one-line summary.

## Notes
- `docs/development-notes.md` holds internal design notes — not needed to use the plugin.
- JSFX has no compiler/linter; the only true test is loading it in REAPER.
