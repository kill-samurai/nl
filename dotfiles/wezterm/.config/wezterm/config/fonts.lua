local wezterm = require('wezterm')
local platform = require('utils.platform')

-- Use a font included with Windows so a fresh setup does not require manual
-- font installation. Other platforms use the Nerd Font installed by Brewfile.
local font_family = platform.is_win and 'Consolas' or 'DepartureMono Nerd Font Mono'
-- local font_family = 'CartographCF Nerd Font'

local font_size = platform.is_mac and 18 or 9.75

---@type Config
return {
    font = wezterm.font_with_fallback({
       font_family,
       'JetBrainsMono Nerd Font Mono',
       'Cascadia Mono',
       'Consolas',
    }),
   font_size = font_size,

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
