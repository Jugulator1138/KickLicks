# KickLicks — REAPER Setup Guide

KickLicks converts kick-drum MIDI into bass notes. To keep your drum kit and bass separate it uses a 4-track architecture:

    Track 1  MIDI Input (Drums)   ← your kit arrives here, fans out to both tracks below
    Track 2  Drums - SD3          ← your drum VST (gets ALL drum MIDI)
    Track 3  KickLicks            ← the JSFX; reads drums, outputs bass on Ch 1 only
    Track 4  Bass Guitar          ← your bass VST (gets Ch 1 bass notes only)

Isolating bass on its own channel/track stops your drum VST from also "playing" the generated notes.

## Option A — One-Click (recommended)
1. Copy `KickLicks.jsfx` into REAPER `Effects` and Re-scan (Options ▸ Preferences ▸ Plug-ins ▸ JS).
2. Actions ▸ Show Action List ▸ New action… ▸ Load ReaScript ▸ select `KickLicks_Setup.lua` ▸ Run.
3. Script creates all 4 tracks, colors them, wires MIDI sends, loads KickLicks (pass-through OFF), shows a summary.
4. Add your drum VST to the Drums track and bass VST to the Bass track. Arm the MIDI Input track and play.

## Option B — Manual
1. Install plugin as above.
2. Create 4 tracks: MIDI Input (arm + monitor, master send OFF, no FX), Drums (your drum VST), KickLicks (JSFX, Pass-Through = No), Bass (your bass VST).
3. Route MIDI (audio = None on every send):
   - MIDI Input → Drums: All channels
   - MIDI Input → KickLicks: All channels
   - KickLicks → Bass: Channel 1 only
4. On the Bass track (or bass VST) set input to Channel 1 only.

## Configure KickLicks
| Setting | Start with |
|---|---|
| Input MIDI Channel | 10 (or your kit's channel) |
| Trigger Note | 36 |
| Output MIDI Channel | 1 |
| Pass-Through Input | No |
| Scale | Minor Pentatonic or Blues |
| Root Note | Match your song key (E for rock) |
| Octave | 2 |
| Pattern Mode | Root-Fifth for instant rock bass |
| Notes in Pattern | 5 |
| Note Length | 150–300ms punchy, 500–1000ms sustained |
| Velocity Mode | Follow Kick |
| Humanize | 20–40% |

## Play
Arm the MIDI Input track and play your kit. You should hear drums AND a bass note on every kick.
Record the result: arm the Bass track with *Record: MIDI ▸ output* to capture the generated line.

## Troubleshooting
- No bass: KickLicks before drum VST; Input Channel matches kit; Trigger Note = 36; KickLicks→Bass send active.
- Bass VST plays drums too: set bass track/VST to Ch 1 only.
- Robotic: raise Humanize, Velocity Mode = Follow Kick.
- Wrong key: change Root Note (or automate it mid-song).
