-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

---@type LazyKeys[]
local keys = {
  -- Next Vim tab
  { "<Tab>", "<cmd>tabnext<CR>", mode = "n", desc = "Next Tab" },
  -- Previous Vim tab
  { "<S-Tab>", "<cmd>tabprevious<CR>", mode = "n", desc = "Previous Tab" },
}

return keys
