# KickLicks JSFX — Full GUI Redesign Prompt for Claude Code
## Handoff Document — Straight-Line Custom Solutions / Curtis Fraser

---

## WHAT YOU'RE BUILDING

Replace the existing `@gfx` block in `KickLicks.jsfx` with a fully interactive custom GUI. The plugin is a MIDI bassline generator triggered by kick drum hits in REAPER. All 15 sliders currently appear in REAPER's default slider strip. The goal is to make the entire plugin operable from the custom GUI alone, with REAPER's slider strip as a fallback only.

The existing file is at the repo root: `KickLicks.jsfx`
Do NOT touch anything above `@gfx` — the MIDI logic is final.

---

## AESTHETIC DIRECTION — NON-NEGOTIABLE

**Rat rod. Industrial. Worn but hard-running.**

Think: a bass guitar headstock made of oiled walnut sitting on a steel workbench covered in metal shavings. Punk rock ethic, not homeless aesthetic. Beat to hell on the surface, dialed in underneath. Every visual choice should communicate that this thing has been used hard and sounds like it.

### Color Palette

```
BG_DEEP:      #0F0D0B   // near-black, faint warm brown cast
BG_PANEL:     #1A1713   // panel surface — like oiled dark walnut grain
BG_SECTION:   #221F1A   // section dividers — slightly lifted surface
STEEL:        #3A3530   // control borders, unpainted steel
RUST:         #8B3A1E   // primary accent — oxidized iron red-orange
RUST_HOT:     #C4521E   // active/fired state — brighter rust
COPPER:       #7A5C3A   // secondary accent — worn copper/brass hardware
COPPER_LIGHT: #A87D52   // labels, value readouts
WOOD_DARK:    #2C1F0F   // dark walnut inlay sections
WOOD_MID:     #4A3018   // wood grain mid tone
TEXT_DIM:     #5C5248   // muted label text
TEXT_MID:     #8C7D6E   // secondary readout text
TEXT_HOT:     #E8D5B0   // primary active text — aged bone/ivory
WELD:         #1E2820   // dark green-black — weld spatter accent, used sparingly
LED_OFF:      #2A1A10   // dead indicator
LED_ON:       #FF6B1A   // fired indicator — hot orange ember
```

### Typography

- **Title/Headers:** `"Oswald"` from Google Fonts or fall back to a condensed sans — uppercase, letter-spaced. Industrial stencil feel.
- **Labels:** `"Share Tech Mono"` or `"Courier New"` fallback — monospace, like stenciled panel labels.
- **Value Readouts:** Same mono font, but slightly larger, TEXT_HOT color.
- NO rounded sans. NO system fonts. NO Inter, Roboto, Arial.

### Visual Texture

- Background gets a subtle diagonal crosshatch or noise texture drawn with `gfx_line` calls at very low alpha (0.03–0.05) to simulate brushed metal or worn paint. Do NOT use an image for this — draw it in gfx primitives.
- Section dividers are thin 1px horizontal lines in STEEL color.
- Control labels are uppercase, slightly letter-spaced.
- Knob/slider tracks use STEEL. Fill/indicator uses RUST or RUST_HOT when active.
- Active controls (being hovered or dragged) shift accent to RUST_HOT.

---

## WINDOW SIZE

```
@gfx 560 380
```

---

## LAYOUT — SECTION MAP

```
┌─────────────────────────────────────────────────────┐
│  [TITLE BAR]  KickLicks       [LED] [HIT COUNTER]   │  y: 0–36
├──────────────┬──────────────────────────────────────┤
│  MIDI I/O    │  KEY / SCALE                         │  y: 36–130
│  In Ch       │  Root   Scale   Octave   Span        │
│  Out Ch      │                                      │
│  Trig Note   │                                      │
│  Pass-Thru   │                                      │
├──────────────┴──────────────────────────────────────┤
│  PATTERN                                            │  y: 130–195
│  Mode: [UP][DOWN][PEND][RAND][R5]  Notes: [■ ■ ■]  │
│  [SEQUENCE STEP BOXES — current position shown]     │
├─────────────────────────────────────────────────────┤
│  PLAYBACK                                           │  y: 195–295
│  Note Length ─────────────────── [value]ms          │
│  Velocity Mode: [FOLLOW KICK] [FIXED]               │
│  Fixed Vel ────────────────────── [value]           │
│  Humanize ─────────────────────── [value]%          │
├─────────────────────────────────────────────────────┤
│  [LAST NOTE DISPLAY]       [RESET BTN]  [STATUS]    │  y: 295–380
└─────────────────────────────────────────────────────┘
```

---

## SLIDER REFERENCE TABLE

| Slider | Variable | Type | Range | Control Style |
|--------|----------|------|-------|---------------|
| slider1 | Input MIDI Channel | stepped int | 0–15 → display 1–16 | Click-cycle or +/- buttons |
| slider2 | Trigger Note | stepped int | 0–127 | +/- buttons with value display |
| slider3 | Output MIDI Channel | stepped int | 0–15 → display 1–16 | Click-cycle or +/- buttons |
| slider4 | Scale | enum 0–7 | see list | Click-cycle button — display name |
| slider5 | Root Note | enum 0–11 | C through B | Click-cycle — 12 positions |
| slider6 | Octave | stepped int | 1–3 | +/- buttons |
| slider7 | Pattern Mode | enum 0–4 | Up/Down/Pend/Rand/R5 | 5-button radio group |
| slider8 | Notes in Pattern | stepped int | 1–16 | Horizontal drag slider |
| slider9 | Note Length ms | continuous | 50–2000 | Horizontal drag slider |
| slider10 | Velocity Mode | binary | 0=Follow, 1=Fixed | 2-button toggle |
| slider11 | Fixed Velocity | stepped int | 1–127 | Horizontal drag slider |
| slider12 | Pass-Through | binary | 0=Yes, 1=No | Toggle button |
| slider13 | Octave Span | stepped int | 1–3 | +/- buttons |
| slider14 | Humanize % | continuous | 0–100 | Horizontal drag slider |
| slider15 | Reset Pattern | momentary | 0=off, 1=reset | Momentary button — resets to 0 after fire |

---

## CONTROL IMPLEMENTATION — JSFX gfx SPECIFICS

### Mouse Input

All interaction goes through the `@gfx` section. JSFX provides these mouse globals:

```
mouse_x, mouse_y          // current position
mouse_cap                 // bitmask: bit0=LMB, bit1=RMB, bit2=Ctrl, bit3=Shift, bit4=Alt
```

Track state with persistent variables:
```
drag_slider    // which slider is being dragged (-1 = none)
drag_start_x   // mouse_x at drag start
drag_start_val // slider value at drag start
hover_control  // which control mouse is over
last_mouse_cap // previous frame's mouse_cap — for edge detection
```

### Drag Slider Implementation

For continuous sliders (slider8, slider9, slider11, slider14):

```
// On LMB press over control:
drag_slider = SLIDER_ID;
drag_start_x = mouse_x;
drag_start_val = sliderN;

// Each frame while dragging:
delta = (mouse_x - drag_start_x) * SENSITIVITY;
sliderN = max(MIN, min(MAX, drag_start_val + delta));
sliderchange(sliderN);
```

Sensitivity values:
- slider9 (50–2000): 5.0 px per unit
- slider11 (1–127): 0.5 px per unit  
- slider14 (0–100): 0.4 px per unit
- slider8 (1–16): 0.1 px per unit

### Click-Cycle Implementation

For enum sliders (slider4, slider5):

```
// On LMB click (rising edge — mouse_cap bit0 set, was 0 last frame):
slider4 = (slider4 + 1) % NUM_OPTIONS;
sliderchange(slider4);
```

Right-click goes backwards:
```
slider4 = (slider4 - 1 + NUM_OPTIONS) % NUM_OPTIONS;
```

### Button Radio Group

For slider7 (Pattern Mode) — 5 buttons, clicking any sets slider7 to that index:

```
// Hit test each button rect
// On click: slider7 = button_index; sliderchange(slider7);
```

### Momentary Button (slider15 Reset)

```
// On LMB press:
slider15 = 1;
sliderchange(slider15);
// The @slider block handles reset and sets slider15 back to 0
```

---

## DRAWING FUNCTIONS TO IMPLEMENT

### `draw_hslider(x, y, w, val, minv, maxv, label, unit)`
- Track: full width rect, 6px height, STEEL color
- Fill: from left to val position, RUST color
- Thumb: small vertical rect or circle at val position, COPPER_LIGHT
- Label above-left in mono font
- Value readout above-right in TEXT_HOT

### `draw_cycle_button(x, y, w, h, label, value_str)`
- Rect with STEEL border
- Left/right arrows on edges (drawn with gfx_line)
- Centered value text in TEXT_HOT
- On hover: border goes COPPER

### `draw_radio_group(x, y, btn_w, btn_h, options[], active_idx)`
- Horizontal row of buttons
- Active: RUST fill, TEXT_HOT text
- Inactive: BG_SECTION fill, TEXT_DIM text
- STEEL borders throughout

### `draw_toggle(x, y, w, h, val, label_a, label_b)`
- Two-segment control
- Active segment: RUST fill
- Inactive: BG_SECTION

### `draw_nudge(x, y, val, minv, maxv, label)`
- [-] [value] [+] layout
- Compact for channel/octave controls

### `draw_led(cx, cy, r)`
- Filled circle
- note_flash > 0: LED_ON with alpha proportional to flash
- note_active: LED_ON at full
- else: LED_OFF

### `draw_step_boxes(x, y, notes_in_pattern, pattern_pos, note_list[])`
- Existing logic from current @gfx — keep and restyle
- Active step: RUST fill, black note name
- Inactive: BG_SECTION, TEXT_DIM note name
- STEEL borders

### `draw_section_header(x, y, w, label)`
- Thin 1px STEEL line full width
- Label left-aligned in Oswald/condensed, uppercase, TEXT_DIM color
- Like a panel section stamp

---

## BACKGROUND TEXTURE

Draw this once per frame (it's cheap):
```
// Diagonal crosshatch at very low alpha
gfx_set(1, 1, 1, 0.025);
i = -gfx_h;
while (i < gfx_w) (
  gfx_line(i, 0, i + gfx_h, gfx_h);
  i += 8;
);
```

---

## TITLE BAR

```
// Dark wood-toned bar, full width, 36px tall
gfx_set(from WOOD_DARK);
gfx_rect(0, 0, gfx_w, 36);

// Thin RUST accent line at bottom of title bar
gfx_set(from RUST);
gfx_rect(0, 34, gfx_w, 2);

// Title text — left aligned, Oswald/condensed style, uppercase
// "KICKLICKS" large, "BASS GENERATOR" smaller/dimmer on same line or below

// LED indicator — top right area
draw_led(gfx_w - 45, 18, 7);

// Hit counter — right of LED
```

---

## FONT CALLS

JSFX `gfx_setfont` only loads system fonts. Use:
```
gfx_setfont(1, "Courier New", 15, 66);   // 'B' flag = bold, for labels
gfx_setfont(2, "Courier New", 12, 0);    // small readouts
gfx_setfont(3, "Courier New", 18, 66);   // title / large display
gfx_setfont(4, "Courier New", 11, 0);    // note names in step boxes
gfx_setfont(5, "Courier New", 13, 0);    // value readouts
```

If running on Windows, "Consolas" is available and preferred over Courier New.
Font slots 1–16 are persistent once set — only call `gfx_setfont` when changing.

---

## COLOR HELPER

Define these as constants at top of @init and use throughout:

```
// Colors as packed RGB for gfx_set — use: gfx_set(r, g, b, a)
// BG_DEEP      r=0.059 g=0.051 b=0.043
// BG_PANEL     r=0.102 g=0.090 b=0.075
// BG_SECTION   r=0.133 g=0.122 b=0.102
// STEEL        r=0.227 g=0.208 b=0.188
// RUST         r=0.545 g=0.227 b=0.118
// RUST_HOT     r=0.769 g=0.322 b=0.118
// COPPER       r=0.478 g=0.361 b=0.227
// COPPER_LIGHT r=0.659 g=0.490 b=0.322
// WOOD_DARK    r=0.173 g=0.122 b=0.059
// TEXT_DIM     r=0.361 g=0.322 b=0.282
// TEXT_MID     r=0.549 g=0.490 b=0.431
// TEXT_HOT     r=0.910 g=0.835 b=0.690
// LED_OFF      r=0.165 g=0.102 b=0.063
// LED_ON       r=1.000 g=0.420 b=0.102
```

---

## WHAT NOT TO TOUCH

- Everything above `@gfx` in the file — `@init`, `@slider`, `@block` — is final.
- The `build_note_list()` function and scale tables.
- The MIDI send logic.
- `note_flash`, `hit_count`, `last_note_midi`, `pattern_pos` — these are already computed by `@block` and should be READ in `@gfx` for display only.

---

## INTERACTION NOTES

- `sliderchange(sliderN)` must be called every time a slider value is modified from `@gfx` so REAPER registers the change for automation and preset saving.
- Edge-detect mouse button presses: `(mouse_cap & 1) && !(last_mouse_cap & 1)` = rising edge (click moment). Set `last_mouse_cap = mouse_cap` at the END of each `@gfx` frame.
- For drag sliders, update continuously while `(mouse_cap & 1) && drag_slider >= 0`.
- Release detection: `!(mouse_cap & 1) && drag_slider >= 0` → clear `drag_slider = -1`.
- Hover detection: check `mouse_x` / `mouse_y` against each control's bounding rect each frame.

---

## DELIVERY

- Output is a single modified `KickLicks.jsfx` file with the `@gfx` block replaced.
- No other files. No dependencies. No images.
- The `@gfx 560 380` header line sets window dimensions — include it.
- Test logic: dragging a slider must visually update AND call `sliderchange()`. The sequence step boxes must advance when MIDI triggers fire. The LED must flash on hit.

---

## REPO CONTEXT

File lives at repo root. Push the modified file to the same location. The plugin is self-contained — one `.jsfx` file.
