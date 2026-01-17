return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- Prefer LSP for C/C++ (clangd), fall back to treesitter
    backends = { "lsp", "treesitter", "markdown", "man" },

    layout = {
      -- Compact window width
      max_width = { 70, 0.30 },
      width = 55,
      min_width = 45,
      -- Open on the right side
      default_direction = "prefer_right",
      placement = "window",
      -- Resize to fit content
      resize_to_content = true,
      -- Window-local options for aerial window
      win_opts = {
        winblend = 0,
        cursorline = true,
        winhighlight = "Normal:AerialNormal,CursorLine:AerialCursorLine",
        -- Padding: left padding via signcolumn and foldcolumn
        signcolumn = "yes:1",
        foldcolumn = "1",
        numberwidth = 1,
        number = false,
        relativenumber = false,
      },
    },

    -- Show beautiful tree guides with fancy characters
    show_guides = true,
    guides = {
      mid_item = "├── ",
      last_item = "└── ",
      nested_top = "│   ",
      whitespace = "    ",
    },

    -- Highlight settings for better visibility
    highlight_mode = "full_width",
    highlight_closest = true,
    highlight_on_hover = true,
    highlight_on_jump = 500,

    -- Use Nerd Font icons (beautiful custom icons with spacing)
    nerd_font = true,
    icons = {
      Array         = "󰅪 ",
      Boolean       = "󰨙 ",
      Class         = "󰠱 ",
      Collapsed     = "󰅂 ",
      Color         = "󰏘 ",
      Constant      = "󰏿 ",
      Constructor   = "󰒓 ",
      Enum          = "󰕘 ",
      EnumMember    = " ",
      Event         = "󰂚 ",
      Field         = "󰜢 ",
      File          = "󰈙 ",
      Folder        = "󰉋 ",
      Function      = "󰊕 ",
      Interface     = "󰜰 ",
      Key           = "󰌋 ",
      Keyword       = "󰌆 ",
      Method        = "󰆧 ",
      Module        = "󰏗 ",
      Namespace     = "󰅩 ",
      Null          = "󰟢 ",
      Number        = "󰎠 ",
      Object        = "󰅩 ",
      Operator      = "󰆕 ",
      Package       = "󰏖 ",
      Property      = "󰖷 ",
      Reference     = "󰈇 ",
      Snippet       = "󰩫 ",
      String        = "󰉾 ",
      Struct        = "󰙅 ",
      Text          = "󰉿 ",
      TypeParameter = "󰊄 ",
      Unit          = "󰑭 ",
      Value         = "󰎠 ",
      Variable      = "󰀫 ",
    },

    -- Float window styling with double border
    float = {
      border = "double",
      relative = "cursor",
      max_height = 0.9,
      min_height = { 12, 0.25 },
    },

    -- Navigation window styling - more spacious and beautiful
    nav = {
      border = "double",
      max_height = 0.9,
      min_height = { 12, 0.25 },
      max_width = 0.7,
      min_width = { 0.4, 40 },
      win_opts = {
        cursorline = true,
        winblend = 0,
        winhighlight = "Normal:AerialNormal,CursorLine:AerialCursorLine",
      },
      autojump = true,
      preview = true,
    },

    -- Show more symbol kinds for comprehensive outline
    filter_kind = false, -- Show ALL symbols for comprehensive view

    -- Don't auto-close - keep it open for reference
    close_automatic_events = {},

    -- Append function/method parameters to the symbol name
    -- This shows signatures like: myFunction(arg1, arg2)
    post_parse_symbol = function(bufnr, item, ctx)
      -- Only process functions, methods, and constructors
      if item.kind ~= "Function" and item.kind ~= "Method" and item.kind ~= "Constructor" then
        return true
      end

      -- Try to get parameters from the source code directly
      -- This works for all backends (LSP, treesitter, etc.)
      local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, item.lnum - 1, item.lnum + 2, false)
      if ok and lines and #lines > 0 then
        -- Join lines in case params span multiple lines
        local code = table.concat(lines, " ")

        -- Escape special pattern characters in item.name
        local escaped_name = item.name:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")

        -- Try to extract parameters - match function_name followed by (params)
        -- Handle various patterns:
        -- function name(params)
        -- name = function(params)
        -- name: function(params)
        -- def name(params):
        -- void name(params)
        local params = code:match(escaped_name .. "%s*%(([^%)]*)")

        if params then
          -- Clean up the params - keep full "type name" format
          params = params:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
          -- Normalize internal whitespace (multiple spaces to single)
          params = params:gsub("%s+", " ")

          -- Truncate if too long (keep full type + name)
          if #params > 45 then
            params = params:sub(1, 42) .. "..."
          end

          item.name = item.name .. "(" .. params .. ")"
        else
          -- No params found, show empty parens
          item.name = item.name .. "()"
        end
      end

      return true
    end,

    -- Custom function to set highlights per symbol type
    get_highlight = function(symbol, is_icon, is_collapsed)
      -- Return custom highlights based on symbol kind
      if is_icon then
        return "Aerial" .. symbol.kind .. "Icon"
      end
      return "Aerial" .. symbol.kind
    end,
  },
  keys = {
    { "<leader>ao", "<cmd>AerialToggle<CR>", desc = "󰀘  Toggle Aerial Outline" },
    { "<leader>an", "<cmd>AerialNavToggle<CR>", desc = "󰆋  Toggle Aerial Nav" },
    { "<leader>af", "<cmd>AerialToggle float<CR>", desc = "󰉖  Aerial Float" },
    { "{", "<cmd>AerialPrev<CR>", desc = "Aerial Previous Symbol" },
    { "}", "<cmd>AerialNext<CR>", desc = "Aerial Next Symbol" },
    { "[[", "<cmd>AerialPrevUp<CR>", desc = "Aerial Previous Up" },
    { "]]", "<cmd>AerialNextUp<CR>", desc = "Aerial Next Up" },
    { "<leader>as", "<cmd>Telescope aerial<CR>", desc = "󰍉  Aerial Symbol Search" },
  },
  config = function(_, opts)
    require("aerial").setup(opts)

    -- Telescope integration for fuzzy symbol search
    pcall(function()
      require("telescope").load_extension("aerial")
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- Beautiful Catppuccin Mocha-inspired highlight colors
    -- ══════════════════════════════════════════════════════════════════════

    -- Window backgrounds
    vim.api.nvim_set_hl(0, "AerialNormal", { bg = "#1e1e2e" })
    vim.api.nvim_set_hl(0, "AerialCursorLine", { bg = "#45475a", bold = true })
    vim.api.nvim_set_hl(0, "AerialLine", { bg = "#45475a", bold = true })
    vim.api.nvim_set_hl(0, "AerialLineNC", { bg = "#313244" })

    -- Rainbow guides for nested levels
    vim.api.nvim_set_hl(0, "AerialGuide", { fg = "#585b70" })
    vim.api.nvim_set_hl(0, "AerialGuide1", { fg = "#f38ba8" }) -- Red/Pink
    vim.api.nvim_set_hl(0, "AerialGuide2", { fg = "#fab387" }) -- Peach
    vim.api.nvim_set_hl(0, "AerialGuide3", { fg = "#f9e2af" }) -- Yellow
    vim.api.nvim_set_hl(0, "AerialGuide4", { fg = "#a6e3a1" }) -- Green
    vim.api.nvim_set_hl(0, "AerialGuide5", { fg = "#89dceb" }) -- Teal
    vim.api.nvim_set_hl(0, "AerialGuide6", { fg = "#89b4fa" }) -- Blue
    vim.api.nvim_set_hl(0, "AerialGuide7", { fg = "#cba6f7" }) -- Mauve
    vim.api.nvim_set_hl(0, "AerialGuide8", { fg = "#f5c2e7" }) -- Pink

    -- Symbol icon colors (vibrant and distinct)
    vim.api.nvim_set_hl(0, "AerialClassIcon", { fg = "#f9e2af", bold = true }) -- Yellow
    vim.api.nvim_set_hl(0, "AerialClass", { fg = "#f9e2af" })
    vim.api.nvim_set_hl(0, "AerialFunctionIcon", { fg = "#89b4fa", bold = true }) -- Blue
    vim.api.nvim_set_hl(0, "AerialFunction", { fg = "#89b4fa" })
    vim.api.nvim_set_hl(0, "AerialMethodIcon", { fg = "#89dceb", bold = true }) -- Teal
    vim.api.nvim_set_hl(0, "AerialMethod", { fg = "#89dceb" })
    vim.api.nvim_set_hl(0, "AerialConstructorIcon", { fg = "#cba6f7", bold = true }) -- Mauve
    vim.api.nvim_set_hl(0, "AerialConstructor", { fg = "#cba6f7" })
    vim.api.nvim_set_hl(0, "AerialFieldIcon", { fg = "#a6e3a1" }) -- Green
    vim.api.nvim_set_hl(0, "AerialField", { fg = "#a6e3a1" })
    vim.api.nvim_set_hl(0, "AerialVariableIcon", { fg = "#f5c2e7" }) -- Pink
    vim.api.nvim_set_hl(0, "AerialVariable", { fg = "#f5c2e7" })
    vim.api.nvim_set_hl(0, "AerialConstantIcon", { fg = "#fab387", bold = true }) -- Peach
    vim.api.nvim_set_hl(0, "AerialConstant", { fg = "#fab387" })
    vim.api.nvim_set_hl(0, "AerialPropertyIcon", { fg = "#94e2d5" }) -- Teal
    vim.api.nvim_set_hl(0, "AerialProperty", { fg = "#94e2d5" })
    vim.api.nvim_set_hl(0, "AerialEnumIcon", { fg = "#f38ba8", bold = true }) -- Red
    vim.api.nvim_set_hl(0, "AerialEnum", { fg = "#f38ba8" })
    vim.api.nvim_set_hl(0, "AerialEnumMemberIcon", { fg = "#eba0ac" }) -- Maroon
    vim.api.nvim_set_hl(0, "AerialEnumMember", { fg = "#eba0ac" })
    vim.api.nvim_set_hl(0, "AerialInterfaceIcon", { fg = "#74c7ec", bold = true }) -- Sapphire
    vim.api.nvim_set_hl(0, "AerialInterface", { fg = "#74c7ec" })
    vim.api.nvim_set_hl(0, "AerialStructIcon", { fg = "#b4befe", bold = true }) -- Lavender
    vim.api.nvim_set_hl(0, "AerialStruct", { fg = "#b4befe" })
    vim.api.nvim_set_hl(0, "AerialModuleIcon", { fg = "#f2cdcd" }) -- Flamingo
    vim.api.nvim_set_hl(0, "AerialModule", { fg = "#f2cdcd" })
    vim.api.nvim_set_hl(0, "AerialNamespaceIcon", { fg = "#cdd6f4" }) -- Text
    vim.api.nvim_set_hl(0, "AerialNamespace", { fg = "#cdd6f4" })
    vim.api.nvim_set_hl(0, "AerialPackageIcon", { fg = "#f5e0dc" }) -- Rosewater
    vim.api.nvim_set_hl(0, "AerialPackage", { fg = "#f5e0dc" })
    vim.api.nvim_set_hl(0, "AerialStringIcon", { fg = "#a6e3a1" }) -- Green
    vim.api.nvim_set_hl(0, "AerialString", { fg = "#a6e3a1" })
    vim.api.nvim_set_hl(0, "AerialNumberIcon", { fg = "#fab387" }) -- Peach
    vim.api.nvim_set_hl(0, "AerialNumber", { fg = "#fab387" })
    vim.api.nvim_set_hl(0, "AerialBooleanIcon", { fg = "#fab387" }) -- Peach
    vim.api.nvim_set_hl(0, "AerialBoolean", { fg = "#fab387" })
    vim.api.nvim_set_hl(0, "AerialArrayIcon", { fg = "#fab387" }) -- Peach
    vim.api.nvim_set_hl(0, "AerialArray", { fg = "#fab387" })
    vim.api.nvim_set_hl(0, "AerialObjectIcon", { fg = "#f9e2af" }) -- Yellow
    vim.api.nvim_set_hl(0, "AerialObject", { fg = "#f9e2af" })
    vim.api.nvim_set_hl(0, "AerialKeyIcon", { fg = "#f38ba8" }) -- Red
    vim.api.nvim_set_hl(0, "AerialKey", { fg = "#f38ba8" })
    vim.api.nvim_set_hl(0, "AerialNullIcon", { fg = "#6c7086" }) -- Overlay0
    vim.api.nvim_set_hl(0, "AerialNull", { fg = "#6c7086" })
    vim.api.nvim_set_hl(0, "AerialEventIcon", { fg = "#f9e2af" }) -- Yellow
    vim.api.nvim_set_hl(0, "AerialEvent", { fg = "#f9e2af" })
    vim.api.nvim_set_hl(0, "AerialOperatorIcon", { fg = "#89dceb" }) -- Teal
    vim.api.nvim_set_hl(0, "AerialOperator", { fg = "#89dceb" })
    vim.api.nvim_set_hl(0, "AerialTypeParameterIcon", { fg = "#f9e2af" }) -- Yellow
    vim.api.nvim_set_hl(0, "AerialTypeParameter", { fg = "#f9e2af" })
  end,
}
