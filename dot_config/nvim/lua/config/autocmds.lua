-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function ensure_valid_cwd()
  local cwd = vim.uv.cwd()
  if cwd and cwd ~= "" and vim.uv.fs_stat(cwd) then
    return
  end
  local home = vim.env.HOME or "~"
  vim.cmd("cd " .. vim.fn.fnameescape(home))
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = ensure_valid_cwd,
})
