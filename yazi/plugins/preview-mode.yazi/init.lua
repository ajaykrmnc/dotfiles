-- Preview Mode Plugin for Yazi
-- This creates a modal preview navigation system similar to vim modes

local M = {}

-- State to track if we're in preview mode
local preview_mode_active = false

-- Function to enter preview mode
function M.enter_preview_mode()
    preview_mode_active = true
    ya.notify {
        title = "Preview Mode",
        content = "Entered Preview Mode - Use j/k to navigate, ESC to exit",
        timeout = 2,
        level = "info",
    }
    
    -- Show preview mode indicator
    ya.manager_emit("escape", { visual = true }) -- Clear any visual selection
end

-- Function to exit preview mode
function M.exit_preview_mode()
    preview_mode_active = false
    ya.notify {
        title = "Preview Mode",
        content = "Exited Preview Mode",
        timeout = 1,
        level = "info",
    }
end

-- Function to toggle preview mode
function M.toggle_preview_mode()
    if preview_mode_active then
        M.exit_preview_mode()
    else
        M.enter_preview_mode()
    end
end

-- Function to handle j key in preview mode
function M.preview_down()
    if preview_mode_active then
        ya.manager_emit("seek", { 1 })
    else
        -- Normal j behavior (move cursor down)
        ya.manager_emit("arrow", { 1 })
    end
end

-- Function to handle k key in preview mode
function M.preview_up()
    if preview_mode_active then
        ya.manager_emit("seek", { -1 })
    else
        -- Normal k behavior (move cursor up)
        ya.manager_emit("arrow", { -1 })
    end
end

-- Function to handle escape in preview mode
function M.preview_escape()
    if preview_mode_active then
        M.exit_preview_mode()
    else
        -- Normal escape behavior
        ya.manager_emit("escape", {})
    end
end

return M
