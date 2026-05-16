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


local function toggle_wrap(toggle)
	vim.wo.wrap = toggle
	vim.wo.colorcolumn = toggle and "" or vim.g.colorcolumn
end

vim.api.nvim_create_autocmd("ModeChanged", {
	desc = "Wrap lines when rendering markdown",
	group = group,
	pattern = "*",
	callback = function()
		if vim.bo.filetype ~= "markdown" then
			return
		end
		local mode = vim.api.nvim_get_mode().mode
		-- Check if we are entering Normal (n) or Command (c) mode
		if mode == "n" or mode == "c" or mode == "t" then
			toggle_wrap(true)
		else
			toggle_wrap(false)
		end
	end,
})

-- Ensure it's set correctly when first entering a markdown buffer
vim.api.nvim_create_autocmd("FileType", {
	desc = "Wrap lines when rendering markdown",
	group = group,
	pattern = "markdown",
	callback = function()
		toggle_wrap(true)
	end,
})
