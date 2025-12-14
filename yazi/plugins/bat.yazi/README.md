# Bat Plugin for Yazi - Fixed Version

This is a fixed version of the bat plugin that properly supports seek functionality in yazi preview mode.

## What was fixed

The original bat plugin had an issue where the seek function (scrolling in preview) didn't work because:

1. **Original Issue**: The `peek` function loaded the entire file content at once using `child:wait_with_output()` and displayed it all, ignoring the `job.skip` parameter that controls scrolling position.

2. **The Fix**: Changed the `peek` function to:
   - Read the bat output line by line using `child:read_line()`
   - Respect the `job.skip` parameter to only show lines after the skip count
   - Limit output to `job.area.h` lines (the height of the preview area)
   - Handle edge cases when scrolling near the end of files

## How it works now

- **j/k, J/K**: Scroll up/down in preview
- **d/u**: Larger scroll increments  
- **Ctrl+d/Ctrl+u**: Half-page scrolling
- **g/G**: Go to top/bottom of file
- **All other configured seek keybindings work properly**

## Technical Details

The key changes in `main.lua`:

```lua
-- Before: Load entire file at once
local output, err = child:wait_with_output()
local lines = output.stdout

-- After: Read line by line with skip support
local limit = job.area.h
local i, lines = 0, ""
repeat
    local next, event = child:read_line()
    -- ... error handling ...
    i = i + 1
    if i > job.skip then
        lines = lines .. next
    end
until i >= job.skip + limit
```

This matches the pattern used by other working plugins like glow.yazi.

## Testing

Use the provided `test_seek.py` file to test scrolling functionality:

```bash
./test_yazi_seek.sh
```

Navigate to any `.py`, `.txt`, or other text file and try the seek keybindings.
