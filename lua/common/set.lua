vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true -- Highlight search hits
vim.opt.incsearch = true -- Incremental search
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true  -- Smart case sensitivity

vim.opt.termguicolors = true

vim.opt.scrolloff = 8 -- scroll context lines
vim.opt.signcolumn = "yes" -- always reserve column for LSP signs
vim.opt.isfname:append("@-@") -- fixes gf for files with "@" in filename

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"


vim.opt.splitright = true   -- Open new vertical splits to the right
vim.opt.splitbelow = true   -- Open new horizontal splits below
