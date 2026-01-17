# Moving ~/garage to /garage: Permission Issues & Requirements

## Overview
When moving a repository from `~/garage` (user home directory) to `/garage` (root-level directory), you'll encounter significant permission and ownership changes that require careful handling.

---

## Why Permission Changes Are Necessary

### 1. **Ownership Differences**

**Current Location: `~/garage`**
- Owner: `ajay.kumar` (your user)
- Group: `staff` (typical macOS user group)
- Default permissions: User has full control (read/write/execute)

**New Location: `/garage`**
- Owner: Likely `root` initially (system-level directory)
- Requires explicit permission setup
- System directories have stricter default permissions

### 2. **Access Control Requirements**

Moving to `/garage` means:
- The directory is outside your home directory
- macOS system protections (SIP - System Integrity Protection) may apply
- Other users/processes may need different access levels
- Build tools, IDEs, and scripts need proper execute permissions

---

## Permission Issues You'll Encounter

### Issue 1: **Directory Creation Requires Root**
```bash
# This will fail without sudo
mkdir /garage
# Error: Permission denied

# Requires root privileges
sudo mkdir /garage
```

### Issue 2: **File Ownership**
After moving files, they may be owned by `root`:
```bash
ls -la /garage
# drwxr-xr-x  root  wheel  ...  /garage
```

**Problem**: Your user can't modify files owned by root.

### Issue 3: **Execute Permissions on Scripts**
Scripts and binaries need execute permissions:
```bash
# Build scripts
/garage/workspace/ap/build/scripts/*.sh

# Toolchain binaries
/garage/workspace/ap/build/export/toolchain-*/bin/*
/garage/workspace/ap/build/export/arm-gnu-toolchain-*/bin/*

# Git hooks
/garage/.git/hooks/*
```

**Without execute permissions**:
- Build scripts won't run
- Toolchain compilers won't execute
- Git hooks will fail
- Development tools will break

### Issue 4: **Directory Traversal**
Directories need execute permission to be traversed:
```bash
# Without execute on /garage
cd /garage/workspace
# Error: Permission denied
```

---

## Required chmod Commands

### 1. **Set Ownership to Your User**
```bash
# Change owner from root to your user
sudo chown -R ajay.kumar:staff /garage
```

**Why**: Allows you to read, write, and modify files without sudo.

### 2. **Set Directory Permissions**
```bash
# Give directories read, write, execute for owner
sudo chmod -R u+rwX /garage
```

**Explanation**:
- `u+rwX`: User gets read, write, and execute (capital X = only on directories)
- `-R`: Recursive (applies to all subdirectories)

### 3. **Set Execute Permissions on Scripts**
```bash
# Make all .sh scripts executable
find /garage -type f -name "*.sh" -exec chmod +x {} \;

# Make toolchain binaries executable
chmod -R +x /garage/workspace/ap/build/export/toolchain-*/bin/*
chmod -R +x /garage/workspace/ap/build/export/arm-gnu-toolchain-*/bin/*
```

**Why**: Scripts and binaries must have execute bit set to run.

### 4. **Set Git Hooks Permissions**
```bash
# Git hooks need execute permissions
chmod +x /garage/.git/hooks/*
```

---

## Why `chmod -R +x` Is Necessary

### The Execute Permission Explained

**For Files**:
- `+x` = Can be executed as a program/script
- Required for: shell scripts, binaries, compiled programs

**For Directories**:
- `+x` = Can be traversed (cd into it)
- Required to access files inside the directory

### Why Recursive (`-R`) Is Needed

Your garage repository has nested structure:
```
/garage/
├── workspace/
│   └── ap/
│       ├── build/
│       │   ├── scripts/          # Scripts need +x
│       │   └── export/
│       │       ├── toolchain-*/
│       │       │   └── bin/*     # Binaries need +x
│       │       └── arm-gnu-toolchain-*/
│       │           └── bin/*     # Binaries need +x
│       └── src/                  # Directories need +x to traverse
└── .git/
    └── hooks/*                   # Git hooks need +x
```

**Without recursive**: You'd have to manually chmod each directory and file.

---

## Recommended Permission Setup

### Complete Setup Script
```bash
#!/bin/bash
# Run this after moving ~/garage to /garage

echo "Setting up permissions for /garage..."

# 1. Take ownership
echo "Step 1: Setting ownership..."
sudo chown -R ajay.kumar:staff /garage

# 2. Set base permissions (directories executable, files readable/writable)
echo "Step 2: Setting base permissions..."
sudo chmod -R u+rwX,go+rX /garage

# 3. Make scripts executable
echo "Step 3: Making scripts executable..."
find /garage -type f -name "*.sh" -exec chmod +x {} \;

# 4. Make toolchain binaries executable
echo "Step 4: Making toolchain binaries executable..."
if [ -d "/garage/workspace/ap/build/export" ]; then
    find /garage/workspace/ap/build/export -type f -path "*/bin/*" -exec chmod +x {} \;
fi

# 5. Make git hooks executable
echo "Step 5: Making git hooks executable..."
if [ -d "/garage/.git/hooks" ]; then
    chmod +x /garage/.git/hooks/* 2>/dev/null || true
fi

echo "✓ Permissions setup complete!"
```

---

## Security Considerations

### 1. **Avoid chmod 777**
```bash
# ❌ NEVER DO THIS
chmod -R 777 /garage
```
**Why**: Gives everyone (all users) full permissions - major security risk.

### 2. **Use Minimal Permissions**
```bash
# ✓ BETTER: Only owner has write access
chmod -R u+rwX,go+rX /garage
```
- Owner: read, write, execute
- Group/Others: read, execute only

### 3. **Protect Sensitive Files**
```bash
# SSH keys, credentials should be restricted
chmod 600 /garage/.ssh/id_rsa
chmod 600 /garage/.env
```

---

## Verification Commands

After setting permissions, verify:

```bash
# Check ownership
ls -la /garage
# Should show: ajay.kumar staff

# Check directory permissions
ls -ld /garage/workspace/ap
# Should show: drwxr-xr-x (755)

# Check script permissions
ls -l /garage/workspace/ap/build/scripts/*.sh
# Should show: -rwxr-xr-x (755)

# Test execution
/garage/workspace/ap/build/scripts/build.sh --help
# Should run without "Permission denied"
```

---

## Summary

**Why chmod -R +x is necessary**:
1. **Directories**: Need execute to traverse (cd into them)
2. **Scripts**: Need execute to run (.sh files, build scripts)
3. **Binaries**: Need execute to run (compilers, toolchain)
4. **Git hooks**: Need execute to trigger on git operations

**The -R flag**: Applies changes recursively to all nested files/directories.

**Without proper permissions**: Your development environment will break - builds will fail, tools won't run, and you'll get "Permission denied" errors constantly.

