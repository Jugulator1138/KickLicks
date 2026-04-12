-- KickLicks_Setup.lua
-- REAPER Script: Auto-creates tracks and MIDI routing for KickLicks
-- Run from: Actions, Show Action List, New action, Load ReaScript

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local num_tracks = reaper.CountTracks(0)

-----------------------------------------------------------
-- TRACK 1: MIDI Input (receives from drum module)
--   No FX here - just captures MIDI and fans it out
-----------------------------------------------------------
reaper.InsertTrackAtIndex(num_tracks, true)
local midi_in = reaper.GetTrack(0, num_tracks)
reaper.GetSetMediaTrackInfo_String(midi_in, "P_NAME", "MIDI Input (Drums)", true)
reaper.SetMediaTrackInfo_Value(midi_in, "I_RECARM", 1)
reaper.SetMediaTrackInfo_Value(midi_in, "I_RECINPUT", 4096 + 62 * 32)
reaper.SetMediaTrackInfo_Value(midi_in, "I_RECMON", 1)
reaper.SetTrackColor(midi_in, reaper.ColorToNative(180, 180, 60) + 0x1000000)

-----------------------------------------------------------
-- TRACK 2: Superior Drummer 3 (receives all drum MIDI)
-----------------------------------------------------------
reaper.InsertTrackAtIndex(num_tracks + 1, true)
local sd3 = reaper.GetTrack(0, num_tracks + 1)
reaper.GetSetMediaTrackInfo_String(sd3, "P_NAME", "Drums - SD3", true)
reaper.SetTrackColor(sd3, reaper.ColorToNative(60, 100, 180) + 0x1000000)

-----------------------------------------------------------
-- TRACK 3: KickLicks (receives drum MIDI, generates bass)
--   Pass-through OFF - only outputs bass notes on Ch 1
-----------------------------------------------------------
reaper.InsertTrackAtIndex(num_tracks + 2, true)
local kicklicks = reaper.GetTrack(0, num_tracks + 2)
reaper.GetSetMediaTrackInfo_String(kicklicks, "P_NAME", "KickLicks", true)
reaper.SetTrackColor(kicklicks, reaper.ColorToNative(180, 100, 60) + 0x1000000)

-- Try to add KickLicks JSFX
local kl_found = false
local kl_idx = reaper.TrackFX_AddByName(kicklicks, "JS:KickLicks - Kick Drum Bassline Generator", false, -1)
if kl_idx >= 0 then
  kl_found = true
else
  kl_idx = reaper.TrackFX_AddByName(kicklicks, "JS:KickLicks", false, -1)
  if kl_idx >= 0 then
    kl_found = true
  else
    kl_idx = reaper.TrackFX_AddByName(kicklicks, "JS:KickLicks/KickLicks", false, -1)
    if kl_idx >= 0 then
      kl_found = true
    end
  end
end

-- Set KickLicks pass-through to NO (slider12 = 1)
if kl_found and kl_idx >= 0 then
  reaper.TrackFX_SetParam(kicklicks, kl_idx, 11, 1.0)
end

-----------------------------------------------------------
-- TRACK 4: Bass Guitar VST
-----------------------------------------------------------
reaper.InsertTrackAtIndex(num_tracks + 3, true)
local bass = reaper.GetTrack(0, num_tracks + 3)
reaper.GetSetMediaTrackInfo_String(bass, "P_NAME", "Bass Guitar", true)
reaper.SetTrackColor(bass, reaper.ColorToNative(60, 160, 80) + 0x1000000)

-----------------------------------------------------------
-- SEND 1: MIDI Input -> SD3 (all MIDI, no audio)
-----------------------------------------------------------
local send1 = reaper.CreateTrackSend(midi_in, sd3)
reaper.SetTrackSendInfo_Value(midi_in, 0, send1, "I_SRCCHAN", -1)
reaper.SetTrackSendInfo_Value(midi_in, 0, send1, "I_MIDIFLAGS", 0)

-----------------------------------------------------------
-- SEND 2: MIDI Input -> KickLicks (all MIDI, no audio)
-----------------------------------------------------------
local send2 = reaper.CreateTrackSend(midi_in, kicklicks)
reaper.SetTrackSendInfo_Value(midi_in, 0, send2, "I_SRCCHAN", -1)
reaper.SetTrackSendInfo_Value(midi_in, 0, send2, "I_MIDIFLAGS", 0)

-----------------------------------------------------------
-- SEND 3: KickLicks -> Bass (Ch 1 only, no audio)
-----------------------------------------------------------
local send3 = reaper.CreateTrackSend(kicklicks, bass)
reaper.SetTrackSendInfo_Value(kicklicks, 0, send3, "I_SRCCHAN", -1)
reaper.SetTrackSendInfo_Value(kicklicks, 0, send3, "I_MIDIFLAGS", 1)

-----------------------------------------------------------
-- Disable master send on MIDI Input track (no audio to master)
-----------------------------------------------------------
reaper.SetMediaTrackInfo_Value(midi_in, "B_MAINSEND", 0)

-----------------------------------------------------------
-- Done
-----------------------------------------------------------
reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
reaper.Undo_EndBlock("KickLicks Auto-Setup", -1)

local msg = "KickLicks setup complete!\n\n"
msg = msg .. "4 TRACKS CREATED:\n\n"
msg = msg .. "  1. MIDI Input (yellow) - record armed, receives your drum kit\n"
msg = msg .. "     Sends MIDI to both SD3 and KickLicks tracks\n\n"
msg = msg .. "  2. Drums - SD3 (blue) - add Superior Drummer 3 here\n"
msg = msg .. "     Receives ALL drum MIDI from track 1\n\n"
msg = msg .. "  3. KickLicks (orange) - filters kick, generates bass notes\n"
if kl_found then
  msg = msg .. "     KickLicks JSFX loaded, pass-through OFF\n\n"
else
  msg = msg .. "     WARNING: KickLicks JSFX not found! Add it manually.\n\n"
end
msg = msg .. "  4. Bass Guitar (green) - add your bass VST here\n"
msg = msg .. "     Receives ONLY Channel 1 bass notes from KickLicks\n\n"
msg = msg .. "ROUTING (already wired up):\n"
msg = msg .. "  MIDI Input --ALL MIDI--> SD3\n"
msg = msg .. "  MIDI Input --ALL MIDI--> KickLicks\n"
msg = msg .. "  KickLicks  --CH 1 ONLY--> Bass Guitar\n\n"
msg = msg .. "NEXT STEPS:\n"
msg = msg .. "  1. Set MIDI Input track to your PreSonus FireBox\n"
msg = msg .. "  2. Add Superior Drummer 3 on the SD3 track\n"
msg = msg .. "  3. Add your bass VST on the Bass Guitar track\n"
msg = msg .. "  4. Hit your kick drum!\n"

reaper.ShowMessageBox(msg, "KickLicks Auto-Setup", 0)
