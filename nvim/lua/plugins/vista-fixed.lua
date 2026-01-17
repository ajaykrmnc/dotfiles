-- Enhanced Vista.vim configuration with proper FZF integration
return {
  -- Vista.vim - Modern tagbar alternative with LSP support
  {
    "liuchengxu/vista.vim",
    dependencies = {
      "junegunn/fzf.vim", -- Required for Vista finder functionality
      "junegunn/fzf", -- FZF binary
    },
    cmd = { "Vista" },
    keys = {
      { "<leader>tv", ":Vista\\!\\!<CR>", desc = "Toggle Vista" },
      { "<leader>tV", ":Vista finder<CR>", desc = "Vista finder" },
      { "<leader>tf", ":Vista finder ctags<CR>", desc = "Vista finder (ctags)" },
    },
    config = function()
      -- Set Vista to use ctags by default
      vim.g.vista_default_executive = "ctags"

      -- Ensure FZF is available for Vista finder
      vim.g.vista_fzf_preview = { "right:50%" }
      vim.g.vista_finder_alternative_executives = { "ctags" }

      -- Configure Vista to work with our tags file
      vim.g.vista_ctags_executable = "ctags"
      vim.g.vista_ctags_options =
        "--fields=+ailmnSzkt --extras=+qfF --output-format=e-ctags --recurse=true --kinds-all=* --map-C++=+.h --map-C++=+.hpp --map-C++=+.hxx --map-C++=+.hh --sort=yes"

      -- C/C++ language support only
      vim.g.vista_executive_for = {
        c = "ctags",
        cpp = "ctags",
      }

      -- Vista appearance settings
      vim.g.vista_icon_indent = { "╰─▸ ", "├─▸ " }
      vim.g.vista_sidebar_width = 65
      vim.g.vista_echo_cursor = 0
      vim.g.vista_close_on_jump = 0
      vim.g.vista_stay_on_open = 1
      vim.g.vista_blink = { 0, 0 } -- Disable the bright blink effect

      -- Catppuccin Mocha-inspired highlight colors for Vista
      -- Override the bright IncSearch used by Vista blink with softer colors
      vim.api.nvim_set_hl(0, "VistaMatch", { bg = "#45475a", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "VistaBlink", { bg = "#45475a", fg = "#cdd6f4" })

      -- Enable cursorline in Vista sidebar with Catppuccin colors
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "vista", "vista_kind" },
        callback = function()
          -- Enable cursorline for better visibility
          vim.opt_local.cursorline = true
          -- Set softer highlight colors
          vim.api.nvim_set_hl(0, "Search", { bg = "#45475a", fg = "#cdd6f4" })
          vim.api.nvim_set_hl(0, "IncSearch", { bg = "#45475a", fg = "#cdd6f4" })
          -- Set cursorline highlight for Vista (Catppuccin surface1)
          vim.api.nvim_set_hl(0, "CursorLine", { bg = "#45475a" })
        end,
      })

      -- Disable Vista for certain filetypes where it might cause issues
      vim.g.vista_ignore_kinds = {}

      -- Custom Vista commands
      vim.api.nvim_create_user_command("VistaRefresh", function()
        vim.cmd("Vista\\!")
        vim.cmd("Vista\\!\\!")
      end, { desc = "Refresh Vista" })

      -- Helper function to safely close a timer
      local function safe_close_timer(timer)
        if timer and not timer:is_closing() then
          timer:stop()
          timer:close()
        end
      end

      -- Smooth scroll function for source window
      local function smooth_scroll_to(win, target_line)
        local current_line = vim.api.nvim_win_get_cursor(win)[1]
        local diff = target_line - current_line
        if diff == 0 then
          return
        end

        local step = diff > 0 and 1 or -1
        local abs_diff = math.abs(diff)
        -- Adjust speed based on distance
        local delay = abs_diff > 100 and 1 or (abs_diff > 50 and 2 or 3)
        -- Larger steps for big jumps
        local jump_size = abs_diff > 200 and 8 or (abs_diff > 100 and 4 or (abs_diff > 50 and 2 or 1))

        local lines_moved = 0
        local timer = vim.loop.new_timer()
        if not timer then
          return
        end

        timer:start(
          0,
          delay,
          vim.schedule_wrap(function()
            if not vim.api.nvim_win_is_valid(win) then
              safe_close_timer(timer)
              return
            end
            lines_moved = lines_moved + jump_size
            local new_line = current_line + (step * math.min(lines_moved, abs_diff))
            -- Clamp to valid range
            local buf = vim.api.nvim_win_get_buf(win)
            local max_line = vim.api.nvim_buf_line_count(buf)
            new_line = math.max(1, math.min(new_line, max_line))

            vim.api.nvim_win_set_cursor(win, { new_line, 0 })

            if lines_moved >= abs_diff then
              safe_close_timer(timer)
              -- Center the final position
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_call(win, function()
                  vim.cmd("normal\\! zz")
                end)
              end
            end
          end)
        )
      end

      -- Custom keybinding: scroll to symbol without losing focus on Vista
      -- Press 'o' in Vista sidebar to smooth scroll to symbol but stay in Vista
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "vista", "vista_kind" },
        callback = function()
          vim.keymap.set("n", "o", function()
            local cur_line = vim.fn.getline(".")
            -- Extract line number from Vista line format (ends with :lnum)
            local lnum = cur_line:match(":(%d+)%s*$")
            if lnum then
              lnum = tonumber(lnum)
              -- Get the source window and buffer
              local source_bufnr = vim.g.vista and vim.g.vista.source and vim.g.vista.source.bufnr
              if source_bufnr then
                -- Find the window displaying the source buffer
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  if vim.api.nvim_win_get_buf(win) == source_bufnr then
                    -- Smooth scroll to the target line
                    smooth_scroll_to(win, lnum)
                    break
                  end
                end
              end
            end
          end, { buffer = true, silent = true, desc = "Smooth scroll to symbol (keep Vista focus)" })
        end,
      })
    end,
  },
}
