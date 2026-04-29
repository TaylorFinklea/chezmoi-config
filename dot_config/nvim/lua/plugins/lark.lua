-- lark.nvim was extracted from the larkline monorepo to its own repo in
-- larkline v0.13.0-D. Local dev clone lives at ~/git/lark.nvim. The
-- plugin/lark.lua bundled with the plugin auto-wires <C-l> (Telescope
-- picker, falls back to TUI) and <C-l><C-l> (legacy floating-terminal
-- TUI) — no manual `keys` table needed.
return {
  dir = vim.fn.expand("~/git/lark.nvim"),
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("lark").setup({})
    pcall(require("telescope").load_extension, "lark")
  end,
}
