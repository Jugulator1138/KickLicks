-- KickLicks_Setup.lua
-- REAPER Script: Auto-creates tracks and MIDI routing for KickLicks
-- Run from: Actions, Show Action List, New action, Load ReaScript

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local num_tracks = reaper.CountTracks(0)

-- Create Drums track
reaper.InsertTrackAtIndex(num_tracks, true)
local drums = reaper.GetTrack(0, num_tracks)
reaper.GetSetMediaTrackInfo_String(drums, "P_NAME", "Drums - KickLicks + SD3", true)

-- Record arm, MIDI input (all devices all channels), monitor on
reaper.SetMediaTrackInfo_Value(drums, "I_RECARM", 1)
reaper.SetMediaTrackInfo_Value(drums, "I_RECINPUT", 4096 + 62 * 32)
reaper.SetMediaTrackInfo_Value(drums, "I_RECMON", 1)

-- Try to add KickLicks JSFX
local kl_found = false
local kl_idx = reaper.TrackFX_AddByName(drums, "JS:KickLicks - Kick Drum Bassline Generator", false, -1)
if kl_idx >= 0 then
  kl_found = true
else
  kl_idx = reaper.TrackFX_AddByName(drums, "JS:KickLicks", false, -1)
  if kl_idx >= 0 then
    kl_found = true
  else
    kl_idx = reaper.TrackFX_AddByName(drums, "JS:KickLicks/KickLicks", false, -1)
    if kl_idx >= 0 then
      kl_found = true
    end
  end
end

-- Create Bass track
reaper.InsertTrackAtIndex(num_tracks + 1, true)
local bass = reaper.GetTrack(0, num_tracks + 1)
reaper.GetSetMediaTrackInfo_String(bass, "P_NAME", "Bass Guitar", true)

-- Color tracks: Drums = blue, Bass = green
reaper.SetTrackColor(drums, reaper.ColorToNative(60, 100, 180) + 0x1000000)
reaper.SetTrackColor(bass, reaper.ColorToNative(60, 160, 80) + 0x1000000)

-- Create MIDI send from Drums to Bass
local send_idx = reaper.CreateTrackSend(drums, bass)

-- Disable audio on the send (MIDI only)
reaper.SetTrackSendInfo_Value(drums, 0, send_idx, "I_SRCCHAN", -1)

-- MIDI flags: only pass Channel 1 (KickLicks output)
-- Low 5 bits = source channel (1 = ch1 only), next 5 bits = dest (0 = keep original)
reaper.SetTrackSendInfo_Value(drums, 0, send_idx, "I_MIDIFLAGS", 1)

reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
reaper.Undo_EndBlock("KickLicks Auto-Setup", -1)

-- Show result
local msg = "KickLicks setup complete!\n\n"
msg = msg .. "CREATED:\n"
msg = msg .. "  Drums track (blue) - record armed, MIDI input on\n"
if kl_found then
  msg = msg .. "  KickLicks JSFX loaded in FX chain\n"
else
  msg = msg .. "  WARNING: KickLicks JSFX not found! Install it first.\n"
end
msg = msg .. "  Bass Guitar track (green)\n"
msg = msg .. "  MIDI send: Drums to Bass, Channel 1 only, no audio\n"
msg = msg .. "\n"
msg = msg .. "NEXT STEPS:\n"
msg = msg .. "  1. Set Drums track input to your PreSonus FireBox\n"
msg = msg .. "  2. Add Superior Drummer 3 AFTER KickLicks on Drums track\n"
msg = msg .. "  3. Add bass guitar VST on Bass track\n"
msg = msg .. "  4. Hit your kick drum!\n"

reaper.ShowMessageBox(msg, "KickLicks Auto-Setup", 0)
