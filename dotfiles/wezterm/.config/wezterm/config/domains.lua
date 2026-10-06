local platform = require('utils.platform')

---@type Config
local options = {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = {},

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {},
}

if platform.is_win then
   options.wsl_domains = {
      {
         name = 'wsl:ubuntu-fish',
         distribution = 'Ubuntu',
         default_prog = {
            'bash',
            '-lc',
            'if command -v fish >/dev/null 2>&1; then exec fish -l; else exec bash -l; fi',
         },
      },
      {
         name = 'wsl:ubuntu-bash',
         distribution = 'Ubuntu',
         default_prog = { 'bash', '-l' },
      },
   }
end

return options
