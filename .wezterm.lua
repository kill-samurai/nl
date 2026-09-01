local wezterm = require("wezterm")
local electric = wezterm.plugin.require("https://github.com/Tomauskasz/electric-control-room.wez")
local window_background_opacity = 0.8

local config = wezterm.config_builder()
config.font = wezterm.font_with_fallback {
    "DepartureMono Nerd Font",
    "IosevkaTerm Nerd Font Mono",
    "JetBrainsMono Nerd Font",
}
config.font_size = 18
config.max_fps= 144
config.animation_fps = 144
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

electric.apply_to_config(config, {
  pause_when_idle = true,
  sweep_opacity = 0.24,
  dormant_opacity = 0.14,
})

electric.apply_to_config(config)

return config
