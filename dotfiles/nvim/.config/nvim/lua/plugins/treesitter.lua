return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    config = function()
	local config = require('nvim-treesitter.config')
	config.setup({
	    highlitght = { enable = true },
	    indent = { enable = true },
	    autotag = { enable = true },
	    ensure_installed = { 'lua', 'tsx', 'typescript', 'javascript', 'http', 'html', 'kotlin', 'python', 'bash', 'c', },
	    auto_install = true,

	})
    end
}
