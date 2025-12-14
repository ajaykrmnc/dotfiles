#!/bin/bash
# Toggle between normal and preview mode for Yazi

YAZI_CONFIG_DIR="$HOME/.config/yazi"
NORMAL_KEYMAP="$YAZI_CONFIG_DIR/keymap.toml"
PREVIEW_KEYMAP="$YAZI_CONFIG_DIR/keymap-preview-mode.toml"
BACKUP_KEYMAP="$YAZI_CONFIG_DIR/keymap.toml.backup"
MODE_FILE="$YAZI_CONFIG_DIR/.preview_mode"

# Create backup of original keymap if it doesn't exist
if [ ! -f "$BACKUP_KEYMAP" ]; then
    cp "$NORMAL_KEYMAP" "$BACKUP_KEYMAP"
fi

# Check current mode
if [ -f "$MODE_FILE" ]; then
    # Currently in preview mode, switch to normal
    cp "$BACKUP_KEYMAP" "$NORMAL_KEYMAP"
    rm "$MODE_FILE"
    echo "🔄 Switched to NORMAL mode (j/k = file navigation)"
    notify-send "Yazi" "Normal Mode: j/k for file navigation" 2>/dev/null || true
else
    # Currently in normal mode, switch to preview
    cp "$PREVIEW_KEYMAP" "$NORMAL_KEYMAP"
    touch "$MODE_FILE"
    echo "🔍 Switched to PREVIEW mode (j/k = preview navigation)"
    notify-send "Yazi" "Preview Mode: j/k for preview navigation" 2>/dev/null || true
fi

# Try to reload yazi configuration (if yazi is running)
pkill -USR1 yazi 2>/dev/null || true
