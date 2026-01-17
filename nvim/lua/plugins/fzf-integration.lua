-- FZF integration for better tag navigation
return {
  -- FZF binary
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  
  -- FZF.vim for Vim integration
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    config = function()
      -- FZF default options
      vim.env.FZF_DEFAULT_OPTS = "--layout=reverse --info=inline"
      
      -- FZF layout
      vim.g.fzf_layout = { window = { width = 0.9, height = 0.6 } }
      
      -- Custom FZF commands for tags
      vim.api.nvim_create_user_command("FzfTags", "Tags", { desc = "FZF Tags" })
      vim.api.nvim_create_user_command("FzfBTags", "BTags", { desc = "FZF Buffer Tags" })
      
      -- Key mappings for FZF tag navigation
      vim.keymap.set("n", "<leader>ft", "<cmd>Tags<CR>", { desc = "FZF Tags" })
      vim.keymap.set("n", "<leader>fT", "<cmd>BTags<CR>", { desc = "FZF Buffer Tags" })
      vim.keymap.set("n", "<leader>f/", "<cmd>BLines<CR>", { desc = "FZF Buffer Lines" })
      
      -- Enhanced tag preview with comprehensive ctags options for C/C++
      vim.g.fzf_tags_command = "ctags -R --fields=+ailmnSzktfFprs --extras=+qfF --kinds-all=* --languages=C,C++ --c-kinds=+defgpstuvxz --c++-kinds=+cdefgmnpstuvxz --sort=yes"
      vim.g.fzf_preview_window = { "right:50%", "ctrl-/" }
    end,
  },
}
