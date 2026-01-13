-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ~/.config/nvim/lua/options.lua

local opt = vim.opt

-----------------------------------------------------------------------
-- General Editor Settings (VS Code style)
-----------------------------------------------------------------------
opt.number = true              -- show line numbers
opt.relativenumber = true      -- relative line numbers
opt.cursorline = true          -- highlight current line
opt.signcolumn = "yes"         -- always show sign column
opt.updatetime = 250           -- faster diagnostics update
opt.undofile = true


-----------------------------------------------------------------------
-- Indentation
-----------------------------------------------------------------------
opt.expandtab = true           -- convert tabs to spaces
opt.shiftwidth = 2             -- indent size
opt.tabstop = 2                -- tab size
opt.smartindent = true         -- auto-indent new lines

-----------------------------------------------------------------------
-- Search
-----------------------------------------------------------------------
opt.ignorecase = true          -- case insensitive search
opt.smartcase = true           -- unless capitals in search
opt.hlsearch = true            -- highlight matches
opt.incsearch = true           -- incremental search

-----------------------------------------------------------------------
-- Formatting and Whitespaces (VS Code like)
-----------------------------------------------------------------------
opt.wrap = false
opt.scrolloff = 8              -- keep lines visible when scrolling
opt.sidescrolloff = 8
opt.list = true                -- show invisible chars
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" }

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-----------------------------------------------------------------------
-- Rulers (similar to VS Code "editor.rulers")
-----------------------------------------------------------------------
opt.colorcolumn = "120" -- 120 char ruler

-----------------------------------------------------------------------
-- Split behavior
-----------------------------------------------------------------------
opt.splitbelow = true
opt.splitright = true

-----------------------------------------------------------------------
-- Shell configuration (for git commands and external tools)
-----------------------------------------------------------------------
opt.shell = "/bin/zsh"
opt.shellcmdflag = "-c"
opt.shellquote = ""
opt.shellxquote = ""
