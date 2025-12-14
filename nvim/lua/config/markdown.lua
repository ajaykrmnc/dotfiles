-- lua/config/markdown.lua
-- Markdown-specific configuration and keymaps

-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  group = vim.api.nvim_create_augroup("CustomMarkdownSettings", { clear = true }),
  callback = function()
    local opts = { buffer = true, silent = true }

    -- Enable spell checking for markdown but disable error underlines
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"

    -- Disable spell error underlines by clearing spell highlights
    vim.cmd([[
      highlight clear SpellBad
      highlight clear SpellCap
      highlight clear SpellRare
      highlight clear SpellLocal
    ]])

    -- Enable text wrapping for markdown
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true

    -- Set text width to 78 characters for formatting
    vim.opt_local.textwidth = 78

    -- Disable colorcolumn for markdown files only
    vim.opt_local.colorcolumn = ""

    -- Set conceallevel for better markdown rendering
    vim.opt_local.conceallevel = 2

    -- Enable formatting with gq command and auto-wrap at textwidth
    vim.opt_local.formatoptions = "tcqjnwa"

    -- Markdown-specific keymaps
    local keymap = vim.keymap.set

    -- Custom format function for markdown
    local function format_markdown()
      -- Save cursor position
      local cursor_pos = vim.api.nvim_win_get_cursor(0)

      -- Format the entire buffer using gq
      vim.cmd("normal! ggVGgq")

      -- Restore cursor position
      vim.api.nvim_win_set_cursor(0, cursor_pos)
    end

    -- Override the LSP format keymap for markdown
    keymap("n", "<leader>bf", format_markdown, vim.tbl_extend("force", opts, { desc = "Format markdown buffer" }))

    -- Text formatting
    keymap("n", "<leader>mb", "viwS*", vim.tbl_extend("force", opts, { desc = "Bold word" }))
    keymap("v", "<leader>mb", "S*", vim.tbl_extend("force", opts, { desc = "Bold selection" }))
    keymap("n", "<leader>mi", "viwS_", vim.tbl_extend("force", opts, { desc = "Italic word" }))
    keymap("v", "<leader>mi", "S_", vim.tbl_extend("force", opts, { desc = "Italic selection" }))
    keymap("n", "<leader>mc", "viw<esc>a`<esc>bi`<esc>", vim.tbl_extend("force", opts, { desc = "Code word" }))
    keymap("v", "<leader>mc", "<esc>`>a`<esc>`<i`<esc>", vim.tbl_extend("force", opts, { desc = "Code selection" }))

    -- Headers
    keymap("n", "<leader>m1", "I# <esc>", vim.tbl_extend("force", opts, { desc = "H1 Header" }))
    keymap("n", "<leader>m2", "I## <esc>", vim.tbl_extend("force", opts, { desc = "H2 Header" }))
    keymap("n", "<leader>m3", "I### <esc>", vim.tbl_extend("force", opts, { desc = "H3 Header" }))
    keymap("n", "<leader>m4", "I#### <esc>", vim.tbl_extend("force", opts, { desc = "H4 Header" }))
    keymap("n", "<leader>m5", "I##### <esc>", vim.tbl_extend("force", opts, { desc = "H5 Header" }))
    keymap("n", "<leader>m6", "I###### <esc>", vim.tbl_extend("force", opts, { desc = "H6 Header" }))

    -- Lists
    keymap("n", "<leader>ml", "I- <esc>", vim.tbl_extend("force", opts, { desc = "Bullet list item" }))
    keymap("n", "<leader>mn", "I1. <esc>", vim.tbl_extend("force", opts, { desc = "Numbered list item" }))
    keymap("n", "<leader>mx", "I- [ ] <esc>", vim.tbl_extend("force", opts, { desc = "Checkbox item" }))

    -- Links and images
    keymap("n", "<leader>mk", "a[]()<esc>F]i", vim.tbl_extend("force", opts, { desc = "Insert link" }))
    keymap("v", "<leader>mk", "<esc>`>a)<esc>`<i[<esc>f)i", vim.tbl_extend("force", opts, { desc = "Link selection" }))
    keymap("n", "<leader>mI", "a![]()<esc>F]i", vim.tbl_extend("force", opts, { desc = "Insert image" }))

    -- Code blocks
    keymap("n", "<leader>mC", "o```<cr>```<esc>O", vim.tbl_extend("force", opts, { desc = "Code block" }))

    -- Horizontal rule
    keymap("n", "<leader>mr", "o---<esc>", vim.tbl_extend("force", opts, { desc = "Horizontal rule" }))

    -- Quote
    keymap("n", "<leader>mq", "I> <esc>", vim.tbl_extend("force", opts, { desc = "Quote line" }))
    keymap("v", "<leader>mq", ":s/^/> /<cr>:noh<cr>", vim.tbl_extend("force", opts, { desc = "Quote selection" }))

    -- Table shortcuts
    keymap(
      "n",
      "<leader>mT",
      "o| Column 1 | Column 2 | Column 3 |<cr>|----------|----------|----------|<cr>| Cell 1   | Cell 2   | Cell 3   |<esc>",
      vim.tbl_extend("force", opts, { desc = "Insert table" })
    )
  end,
})

-- Auto-save markdown files when focus is lost
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "*.md",
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})

-- Automatically create parent directories when saving markdown files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Set up markdown folding
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldenable = false -- Start with folds open
  end,
})

-- Markdown live word count in statusline
local function get_word_count()
  if vim.bo.filetype == "markdown" then
    local words = vim.fn.wordcount()
    return string.format("Words: %d", words.words)
  end
  return ""
end

-- Add word count to lualine if it exists
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- This will be picked up by lualine if configured
    vim.b.word_count = get_word_count()
  end,
})

-- Update word count on text change
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = "*.md",
  callback = function()
    vim.b.word_count = get_word_count()
  end,
})

-- Markdown snippet-like functionality for common patterns
local function insert_date()
  local date = os.date("%Y-%m-%d")
  vim.api.nvim_put({ date }, "c", true, true)
end

local function insert_time()
  local time = os.date("%H:%M")
  vim.api.nvim_put({ time }, "c", true, true)
end

local function insert_datetime()
  local datetime = os.date("%Y-%m-%d %H:%M")
  vim.api.nvim_put({ datetime }, "c", true, true)
end

-- Create user commands for date/time insertion
vim.api.nvim_create_user_command("MdInsertDate", insert_date, { desc = "Insert current date" })
vim.api.nvim_create_user_command("MdInsertTime", insert_time, { desc = "Insert current time" })
vim.api.nvim_create_user_command("MdInsertDateTime", insert_datetime, { desc = "Insert current date and time" })

-- Keymaps for date/time insertion (only in markdown files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "<leader>md", insert_date, vim.tbl_extend("force", opts, { desc = "Insert date" }))
    vim.keymap.set("n", "<leader>mD", insert_datetime, vim.tbl_extend("force", opts, { desc = "Insert datetime" }))
    vim.keymap.set("i", "<C-d>", insert_date, vim.tbl_extend("force", opts, { desc = "Insert date" }))
    vim.keymap.set("i", "<C-t>", insert_time, vim.tbl_extend("force", opts, { desc = "Insert time" }))
  end,
})
