-- lua/plugins/header.lua
return {
  {
    "alpertuna/vim-header",
    config = function()
      vim.g.header_auto_add_header = 1
      vim.g.header_field_author = "Arista Networks, Inc."
      vim.g.header_field_timestamp_format = "%Y-%m-%d"
      vim.g.header_template = {
        "Copyright (c) <year> Arista Networks, Inc. All rights reserved.",
        "Arista Networks, Inc. Confidential and Proprietary.",
      }
    end,
  },
}
