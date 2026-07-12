Modify KickLicks.jsfx — replace only the @gfx block.

Window: @gfx 560 380

STYLE: Dark industrial/worn metal. Colors:
BG #0F0D0B, Panel #1A1713, Steel #3A3530, Rust #8B3A1E, 
RustHot #C4521E, Copper #7A5C3A, TextHot #E8D5B0, TextDim #5C5248,
LED_ON #FF6B1A, LED_OFF #2A1A10
Font: Courier New bold for labels, regular for values. No Arial.
Texture: diagonal crosshatch gfx_lines at alpha 0.03.

LAYOUT (4 sections top to bottom):
1. Title bar y0-36: "KICKLICKS" left, LED indicator + hit counter right
2. MIDI/KEY y36-130: In/Out channel nudge controls, trigger note, root, scale, octave, span, pass-through toggle
3. Pattern y130-195: 5-button radio for slider7 modes, notes-in-pattern slider, step box visualizer
4. Playback y195-295: Note length, velocity mode toggle, fixed vel, humanize — all horizontal drag sliders
5. Footer y295-380: Last note display, Reset momentary button

CONTROLS:
- Drag sliders: slider8(1-16), slider9(50-2000), slider11(1-127), slider14(0-100)
- Click-cycle (LMB=next, RMB=prev): slider4 (scale 0-7), slider5 (root 0-11)
- Radio buttons: slider7 (0-4, labels: UP DOWN PEND RAND R5)
- Nudge +/-: slider1, slider3 (channels, display +1), slider2, slider6, slider13
- Toggles: slider10 (FOLLOW/FIXED), slider12 (YES/NO)
- Momentary: slider15 — set to 1 on click, @slider resets it

MOUSE: Use mouse_cap bit0 for LMB, edge-detect with last_mouse_cap. Call sliderchange() on every value change. drag_slider=-1 when released.

Display: note_flash, hit_count, last_note_midi, pattern_pos, notes_in_pattern already computed in @block — read only.

Do not modify anything above @gfx.
