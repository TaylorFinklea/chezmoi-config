return {
  "nickjvandyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- See https://github.com/nickjvandyke/opencode.nvim/blob/main/lua/opencode/config.lua for all options
    }

    -- Required for automatic buffer reloading
    vim.o.autoread = true

    -- Keymaps
    local map = vim.keymap.set

    -- Ask opencode with context
    map({ "n", "x" }, "<leader>aa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })

    -- Select opencode action
    map({ "n", "x" }, "<leader>as", function()
      require("opencode").select()
    end, { desc = "Select opencode action" })

    -- Toggle opencode terminal
    map({ "n", "t" }, "<leader>at", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    -- Operator to add range
    map({ "n", "x" }, "<leader>ao", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })

    map("n", "<leader>aoo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })
  end,
}
