-- Enhanced Lualine configuration with tmux integration
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- Function to get tmux session name
    local function tmux_session()
      local handle = io.popen("tmux display-message -p '#S' 2>/dev/null")
      if handle then
        local session = handle:read("*a")
        handle:close()
        if session and session ~= "" then
          return "󰘳 " .. session:gsub("\n", "")
        end
      end
      return ""
    end

    -- Function to get word count for markdown files
    local function word_count()
      if vim.bo.filetype == "markdown" then
        local words = vim.fn.wordcount()
        return "󰈭 " .. words.words .. " words"
      end
      return ""
    end

    require("lualine").setup({
      options = {
        theme = "catppuccin",
        component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
        section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            file_status = true,
            newfile_status = false,
            path = 1, -- 0: Just the filename, 1: Relative path, 2: Absolute path, 3: Absolute path with ~ for home
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
              newfile = "[New]",
            },
          },
        },
        lualine_x = {
          word_count,
          tmux_session,
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { "oil", "lazy", "mason" },
    })
  end,
}
