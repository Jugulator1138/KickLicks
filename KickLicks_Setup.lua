-- KickLicks_Setup.lua
-- REAPER Script: Auto-creates tracks and MIDI routing for KickLicks
--
-- HOW TO RUN:
--   1. In REAPER, go to Actions > Show Action List
--   2. Click "New action..." > "Load ReaScript..."
--   3. Browse to this file and select it
--   4. Click "Run" (or assign a shortcut)

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

-- Get current track count so we insert at the end
local num_tracks = reaper.CountTracks(0)

-----------------------------------------------------
-- TRACK 1: Drums (KickLicks + Superior Drummer 3)
-----------------------------------------------------
reaper.InsertTrackAtIndex(num_tracks, true)
local drums = reaper.GetTrack(0, num_tracks)
reaper.GetSetMediaTrackInfo_String(drums, "P_NAME", "Drums - KickLicks + SD3", true)

-- Record arm the drums track
reaper.SetMediaTrackInfo_Value(drums, "I_RECARM", 1)

-- Set input to All MIDI Inputs, All Channels
-- Encoding: 4096 (MIDI flag) + 62*32 (all devices) + 0 (all channels)
reaper.SetMediaTrackInfo_Value(drums, "I_RECINPUT", 4096 + 62 * 32 + 0)

-- Enable input monitoring so you hear it live
reaper.SetMediaTrackInfo_Value(drums, "I_RECMON", 1)

-- Try to add KickLicks JSFX
local kl_found = false
local kl_idx = reaper.TrackFX_AddByName(drums, "JS:KickLicks - Kick Drum Bassline Generator", false, -1)
if kl_idx >= 0 then
  kl_found = true
else
  -- Try alternate names in case file is in a subfolder
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

-----------------------------------------------------
-- TRACK 2: Bass Guitar
-----------------------------------------------------
reaper.InsertTrackAtIndex(num_tracks + 1, true)
local bass = reaper.GetTrack(0, num_tracks + 1)
reaper.GetSetMediaTrackInfo_String(bass, "P_NAME", "Bass Guitar", true)

-- Color the tracks for easy identification
-- Drums = blue, Bass = green
reaper.SetTrackColor(drums, reaper.ColorToNative(60, 100, 180) | 0x1000000)
reaper.SetTrackColor(bass, reaper.ColorToNative(60, 160, 80) | 0x1000000)

-----------------------------------------------------
-- MIDI SEND: Drums -> Bass (Channel 1 only)
-----------------------------------------------------
local send_idx = reaper.CreateTrackSend(drums, bass)

-- Disable audio on this send (we only want MIDI)
-- I_SRCCHAN = -1 means no audio channels
reaper.SetTrackSendInfo_Value(drums, 0, send_idx, "I_SRCCHAN", -1)

-- MIDI flags: only pass Channel 1 (the KickLicks output channel)
-- Bits 0-4 = source channel filter (0=all, 1=ch1 only, 2=ch2, etc.)
-- Bits 5-9 = dest channel (0=keep original)
-- Value of 1 = only channel 1, keep original routing
reaper.SetTrackSendInfo_Value(drums, 0, send_idx, "I_MIDIFLAGS", 1)

-----------------------------------------------------
-- Done
-----------------------------------------------------
reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
reaper.Undo_EndBlock("KickLicks Auto-Setup", -1)

-- Build status message
local msg = "KickLicks setup complete!\n\n"

msg = msg .. "CREATED TRACKS:\n"
msg = msg .. "  Track: 'Drums - KickLicks + SD3' (blue)\n"
msg = msg .. "    - Record armed with MIDI input enabled\n"
msg = msg .. "    - Input monitoring ON\n"
if kl_found then
  msg = msg .. "    - KickLicks JSFX loaded in FX chain\n"
else
  msg = msg .. "    - WARNING: KickLicks JSFX not found!\n"
  msg = msg .. "      Copy KickLicks.jsfx to your REAPER Effects folder,\n"
  msg = msg .. "      then rescan (Options > Preferences > Plug-ins > JS > Re-scan)\n"
  msg = msg .. "      and add it manually to this track's FX chain.\n"
end
msg = msg .. "\n"
msg = msg .. "  Track: 'Bass Guitar' (green)\n"
msg = msg .. "    - Receives MIDI from Drums track, Channel 1 only\n"
msg = msg .. "\n"
msg = msg .. "MIDI ROUTING (already configured):\n"
msg = msg .. "  Drums -> Bass send: MIDI Channel 1 only, no audio\n"
msg = msg .. "\n"
msg = msg .. "NEXT STEPS:\n"
msg = msg .. "  1. Click the input dropdown on the Drums track\n"
msg = msg .. "     and select: Input MIDI > PreSonus FireBox\n"
msg = msg .. "  2. Open FX on Drums track, add Superior Drummer 3\n"
msg = msg .. "     AFTER KickLicks (KickLicks must be first!)\n"
msg = msg .. "  3. Open FX on Bass track, add your bass guitar VST\n"
msg = msg .. "  4. Hit your kick drum - you should hear bass notes!\n"
msg = msg .. "\n"
msg = msg .. "TROUBLESHOOTING:\n"
msg = msg .. "  - Make sure KickLicks Input Channel = 10 (your TD-5)\n"
msg = msg .. "  - Make sure KickLicks Output Channel = 1\n"
msg = msg .. "  - Make sure KickLicks Trigger Note = 36 (kick)\n"
msg = msg .. "  - Make sure Pass-Through = Yes\n"

reaper.ShowMessageBox(msg, "KickLicks Auto-Setup", 0)
