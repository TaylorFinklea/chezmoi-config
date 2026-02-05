return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position           = "left", -- use a normal vertical split
      width              = 30,
      -- ensure float mode is off
      popup_border_style = "none",
      enable_float       = false,
    },
    filesystem = {
      follow_current_file = true,
      hijack_netrw_behavior = "open_default",
    },
    -- turn off any async watchers that spawn their own UI
    use_libuv_file_watcher = false,
  },
  -- remap your Explorer key to the new toggle
  keys = {
    { "<leader>e", "<cmd>Neotree toggle filesystem<CR>", desc = "פּ File Explorer" },
  },
}
