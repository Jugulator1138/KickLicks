# KickLicks - REAPER Setup Guide

## What It Does

KickLicks listens for kick drum MIDI hits and generates bass guitar notes on a separate track, creating a live bassline that follows the drummer. Every time you hit the kick, a new bass note plays based on your chosen scale, pattern, and settings.

## Your Setup

- **Drum Module**: Roland TD-5
- **Audio Interface**: PreSonus FireBox (MIDI In)
- **DAW**: REAPER
- **Drum VST**: Superior Drummer 3 (MIDI Channel 10)
- **Bass VST**: Any bass guitar plugin (e.g., MODO Bass, Ample Bass, EZbass, etc.)

---

## Step 1: Install the Plugin

1. Open REAPER
2. Go to **Options > Show REAPER resource path...** - this opens a folder
3. Inside that folder, find the **Effects** subfolder
4. Copy `KickLicks.jsfx` into the **Effects** folder (or create a subfolder like `Effects/KickLicks/` to keep it organized)
5. Back in REAPER, go to **Options > Preferences > Plug-ins > JS** and click **Re-scan**

The plugin will now appear as **JS: KickLicks - Kick Drum Bassline Generator** in the FX browser.

---

## Step 2: Set Up the Tracks

### Track 1 - Drums (Superior Drummer 3)

1. Create a new track, name it **"Drums"**
2. Set the track input to your PreSonus FireBox MIDI input:
   - Click the track's input dropdown (red record-arm area)
   - Select **Input: MIDI > PreSonus FireBox > All Channels** (or Channel 10 specifically)
3. Click the **FX** button on the track to open the FX chain
4. Add **KickLicks** first:
   - Click **Add** > search for **"KickLicks"** > insert it
5. Add **Superior Drummer 3** after KickLicks:
   - Click **Add** > search for your SD3 plugin > insert it
6. **Important**: KickLicks must be **above** (before) SD3 in the FX chain so it can process MIDI before SD3 receives it
7. Arm the track for recording (click the record arm button)

### Track 2 - Bass

1. Create a new track, name it **"Bass"**
2. Add your bass guitar VST plugin to this track's FX chain
3. Do **NOT** arm this track for recording - it will receive MIDI from the drums track via a send

---

## Step 3: Set Up MIDI Routing

This is the key step - routing the generated bass notes from Track 1 to Track 2.

1. On the **Drums** track, click the **Route** button (or drag from the Drums track to the Bass track)
2. Click **Add new send...** and select the **Bass** track
3. In the send settings that appear:
   - Set **Audio** to **None** (we only want MIDI, not audio)
   - Set **MIDI** to **Send to channel 1 only** (or whichever channel you set as Output Channel in KickLicks)
   - Under the MIDI dropdown, you may see options to filter - ensure only Channel 1 is being sent

### Alternative: If your bass VST receives notes it shouldn't

If the bass VST is receiving drum MIDI in addition to bass notes:
1. On the **Bass** track, open the track's MIDI input settings
2. Set it to only receive **Channel 1** (the KickLicks output channel)
3. Or in the Bass VST itself, set it to only respond to Channel 1

---

## Step 4: Configure KickLicks

Open the KickLicks plugin on the Drums track and set the controls:

### Input Settings
| Control | Description | Your Setting |
|---------|-------------|-------------|
| **Input MIDI Channel** | Channel your drums come in on | **10** (default for Roland TD-5) |
| **Trigger Note** | MIDI note that triggers bass notes | **36** (standard kick drum) |

### Output Settings
| Control | Description | Recommended |
|---------|-------------|-------------|
| **Output MIDI Channel** | Channel for bass notes | **1** (must differ from input) |
| **Pass-Through Input** | Keep original MIDI for SD3 | **Yes** |

### Musical Settings
| Control | Description | Starting Point |
|---------|-------------|---------------|
| **Scale** | Musical scale for bass notes | Try **Minor Pentatonic** or **Blues** |
| **Root Note** | Key of the bassline | Match your song's key (e.g., **E** for rock) |
| **Octave** | Bass register | **2** (standard bass range) |
| **Octave Span** | How many octaves to cover | **1** for tight basslines, **2** for more range |
| **Notes in Pattern** | How many notes before repeating | **5** for pentatonic, **4** for simpler lines |

### Pattern Settings
| Control | Description | When to Use |
|---------|-------------|-------------|
| **Up** | Walks up the scale | Simple ascending lines |
| **Down** | Walks down the scale | Descending feel |
| **Pendulum** | Goes up then back down | More melodic movement |
| **Random** | Random note from scale | Unpredictable / experimental |
| **Root-Fifth** | Alternates root and fifth | Classic rock/punk bassline |

### Feel Settings
| Control | Description | Recommended |
|---------|-------------|-------------|
| **Note Length** | How long each note sustains (ms) | **150-300ms** for punchy, **500-1000ms** for sustained |
| **Velocity Mode** | Follow kick dynamics or fixed | **Follow Kick** for natural feel |
| **Humanize** | Adds timing/velocity variation | **20-40%** for natural, **0%** for tight |

---

## Step 5: Play!

1. Make sure the Drums track is armed for recording
2. Start playing your electronic drum kit
3. You should hear:
   - Superior Drummer 3 playing your full drum kit as normal
   - The bass VST playing notes every time you hit the kick drum
4. Adjust scale, pattern, and note length to taste while playing

---

## Quick Troubleshooting

### No bass notes playing
- Check that KickLicks is **before** SD3 in the FX chain
- Verify Input MIDI Channel matches your drum module (Channel 10)
- Verify Trigger Note is 36 (kick)
- Check that "Pass-Through Input" is set to **Yes**
- Make sure the MIDI send from Drums to Bass track is active

### Bass plays but sounds wrong
- Try changing the **Scale** and **Root Note** to match your song
- Adjust **Note Length** - too short sounds choppy, too long causes overlaps (the plugin handles overlaps by cutting the previous note)
- Lower the **Octave** if notes sound too high for bass

### SD3 not receiving MIDI
- Make sure "Pass-Through Input" is set to **Yes**
- Make sure KickLicks is before SD3 in the FX chain

### Notes sound mechanical
- Increase **Humanize** to 20-40%
- Set Velocity Mode to **Follow Kick** so dynamics match your playing

### Want to change key mid-song
- Automate the **Root Note** slider in REAPER to change keys at specific points

---

## Tips

- **Start simple**: Use Root-Fifth pattern with Minor Pentatonic scale for instant rock basslines
- **Match the key**: Set the Root Note to match whatever key you're jamming in
- **Use the GUI**: The KickLicks window shows the current note sequence and highlights where you are in the pattern
- **Reset**: Use the Reset Pattern button to start the sequence from the beginning
- **Record**: You can record the generated MIDI on the Bass track for editing later - arm the Bass track, enable "Record: MIDI > output" in the track settings
