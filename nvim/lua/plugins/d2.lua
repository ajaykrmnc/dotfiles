-- lua/plugins/d2.lua
-- D2 diagram language support
return {
  "terrastruct/d2-vim",
  ft = "d2",
  config = function()
    -- D2 filetype detection and syntax highlighting
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.d2",
      callback = function()
        vim.bo.filetype = "d2"
      end,
    })
  end,
}
