#!/bin/bash
# Test script for LazyVim LSP configuration

echo "=== LazyVim LSP Configuration Test ==="
echo ""

# Check if the new config file exists
if [ -f ~/.config/nvim/lua/plugins/lspconfig-lazyvim.lua ]; then
    echo "✅ New LazyVim config file exists: lspconfig-lazyvim.lua"
else
    echo "❌ New LazyVim config file NOT found!"
    exit 1
fi

# Check if old config is disabled
if [ -f ~/.config/nvim/lua/plugins/lspconfig.lua ]; then
    echo "⚠️  WARNING: Old lspconfig.lua is still active!"
    echo "   This will conflict with the new configuration"
    echo "   Please rename it to lspconfig.lua.disabled"
else
    echo "✅ Old lspconfig.lua is disabled"
fi

# Check if LazyVim is installed
if [ -d ~/.local/share/nvim/lazy/LazyVim ]; then
    echo "✅ LazyVim is installed"
else
    echo "⚠️  LazyVim directory not found"
fi

echo ""
echo "=== Next Steps ==="
echo "1. Restart Neovim: pkill nvim && nvim ~/garage/workspace/ap/src/ar_pkt_trace/ar_pkt_trace.c"
echo "2. In Neovim, run: :LspInfo"
echo "3. In Neovim, run: :luafile ~/.config/nvim/check_clangd_config.lua"
echo "4. Check that Command shows all custom flags including --query-driver"
echo ""

