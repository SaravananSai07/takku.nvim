# Takku.nvim

Nvim plugin to quickly access designated files in a project.

## Installation

### [Packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use({
    "SaravananSai07/takku.nvim",
    config = function()
        require("takku.nvim").setup()
    end,
})
```

### [LazyVim](https://github.com/LazyVim/LazyVim)
```lua
{
  "SaravananSai07/takku.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- Optional, if Telescope is preferred for viewing / modifying the lists
  },
  config = function()
    require("takku").setup({
      config = true,
      enable_telescope = true, -- Set to false if you don't want Telescope
      on_attach = function()
        vim.keymap.set("n", "<leader>ta", "<cmd>lua require('takku.nvim').add_file()<CR>")
      end
    })
  end
}
```

## Config
```lua
require("file-navigator").setup({
    mappings = {
        add_file = "<leader>ta",   -- Add current file
        delete_file = "<leader>td",-- Remove current file
        show_list = "<leader>tl",  -- Show file list
        goto_file = "<leader>t",   -- Prefix for <leader>t1-7
    },
    max_files = 7,                -- Max files in list
    enable_telescope_integration = true, -- Auto-detect Telescope
})
```

To force native UI:
```lua
require("takku.nvim").setup({
    enable_telescope_integration = false
})
```
