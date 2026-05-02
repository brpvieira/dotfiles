require("common/bootstrap")
require("common/globals")
require("common/set")
require("common/diagnostics")
require("common/keys")
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
-- TODO: move to common/autocmds.lua
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
require("common/lazy")
