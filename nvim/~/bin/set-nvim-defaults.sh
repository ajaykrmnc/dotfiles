#!/bin/bash

# Script to set nvim as the default application for various file types on macOS

echo "Setting nvim as default application for code files..."

# Common code file extensions
extensions=(
    "txt" "md" "markdown" "py" "js" "ts" "jsx" "tsx" "html" "css" "scss" "sass"
    "json" "xml" "yaml" "yml" "toml" "ini" "cfg" "conf" "config"
    "sh" "bash" "zsh" "fish" "ps1" "bat" "cmd"
    "c" "cpp" "cc" "cxx" "h" "hpp" "hxx"
    "java" "kt" "scala" "groovy"
    "go" "rs" "swift" "m" "mm"
    "php" "rb" "pl" "pm" "lua" "r" "R"
    "sql" "sqlite" "db"
    "log" "out" "err"
    "gitignore" "gitattributes" "gitmodules"
    "dockerfile" "dockerignore"
    "makefile" "cmake" "gradle"
    "vim" "vimrc" "nvim"
)

# Path to nvim-gui wrapper
NVIM_GUI_PATH="/Users/ajay.kumar/bin/nvim-gui"

if [ ! -f "$NVIM_GUI_PATH" ]; then
    echo "Error: nvim-gui wrapper not found at $NVIM_GUI_PATH"
    exit 1
fi

# Set default application for each extension
for ext in "${extensions[@]}"; do
    echo "Setting default for .$ext files..."
    duti -s com.apple.Terminal "$ext" all 2>/dev/null || true
done

echo "File associations updated!"
echo ""
echo "Note: Some file associations may require logging out and back in to take full effect."
echo "You can also manually set associations by:"
echo "1. Right-clicking a file in Finder"
echo "2. Selecting 'Get Info'"
echo "3. Changing 'Open with' to Terminal"
echo "4. Clicking 'Change All...'"
