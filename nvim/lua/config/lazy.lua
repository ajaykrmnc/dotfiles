-- ~/.config/nvim/lua/lazy.lua

-- Set <Space> as leader key
-- NOTE: Must happen before loading plugins, otherwise wrong leader is used
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true -- true color support
vim.opt.cursorline = false

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    ------------------------------------------------------------------------
    -- Base LazyVim
    ------------------------------------------------------------------------
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    ------------------------------------------------------------------------
    -- Load your custom plugin files
    ------------------------------------------------------------------------
    { import = "plugins" }, -- loads all files in lua/plugins/

    ------------------------------------------------------------------------
    -- Workspace / Project handling
    ------------------------------------------------------------------------
    {
      "ahmedkhalf/project.nvim",
      event = "VeryLazy",
      config = function()
        require("project_nvim").setup({
          detection_methods = { "pattern", "lsp" },
          patterns = { ".git", "package.json", "tsconfig.json", "angular.json" },
        })
      end,
    },
    -- Telescope configuration moved to lua/plugins/telescope-enhanced.lua
  },

  ------------------------------------------------------------------------
  -- Lazy.nvim global settings
  ------------------------------------------------------------------------
  defaults = {
    lazy = false, -- load plugins immediately
    version = false, -- always use latest git commit
  },
  install = { colorscheme = { "catppuccin", "tokyonight", "github_dark", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
