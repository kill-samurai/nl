return {
    {-- git plugin
	'tpope/vim-fugitive',},
    {-- show css colors
	'brenoprata10/nvim-highlight-colors',
	config = function()
	    require('nvim-highlight-colors').setup({})
	end},
    { -- codex access
	"nwiizo/codex.nvim",
	config = function()
	    require("codex").setup({})
	end
    },

}
