-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
--
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
local default_severity = { severity = { min = vim.diagnostic.severity.WARN } }
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	-- Can switch between these as you prefer
	virtual_text = false, -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
	jump = { float = true },

	signs = {
		enable = true,
		text = {
			["ERROR"] = signs.Error,
			["WARN"] = signs.Warn,
			["HINT"] = signs.Hint,
			["INFO"] = signs.Info,
		},
		texthl = {
			["ERROR"] = "DiagnosticDefault",
			["WARN"] = "DiagnosticDefault",
			["HINT"] = "DiagnosticDefault",
			["INFO"] = "DiagnosticDefault",
		},
		numhl = {
			["ERROR"] = "DiagnosticDefault",
			["WARN"] = "DiagnosticDefault",
			["HINT"] = "DiagnosticDefault",
			["INFO"] = "DiagnosticDefault",
		},
		severity_sort = true,
	},
})

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>td", function()
	if vim.diagnostic.is_enabled() then
		vim.diagnostic.enable(false)
	else
		vim.diagnostic.enable(true)
	end
end, { desc = "[T]ogle all [d]iagnostics" })

vim.keymap.set('n', '<leader>vt', function()
  local current_value = vim.diagnostic.config().virtual_text
  if current_value then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = default_severity })
  end
end, { desc = "Toggle diagnostic [v]irtual_[t]ext" })

vim.keymap.set('n', '<leader>vl', function()
  local current_value = vim.diagnostic.config().virtual_lines
  if current_value then
    vim.diagnostic.config({ virtual_lines = false })
  else
    vim.diagnostic.config({ virtual_lines = default_severity })
  end
end, { desc = "Toggle diagnostic [v]irtual_[l]ines" })
