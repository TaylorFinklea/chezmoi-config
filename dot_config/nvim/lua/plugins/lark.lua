return {
  dir = vim.fn.expand("~/git/larkline/lark.nvim"),
  config = true,
  keys = {
    { "<C-l>", function() require("lark").toggle() end, desc = "Toggle Lark" },
  },
}
