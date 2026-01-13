-- lua/plugins/git.lua
return {
  {
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
		},
		config = function()
			require('neogit').setup({
				disable_insert_on_commit = true,
				use_default_keymaps = true,
				graph_style = "unicode",
			})
			vim.keymap.set('n', "<leader>gg", require('neogit').open, { desc = "Open Neogit" })
		end
	},
    { "lewis6991/gitsigns.nvim", opts = {} }, -- inline git diff & signs
    { "sindrets/diffview.nvim" }, -- like GitLens diff view
}
