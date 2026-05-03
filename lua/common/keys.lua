-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search '})


-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })


-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = '[p]aste over selection, preserve register' })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = '[y]ank into system clipboard'})
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank into system clipboard'})

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = '[d]elete, preserve register'})
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = 'Make file e[x]ecutable' })
vim.keymap.set("n", "J", "mzJ`z", { desc = 'Append next line into current'})

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Jump 1/2 page [d]own'})
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Jump 1/2 page [u]p'})
vim.keymap.set("n", "n", "nzzzv", { desc = '[n]ext search hit'})
vim.keymap.set("n", "N", "Nzzzv", { desc = '[N]ext search hit'})
