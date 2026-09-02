local p   = require("config.programs")
local mod = p.mainMod

---- volume --------------------------------------------------------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 10%+"),
    { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"),
    { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, description = "Mute" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, description = "Mute microphone" })

---- brightness ----------------------------------------------------------

hl.bind(mod .. " + F5", hl.dsp.exec_cmd(p.brightness .. " set 10%-"),
    { locked = true, repeating = true, description = "Brightness down" })
hl.bind(mod .. " + F6", hl.dsp.exec_cmd(p.brightness .. " set 10%+"),
    { locked = true, repeating = true, description = "Brightness up" })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(p.brightness .. " set 10%-"),
    { locked = true, repeating = true, description = "Brightness down" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(p.brightness .. " set 10%+"),
    { locked = true, repeating = true, description = "Brightness up" })

---- player --------------------------------------------------------------

hl.bind("ALT + Q", hl.dsp.exec_cmd(p.player("previous")),
    { locked = true, description = "Previous track" })
hl.bind("ALT + W", hl.dsp.exec_cmd(p.player("play-pause")),
    { locked = true, description = "Play/pause" })
hl.bind("ALT + E", hl.dsp.exec_cmd(p.player("next")),
    { locked = true, description = "Next track" })

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
