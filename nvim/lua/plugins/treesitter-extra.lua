-- Additional treesitter parsers and configuration
-- This extends LazyVim's default treesitter setup
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag", -- Auto close/rename HTML tags
  },
  opts = function(_, opts)
    -- Extend the default ensure_installed list
    local additional_parsers = {
      -- Web Development
      "typescript",
      "tsx",
      "javascript",
      "html",
      "css",
      "scss",
      "json",
      "jsonc",
      
      -- Configuration files
      "yaml",
      "toml",
      "xml",
      
      -- Programming languages
      "python",
      "rust",
      "go",
      "c",
      "cpp",
      "java",
      "c_sharp",
      
      -- Shell and scripting
      "bash",
      "fish",
      "powershell",
      
      -- Documentation
      "markdown",
      "markdown_inline",
      
      -- Other useful parsers
      "regex",
      "dockerfile",
      "gitignore",
      "gitcommit",
      "diff",
    }
    
    -- Merge with existing ensure_installed
    if opts.ensure_installed then
      vim.list_extend(opts.ensure_installed, additional_parsers)
    else
      opts.ensure_installed = additional_parsers
    end

    -- Ensure highlighting is enabled
    opts.highlight = opts.highlight or {}
    opts.highlight.enable = true
    opts.highlight.additional_vim_regex_highlighting = false

    -- Add autotag configuration
    opts.autotag = {
      enable = true,
      enable_rename = true,
      enable_close = true,
      enable_close_on_slash = true,
      filetypes = {
        "html",
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "svelte",
        "vue",
        "tsx",
        "jsx",
        "rescript",
        "xml",
        "php",
        "markdown",
        "astro",
        "glimmer",
        "handlebars",
        "hbs",
      },
    }
    
    -- Enhanced textobjects configuration
    opts.textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    }
    
    return opts
  end,
}
