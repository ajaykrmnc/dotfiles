# clangd and LSP Symlink Resolution Guide

## Table of Contents
1. [The Problem](#the-problem)
2. [Why This Happens](#why-this-happens)
3. [Real-World Impact](#real-world-impact)
4. [Solutions and Workarounds](#solutions-and-workarounds)
5. [Testing Your Setup](#testing-your-setup)
6. [Other Language Servers](#other-language-servers)
7. [Best Practices](#best-practices)

---

## The Problem

### TL;DR
**clangd and many LSP servers have known issues with symlinks.** When you use synthetic.conf to create `/garage → ~/garage`, clangd may:
- ❌ Fail to find `compile_commands.json`
- ❌ Not index files correctly
- ❌ Show false errors/warnings
- ❌ Break "Go to Definition" functionality
- ❌ Fail to provide code completion

### The Core Issue

When you create a symlink via synthetic.conf:
```bash
# synthetic.conf creates:
/garage → /Users/ajay/garage

# Your project structure:
/garage/workspace/ap/
  ├── src/
  │   └── main.cpp
  └── compile_commands.json
```

**What happens:**
1. You open `/garage/workspace/ap/src/main.cpp` in your editor
2. clangd receives the path: `/garage/workspace/ap/src/main.cpp`
3. clangd resolves symlinks internally: `/Users/ajay/garage/workspace/ap/src/main.cpp`
4. clangd looks for `compile_commands.json` using the **resolved** path
5. But `compile_commands.json` contains entries with the **symlink** path
6. **Path mismatch** → clangd can't find compilation database → no IntelliSense

### Documented Issues

**GitHub Issues:**
- [clangd/clangd#413](https://github.com/clangd/clangd/issues/413) - "Editing symlinked files does not use compile_commands.json"
- [clangd/clangd#503](https://github.com/clangd/clangd/issues/503) - "Indexing issues when root dir is symlinked"
- [clangd/clangd#544](https://github.com/clangd/clangd/issues/544) - "Goto definition performs symlink resolution"

**Status:** Open since 2020, still not fully resolved as of 2024.

---

## Why This Happens

### clangd's Path Resolution Logic

```cpp
// Simplified from clangd source code
DirectoryBasedGlobalCompilationDatabase::getCompileCommand(PathRef File) const {
  CDBLookupRequest Req;
  Req.FileName = File;  // This is the symlink path
  
  auto Res = lookupCDB(Req);
  if (!Res) {
    log("Failed to find compilation database for {0}", File);
    return llvm::None;  // ← Fails here!
  }
  
  auto Candidates = Res->CDB->getCompileCommands(File);
  return Candidates.front();
}
```

**The problem:**
- `lookupCDB` searches for `compile_commands.json` in parent directories
- It uses the **resolved** path (after following symlinks)
- But `compile_commands.json` entries use the **symlink** path
- Result: No match found

### Path Inconsistency Example

```
Editor opens:     /garage/workspace/ap/src/main.cpp
clangd resolves:  /Users/ajay/garage/workspace/ap/src/main.cpp
clangd searches:  /Users/ajay/garage/workspace/ap/compile_commands.json ✓ (found)

compile_commands.json contains:
{
  "directory": "/garage/workspace/ap",
  "file": "/garage/workspace/ap/src/main.cpp",  ← Symlink path
  "command": "clang++ -c src/main.cpp"
}

clangd tries to match:
  /Users/ajay/garage/workspace/ap/src/main.cpp  ← Resolved path
  ≠
  /garage/workspace/ap/src/main.cpp  ← Entry in compile_commands.json

Result: NO MATCH → No IntelliSense
```

---

## Real-World Impact

### What Works ✅
- Basic syntax highlighting (editor-level, not LSP)
- File opening and editing
- Git operations
- Build systems (make, cmake, bazel)
- Docker volume mounts

### What Breaks ❌

**1. Code Completion**
```cpp
#include <vector>

int main() {
    std::vector<int> v;
    v.  // ← No autocomplete suggestions!
}
```

**2. Go to Definition**
```cpp
void myFunction();  // Defined in another file

int main() {
    myFunction();  // ← Cmd+Click does nothing or goes to wrong file
}
```

**3. Error Detection**
```cpp
#include "my_header.h"  // ← Shows "file not found" even though it exists
```

**4. Refactoring**
- Rename symbol: Doesn't find all references
- Extract function: Fails
- Find all references: Incomplete results

**5. Background Indexing**
```
clangd logs:
I[13:08:39.059] Enqueueing 0 commands for indexing
                            ^ Should be > 0!
```

---

## Solutions and Workarounds

### Solution 1: Force compile-commands-dir (Recommended)

**For VSCode:**

Edit `.vscode/settings.json`:
```json
{
  "clangd.arguments": [
    "--compile-commands-dir=${workspaceFolder}",
    "--query-driver=/usr/bin/clang++",
    "--background-index"
  ]
}
```

**For Neovim (with nvim-lspconfig):**
```lua
require('lspconfig').clangd.setup{
  cmd = {
    "clangd",
    "--compile-commands-dir=" .. vim.fn.getcwd(),
    "--background-index"
  }
}
```

**For Emacs (with lsp-mode):**
```elisp
(setq lsp-clients-clangd-args 
  '("--compile-commands-dir=." 
    "--background-index"))
```

**Why this works:**
- Forces clangd to use the workspace root's `compile_commands.json`
- Bypasses the automatic directory traversal that fails with symlinks
- Works regardless of which file you open

**Limitations:**
- Only works if `compile_commands.json` is at workspace root
- Doesn't help if you have multiple compilation databases

---

### Solution 2: Use Resolved Paths Everywhere

**Strategy:** Work with the resolved path instead of the symlink path.

**Open your project using the real path:**
```bash
# Instead of:
cd /garage/workspace/ap
code .

# Do this:
cd ~/garage/workspace/ap
code .

# Or:
code /Users/ajay/garage/workspace/ap
```

**Pros:**
- ✅ clangd works perfectly
- ✅ No configuration needed
- ✅ All LSP features work

**Cons:**
- ❌ Defeats the purpose of having `/garage`
- ❌ Docker containers still expect `/garage`
- ❌ Scripts/configs that hardcode `/garage` will break

---

### Solution 3: Symlink compile_commands.json

**Create symlinks in both locations:**
```bash
# Your real compile_commands.json:
~/garage/workspace/ap/compile_commands.json

# Create symlink at resolved path:
ln -s ~/garage/workspace/ap/compile_commands.json \
      /Users/ajay/garage/workspace/ap/compile_commands.json

# Or vice versa if needed
```

**Why this helps:**
- clangd can find the compilation database from either path
- Minimal configuration changes

**Limitations:**
- Doesn't solve all path mismatch issues
- Still may have indexing problems

---

### Solution 4: Modify compile_commands.json to Use Resolved Paths

**Use a script to rewrite paths:**

```python
#!/usr/bin/env python3
import json
import os
from pathlib import Path

def resolve_symlinks(compile_commands_path):
    with open(compile_commands_path, 'r') as f:
        commands = json.load(f)

    for cmd in commands:
        # Resolve symlinks in all paths
        if 'file' in cmd:
            cmd['file'] = str(Path(cmd['file']).resolve())
        if 'directory' in cmd:
            cmd['directory'] = str(Path(cmd['directory']).resolve())
        if 'command' in cmd:
            # Replace /garage with resolved path in command string
            cmd['command'] = cmd['command'].replace(
                '/garage',
                str(Path('/garage').resolve())
            )

    # Write back
    with open(compile_commands_path, 'w') as f:
        json.dump(commands, f, indent=2)

if __name__ == '__main__':
    resolve_symlinks('compile_commands.json')
```

**Usage:**
```bash
# After generating compile_commands.json:
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
python3 resolve_symlinks.py

# Or add to your build script:
make && python3 resolve_symlinks.py
```

**Pros:**
- ✅ Works with any editor/LSP
- ✅ No editor configuration needed

**Cons:**
- ❌ Must run after every build system regeneration
- ❌ Breaks if you share the project (paths are absolute)

---

### Solution 5: Use .clangd Configuration File

Create `.clangd` in your project root:

```yaml
# .clangd
CompileFlags:
  CompilationDatabase: .

Index:
  Background: Build

Diagnostics:
  UnusedIncludes: Strict
  MissingIncludes: Strict

# Force clangd to use workspace root
# This helps with symlink resolution
```

**Additional option - Add path mappings:**
```yaml
# .clangd (experimental)
PathMappings:
  /garage: /Users/ajay/garage
```

**Note:** Path mappings are not officially supported in all clangd versions.

---

### Solution 6: Patch clangd (Advanced)

**For developers willing to build clangd from source:**

The clangd team has proposed patches (see issues #413, #503) that resolve symlinks consistently. You can:

1. Clone llvm-project
2. Apply symlink resolution patches
3. Build custom clangd
4. Use your patched version

**Patches needed:**
- `JSONCompilationDatabase.cpp` - Resolve symlinks when loading compile_commands.json
- `IndexAction.cpp` - Resolve symlinks when indexing files

**Example patch (from issue #503):**
```cpp
// In JSONCompilationDatabase::getCompileCommands
SmallString<128> NativeFilePath;
std::error_code EC = llvm::sys::fs::real_path(FilePath, NativeFilePath, true);
if (EC) {
  // Fallback to original behavior
  llvm::sys::path::native(FilePath, NativeFilePath);
}
```

**Pros:**
- ✅ Fixes the root cause
- ✅ Works transparently

**Cons:**
- ❌ Requires building from source
- ❌ Must maintain custom build
- ❌ Patches may not be merged upstream

---

## Testing Your Setup

### Test 1: Check if clangd Finds compile_commands.json

```bash
# Open a file and check clangd logs
# VSCode: Cmd+Shift+P → "clangd: Open log"

# Look for:
I[timestamp] Loaded compilation database from /path/to/your/project
I[timestamp] Enqueueing N commands for indexing  # N should be > 0
```

**If you see:**
```
I[timestamp] Enqueueing 0 commands for indexing
```
→ clangd is NOT finding your files!

### Test 2: Verify Path Resolution

```bash
# In your project directory:
pwd
# Output: /garage/workspace/ap

realpath .
# Output: /Users/ajay/garage/workspace/ap

# Check what clangd sees:
# Open a .cpp file and look at clangd logs:
I[timestamp] Working directory: /Users/ajay/garage/workspace/ap
#                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                                 This is the RESOLVED path
```

### Test 3: Code Completion Test

Create a test file:
```cpp
// test.cpp
#include <vector>
#include <string>

int main() {
    std::vector<int> v;
    v.  // ← Type dot and wait for autocomplete

    std::string s;
    s.  // ← Should show string methods

    return 0;
}
```

**Expected:** Autocomplete shows methods like `push_back`, `size`, `clear`, etc.
**If broken:** No suggestions or only basic syntax suggestions.

### Test 4: Go to Definition Test

```cpp
// header.h
void myFunction();

// main.cpp
#include "header.h"

int main() {
    myFunction();  // ← Cmd+Click here
}
```

**Expected:** Jumps to `header.h`
**If broken:** Nothing happens or "Definition not found"

### Test 5: Check Indexing Status

```bash
# VSCode: Look at status bar
# Should show: "clangd: idle" or "clangd: indexing (N files)"

# If it shows "clangd: idle" immediately after opening:
# → Indexing didn't start (symlink issue!)
```

---

## Other Language Servers

### The Good News

Not all language servers have symlink issues!

### Language Servers That Handle Symlinks Well ✅

**1. rust-analyzer (Rust)**
```bash
# Works fine with symlinks
/garage/rust-project → ~/garage/rust-project
# rust-analyzer resolves paths correctly
```

**2. pyright / pylsp (Python)**
```bash
# Python LSPs generally handle symlinks well
# They follow Python's import resolution which respects symlinks
```

**3. typescript-language-server (TypeScript/JavaScript)**
```bash
# Works with symlinks
# Uses Node.js path resolution which handles symlinks
```

**4. gopls (Go)**
```bash
# Generally works with symlinks
# Go modules handle symlinks reasonably well
```

### Language Servers With Symlink Issues ❌

**1. clangd (C/C++)**
- **Status:** Known issues (documented above)
- **Severity:** High - breaks most features
- **Workaround:** Use `--compile-commands-dir`

**2. jdtls (Java)**
- **Status:** Some issues with symlinked source roots
- **Severity:** Medium
- **Workaround:** Use absolute paths in `.classpath`

**3. omnisharp (C#)**
- **Status:** Issues with symlinked project files
- **Severity:** Medium
- **Workaround:** Use real paths in `.csproj`

### Testing Other LSPs

```bash
# Generic test for any LSP:
# 1. Create symlink
ln -s ~/real/path /symlink/path

# 2. Open project via symlink
cd /symlink/path
code .

# 3. Test features:
#    - Autocomplete
#    - Go to definition
#    - Find references
#    - Rename symbol
#    - Show diagnostics

# 4. Check LSP logs for path-related errors
```

---

## Best Practices

### 1. Choose Your Path Strategy Early

**Option A: Use Symlinks Everywhere**
```bash
# Commit to /garage in all configs
# Docker: /garage
# Scripts: /garage
# IDE: Open via /garage
# Requires: LSP workarounds
```

**Option B: Use Real Paths Everywhere**
```bash
# Use ~/garage in all configs
# Docker: Map ~/garage to /garage in container
# Scripts: Use ~/garage
# IDE: Open via ~/garage
# Requires: No LSP workarounds needed
```

**Option C: Hybrid (Recommended)**
```bash
# Development: Use ~/garage (real path)
# Docker: Use /garage (symlink)
# Benefit: LSP works, Docker still gets /garage
```

### 2. Document Your Setup

Create a `DEVELOPMENT.md`:
```markdown
# Development Setup

## Paths
- Real path: `/Users/ajay/garage/workspace/ap`
- Symlink: `/garage/workspace/ap`
- Docker expects: `/garage/workspace/ap`

## IDE Setup
- Open project using: `~/garage/workspace/ap` (real path)
- clangd will work correctly
- Docker volumes: Use `/garage` in docker-compose.yml

## Building
```bash
cd ~/garage/workspace/ap
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .
```
```

### 3. Use Relative Paths in compile_commands.json

**When possible, use relative paths:**
```json
{
  "directory": ".",
  "file": "src/main.cpp",
  "command": "clang++ -c src/main.cpp"
}
```

**Instead of absolute:**
```json
{
  "directory": "/garage/workspace/ap",
  "file": "/garage/workspace/ap/src/main.cpp",
  "command": "clang++ -c /garage/workspace/ap/src/main.cpp"
}
```

**How to generate relative paths:**

**CMake:**
```cmake
# CMakeLists.txt
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Use relative paths
set(CMAKE_CXX_COMPILER_LAUNCHER "")
```

**Bear (for Makefiles):**
```bash
# Use --append and relative paths
bear --append -- make
```

**compiledb (for Makefiles):**
```bash
compiledb --no-build make
# Then post-process to make paths relative
```

### 4. Automate Path Resolution

**Add to your build script:**
```bash
#!/bin/bash
# build.sh

# Build project
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build

# Copy compile_commands.json to root
cp build/compile_commands.json .

# Optional: Resolve symlinks if needed
if [ -f resolve_symlinks.py ]; then
    python3 resolve_symlinks.py
fi

echo "Build complete. clangd should work now."
```

### 5. Test in CI/CD

**Ensure your setup works in different environments:**
```yaml
# .github/workflows/test.yml
name: Test Build

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2

      - name: Test with real path
        run: |
          cd ${{ github.workspace }}
          cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
          test -f build/compile_commands.json

      - name: Test with symlink
        run: |
          ln -s ${{ github.workspace }} /tmp/symlink-test
          cd /tmp/symlink-test
          cmake -B build2 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
          test -f build2/compile_commands.json
```

### 6. Use .clangd for Project-Specific Config

**Commit `.clangd` to your repo:**
```yaml
# .clangd
CompileFlags:
  CompilationDatabase: .
  Add:
    - "-std=c++17"
    - "-Wall"
    - "-Wextra"

Index:
  Background: Build

Diagnostics:
  ClangTidy:
    Add:
      - modernize-*
      - performance-*
    Remove:
      - modernize-use-trailing-return-type
```

**Benefits:**
- Team members get same clangd config
- Works regardless of symlink setup
- Version controlled

### 7. Monitor clangd Performance

**Check if symlinks cause performance issues:**
```bash
# Enable verbose logging
# .vscode/settings.json
{
  "clangd.arguments": [
    "--log=verbose",
    "--compile-commands-dir=${workspaceFolder}"
  ]
}

# Watch for:
# - Repeated "Failed to find compilation database" messages
# - Slow indexing
# - High CPU usage
```

---

## Summary

### The Reality Check

**Symlinks + clangd = Pain** 😞

But it's manageable with the right approach!

### Quick Decision Tree

```
Do you NEED /garage for Docker?
├─ YES
│  ├─ Can you open IDE with ~/garage?
│  │  ├─ YES → Use Solution 2 (Real paths in IDE) ✅ EASIEST
│  │  └─ NO → Use Solution 1 (--compile-commands-dir) ✅ WORKS
│  └─ Must use /garage everywhere?
│     └─ Use Solution 4 (Rewrite compile_commands.json) ⚠️ COMPLEX
└─ NO
   └─ Don't use synthetic.conf! Use ~/garage everywhere ✅ BEST
```

### Recommended Setup

**For most users:**
1. ✅ Use synthetic.conf to create `/garage` for Docker
2. ✅ Open your IDE using `~/garage/workspace/ap` (real path)
3. ✅ Add `--compile-commands-dir=${workspaceFolder}` to clangd args
4. ✅ Docker volumes use `/garage/workspace/ap`

**Result:**
- clangd works perfectly ✅
- Docker gets the paths it expects ✅
- Minimal configuration ✅
- No custom scripts needed ✅

### Final Thoughts

The symlink issue with clangd is a known limitation that has existed since 2020. While frustrating, it's not a dealbreaker. With the workarounds above, you can have both:
- A working development environment with full LSP features
- Docker containers that use the paths they expect

The key is understanding the trade-offs and choosing the solution that fits your workflow.

---

**Document Version:** 1.0
**Last Updated:** 2026-01-14
**Tested With:** clangd 12.0.0 - 18.0.0
**macOS Versions:** Catalina (10.15) - Sonoma (14.x)


