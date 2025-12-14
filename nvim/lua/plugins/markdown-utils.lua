-- lua/plugins/markdown-utils.lua
-- Additional markdown utilities and enhancements

return {
  -- Table mode for easy table creation and editing
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "org" },
    keys = {
      { "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "Toggle Table Mode" },
      { "<leader>tr", "<cmd>TableModeRealign<cr>", desc = "Realign Table" },
    },
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
      vim.g.table_mode_align_char = ":"
      vim.g.table_mode_delimiter = " | "
      vim.g.table_mode_fillchar = "-"
      vim.g.table_mode_map_prefix = "<Leader>t"
      vim.g.table_mode_toggle_map = "m"
      vim.g.table_mode_delete_row_map = "dd"
      vim.g.table_mode_delete_column_map = "dc"
      vim.g.table_mode_add_formula_map = "fa"
      vim.g.table_mode_eval_formula_map = "fe"
      vim.g.table_mode_echo_cell_map = "?"
      vim.g.table_mode_sort_map = "ts"
      vim.g.table_mode_tableize_map = "tt"
      vim.g.table_mode_tableize_d_map = "T"
    end,
  },

  -- Markdown link utilities
  {
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown",
    keys = {
      { "<leader>mf", "<cmd>MkdnFollowLink<cr>", desc = "Follow Markdown Link" },
      { "<leader>mb", "<cmd>MkdnGoBack<cr>", desc = "Go Back" },
      { "<leader>mn", "<cmd>MkdnNextLink<cr>", desc = "Next Link" },
      { "<leader>mN", "<cmd>MkdnPrevLink<cr>", desc = "Previous Link" },
      { "<leader>ml", "<cmd>MkdnCreateLinkFromClipboard<cr>", desc = "Create Link from Clipboard" },
      { "<leader>mL", "<cmd>MkdnCreateLink<cr>", desc = "Create Link", mode = "v" },
      { "<leader>mt", "<cmd>MkdnToggleToDo<cr>", desc = "Toggle Todo" },
      { "<leader>mT", "<cmd>MkdnNewListItem<cr>", desc = "New List Item" },
    },
    opts = {
      modules = {
        bib = true,
        buffers = true,
        conceal = true,
        cursor = true,
        folds = true,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        yaml = false,
        cmp = false,
      },
      filetypes = { md = true, rmd = true, markdown = true },
      create_dirs = true,
      perspective = {
        priority = "first",
        fallback = "current",
        root_tell = false,
        nvim_wd_heel = false,
        update = false,
      },
      wrap = false,
      bib = {
        default_path = nil,
        find_in_root = true,
      },
      silent = false,
      links = {
        style = "markdown",
        name_is_source = false,
        conceal = false,
        context = 0,
        implicit_extension = nil,
        transform_implicit = false,
        transform_explicit = function(text)
          text = text:gsub(" ", "-")
          text = text:lower()
          text = os.date("%Y-%m-%d_") .. text
          return text
        end,
      },
      new_file_template = {
        use_template = false,
        placeholders = {
          before = {
            title = "link_title",
            date = "os_date",
          },
          after = {},
        },
        template = "# {{ title }}",
      },
      to_do = {
        symbols = { " ", "-", "X" },
        update_parents = true,
        not_started = " ",
        in_progress = "-",
        complete = "X",
      },
      tables = {
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
          cell_padding = 1,
          separator_padding = 1,
          outer_pipes = true,
          mimic_alignment = true,
        },
      },
      yaml = {
        bib = { override = false },
      },
      mappings = {
        MkdnEnter = { { "n", "v" }, "<CR>" },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnNextLink = { "n", "<Tab>" },
        MkdnPrevLink = { "n", "<S-Tab>" },
        MkdnNextHeading = { "n", "]]" },
        MkdnPrevHeading = { "n", "[[" },
        MkdnGoBack = { "n", "<BS>" },
        MkdnGoForward = { "n", "<Del>" },
        MkdnCreateLink = false, -- see keymap
        MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>p" },
        MkdnFollowLink = false, -- see keymap
        MkdnDestroyLink = { "n", "<M-CR>" },
        MkdnTagSpan = { "v", "<M-CR>" },
        MkdnMoveSource = { "n", "<F2>" },
        MkdnYankAnchorLink = { "n", "yaa" },
        MkdnYankFileAnchorLink = { "n", "yfa" },
        MkdnIncreaseHeading = { "n", "+" },
        MkdnDecreaseHeading = { "n", "-" },
        MkdnToggleToDo = { { "n", "v" }, "<C-Space>" },
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = { "n", "o" },
        MkdnNewListItemAboveInsert = { "n", "O" },
        MkdnExtendList = false,
        MkdnUpdateNumbering = { "n", "<leader>nn" },
        MkdnTableNextCell = { "i", "<Tab>" },
        MkdnTablePrevCell = { "i", "<S-Tab>" },
        MkdnTableNextRow = { "i", "<M-CR>" },
        MkdnTablePrevRow = { "i", "<M-S-CR>" },
        MkdnTableNewRowBelow = { "n", "<leader>ir" },
        MkdnTableNewRowAbove = { "n", "<leader>iR" },
        MkdnTableNewColAfter = { "n", "<leader>ic" },
        MkdnTableNewColBefore = { "n", "<leader>iC" },
        MkdnFoldSection = { "n", "<leader>f" },
        MkdnUnfoldSection = { "n", "<leader>F" },
      },
    },
  },

  -- Paste images into markdown
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    ft = { "markdown", "quarto", "latex" },
    keys = {
      { "<leader>mi", "<cmd>PasteImage<cr>", desc = "Paste Image from Clipboard" },
    },
    opts = {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = true,
        drag_and_drop = {
          insert_mode = true,
        },
        use_absolute_path = false,
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          dir_path = "assets",
        },
        quarto = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          dir_path = "assets",
        },
      },
    },
  },
}
