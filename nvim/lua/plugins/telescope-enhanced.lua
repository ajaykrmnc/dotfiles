return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Top telescope extensions
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")
      local excludes = require("config.excludes")

      telescope.setup({
        defaults = {
          file_ignore_patterns = excludes.exclude_patterns,
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              width = 0.9,
              height = 0.9,
              preview_width = 0.55,
              results_width = 0.45,
            },
          },
          -- Custom mappings
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
            n = {
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
      })

      -- Enhanced keymaps
      local keymap = vim.keymap.set

      -- File operations
      keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      keymap("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      keymap("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      keymap("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
      keymap("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })

      -- Git operations
      keymap("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      keymap("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
      keymap("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

      -- LSP operations
      keymap("n", "gd", builtin.lsp_definitions, { desc = "LSP definitions" })
      keymap("n", "grr", builtin.lsp_references, { desc = "LSP references" })
      keymap("n", "grd", builtin.diagnostics, { desc = "Diagnostics" })
      keymap("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
      keymap("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })

      -- Search operations
      keymap("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
      keymap("n", "<leader>fc", builtin.commands, { desc = "Commands" })
      keymap("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
      keymap("n", "<leader>fm", builtin.marks, { desc = "Marks" })
      keymap("n", "<leader>fj", builtin.jumplist, { desc = "Jump list" })
      keymap("n", "<leader>fq", builtin.quickfix, { desc = "Quickfix" })
      keymap("n", "<leader>fl", builtin.loclist, { desc = "Location list" })
    end,
  },
}
