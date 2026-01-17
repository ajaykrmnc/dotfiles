-- Cscope integration for Neovim
-- Provides code navigation for C/C++ projects
return {
  "dhananjaylatkar/cscope_maps.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- for picker="telescope"
  },
  ft = { "c", "cpp", "h", "hpp" }, -- Load only for C/C++ files
  cmd = { "Cscope", "Cs", "Cstag", "CsPrompt", "CsStackView" },
  keys = {
    -- Symbol references
    { "<leader>cs", "<cmd>Cs find s<cr>", desc = "󰈞 Cscope: Symbol references" },
    -- Global definition
    { "<leader>cg", "<cmd>Cs find g<cr>", desc = "󰈞 Cscope: Global definition" },
    -- Functions calling this function
    { "<leader>cc", "<cmd>Cs find c<cr>", desc = "󰈞 Cscope: Callers" },
    -- Text string
    { "<leader>ct", "<cmd>Cs find t<cr>", desc = "󰈞 Cscope: Text search" },
    -- Egrep pattern
    { "<leader>ce", "<cmd>Cs find e<cr>", desc = "󰈞 Cscope: Egrep" },
    -- Find file
    { "<leader>cf", "<cmd>Cs find f<cr>", desc = "󰈞 Cscope: Find file" },
    -- Files including this file
    { "<leader>ci", "<cmd>Cs find i<cr>", desc = "󰈞 Cscope: Files including" },
    -- Functions called by this function
    { "<leader>cd", "<cmd>Cs find d<cr>", desc = "󰈞 Cscope: Callees" },
    -- Assignments to symbol
    { "<leader>ca", "<cmd>Cs find a<cr>", desc = "󰈞 Cscope: Assignments" },
    -- Build cscope database
    { "<leader>cb", "<cmd>Cs db build<cr>", desc = "󰈞 Cscope: Build database" },
    -- Stack view - callers tree
    { "<leader>cS", "<cmd>CsStackView open down<cr>", desc = "󰈞 Cscope: Stack (callers)" },
    -- Stack view - callees tree
    { "<leader>cU", "<cmd>CsStackView open up<cr>", desc = "󰈞 Cscope: Stack (callees)" },
  },
  opts = {
    -- Disable default maps (we define our own above)
    disable_maps = true,
    -- Don't ask for input - use word under cursor
    skip_input_prompt = true,
    -- Prefix for default keymaps (if enabled)
    prefix = "<leader>c",

    cscope = {
      -- Location of cscope database file
      db_file = "./cscope.out",
      -- Cscope executable (cscope or gtags-cscope)
      exec = "cscope",
      -- Use telescope for results
      picker = "telescope",
      -- Picker window options
      picker_opts = {
        window_size = 10,
        window_pos = "bottom",
      },
      -- Jump directly for single result
      skip_picker_for_single_result = true,
      -- Database build command
      db_build_cmd = {
        script = "default",
        args = { "-bqkv" },
      },
      -- Statusline indicator
      statusline_indicator = "cscope",
      -- Project rooter - find cscope.out in parent directories
      project_rooter = {
        enable = true,
        change_cwd = false,
      },
      -- Cstag settings
      tag = {
        keymap = true, -- Bind :Cstag to <C-]>
        order = { "cs", "tag_picker", "tag" },
        tag_cmd = "tjump",
      },
    },

    -- Stack view settings
    stack_view = {
      tree_hl = true, -- Highlight tree
    },
  },
  config = function(_, opts)
    require("cscope_maps").setup(opts)

    -- Create autocmd to rebuild cscope db on save for C/C++ files
    local group = vim.api.nvim_create_augroup("CscopeBuildOnSave", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc", "*.hh" },
      callback = function()
        -- Only rebuild if cscope.out exists in current or parent directory
        if vim.fn.filereadable("cscope.out") == 1 then
          vim.cmd("Cscope db build")
        end
      end,
      group = group,
    })
  end,
}

