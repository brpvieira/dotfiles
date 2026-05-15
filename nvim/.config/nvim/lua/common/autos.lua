-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

local augroup = vim.api.nvim_create_augroup
local group = augroup("BootstrapGroup", { clear = true })
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	desc = "Clear trailling whitespace on write",
	group = group,
	pattern = "*",
	callback = function()
		MiniTrailspace.trim()
		MiniTrailspace.trim_last_lines()
	end
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	desc = "Set html syntax for ejs files",
	pattern = "*.ejs",
	command = "set filetype=html",
	group = group,
})
