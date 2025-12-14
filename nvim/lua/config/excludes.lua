local M = {}

M.exclude_patterns = {
  ".angular",
  "**/.git",
  "**/.DS_Store",
  "**/.hg",
  "**/dist",
  "node_modules",
  "coverage",
  "angular-i18n",
  "migration",
}

return M