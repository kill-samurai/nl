local wezterm = require('wezterm')
local platform = require('utils.platform')

---@type Config
local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   options.default_domain = 'wsl:ubuntu-fish'
   options.launch_menu = {
      { label = 'Ubuntu (Fish)', domain = { DomainName = 'wsl:ubuntu-fish' } },
      { label = 'Ubuntu (Bash)', domain = { DomainName = 'wsl:ubuntu-bash' } },
      { label = 'PowerShell Core', args = { 'pwsh', '-NoLogo' } },
      { label = 'PowerShell Desktop', args = { 'powershell' } },
      { label = 'Command Prompt', args = { 'cmd' } },
      { label = 'Nushell', args = { 'nu' } },
   }
elseif platform.is_mac then
   local fish = wezterm.target_triple:find('aarch64')
      and '/opt/homebrew/bin/fish'
      or '/usr/local/bin/fish'
   options.default_prog = { fish, '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { fish, '-l' } },
      { label = 'Nushell', args = { '/opt/homebrew/bin/nu', '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
   }
elseif platform.is_linux then
   options.default_prog = { 'fish', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { 'fish', '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
   }
end

return options
