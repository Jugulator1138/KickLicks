# KickLicks

> **Kick Out The Jams** — turn your kick drum into a live bass player.

![REAPER JSFX](https://img.shields.io/badge/REAPER-JSFX-ff5a00)
![License MIT](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-555)

**KickLicks** is a free [REAPER](https://www.reaper.fm/) JSFX plugin that listens for your kick-drum MIDI hits and automatically generates a bass guitar line that follows your playing in real time. Hit the kick → get a bass note. Play a groove → get a groove.

It's built for live jamming and writing: trigger a bassline from your electronic kit (Superior Drummer 3, EZdrummer, etc.) while you play, no MIDI programming required.

## Features
- Kick-triggered bass — every kick hit spawns a bass note on a separate track
- 8 musical scales — Major, Natural Minor, Minor Pentatonic, Major Pentatonic, Blues, Dorian, Mixolydian, Chromatic
- 5 pattern modes — Up, Down, Pendulum, Random, Root–Fifth
- Follow-the-kick dynamics or fixed velocity
- Humanize — subtle timing/velocity variation
- Custom GUI — dark industrial skin with hit counter, last-note display, pattern visualizer
- Zero dependencies — single `.jsfx` file, no DLLs or installers

## Requirements
| | |
|---|---|
| DAW | REAPER (recent version with JSFX support) |
| Drum source | Any MIDI kick — electronic kit, pad controller, or drum VST |
| Bass source | Any bass VST (MODO Bass, Ample Bass, EZbass, stock synth…) |
| OS | Windows / macOS / Linux |

## Quick Start (recommended)
1. Copy `KickLicks.jsfx` into your REAPER `Effects` folder and **Re-scan** (*Options ▸ Preferences ▸ Plug-ins ▸ JS*).
2. Run `KickLicks_Setup.lua` (*Actions ▸ Show Action List ▸ New action… ▸ Load ReaScript*) — it builds the 4 tracks + all MIDI routing.
3. Add your drum VST to the *Drums* track and your bass VST to the *Bass* track, arm the *MIDI Input* track, and play.

Prefer to wire it by hand? See [`SETUP_GUIDE.md`](SETUP_GUIDE.md).

## Controls
| Control | What it does | Default |
|---|---|---|
| Input MIDI Channel | Channel your drums arrive on | 10 |
| Trigger Note | MIDI note that fires bass (36 = kick) | 36 |
| Output MIDI Channel | Channel for bass notes (must differ from input) | 1 |
| Scale | Musical scale for the bassline | Minor Pentatonic |
| Root Note | Key of the bassline (C–B) | C |
| Octave | Bass register (1–3) | 2 |
| Pattern Mode | Up / Down / Pendulum / Random / Root–Fifth | Up |
| Notes in Pattern | Scale steps before repeat (1–16) | 5 |
| Note Length (ms) | How long each bass note sustains | 200 |
| Velocity Mode | Follow Kick / Fixed | Follow Kick |
| Fixed Velocity | Velocity when Fixed (1–127) | 100 |
| Pass-Through Input | Send original drum MIDI through | Yes |
| Humanize (%) | Timing/velocity variation (0–100) | 0 |
| Reset Pattern | Restart the pattern | — |

## Troubleshooting
- **No bass:** KickLicks must be *before* your drum VST in its FX chain; Input Channel must match your kit (try 10); Trigger Note = 36; KickLicks→Bass send must be active.
- **Bass VST plays drums too:** set bass track/VST to **Channel 1 only**.
- **Robotic:** raise Humanize to 20–40%, set Velocity Mode to Follow Kick.
- **Change key mid-song:** automate the Root Note slider in REAPER.

## Repo Files
| File | Purpose |
|---|---|
| `KickLicks.jsfx` | The plugin |
| `KickLicks_Setup.lua` | One-click REAPER track + routing builder |
| `SETUP_GUIDE.md` | Manual setup / routing walkthrough |
| `docs/development-notes.md` | Internal design notes |

## License
Released under the [MIT License](LICENSE). Free for personal and commercial use.
