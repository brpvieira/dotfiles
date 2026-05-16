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

vim.keymap.set("n", "<leader>ws", function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
end, { desc = 'Trim trailing [w]hite[s]pace'})


-- go to file under cursos with splits in normal mode:
--   - gfh: go to file v-split right
--   - gfj: go to file split down
--   - gfk: go to file split up
--   - gfl: go to file v-split left
--
local function open_file_in_split(direction)
    local file = vim.fn.expand('<cfile>')

    if vim.fn.filereadable(file) == 0 then
        file = vim.fn.expand('%:p:h') .. '/' .. file
    end

    if vim.fn.filereadable(file) == 0 then
        vim.notify('File not found: ' .. file, vim.log.levels.WARN)
        return
    end

    local cur_win = vim.fn.winnr()

    vim.cmd('wincmd ' .. direction)

    if vim.fn.winnr() == cur_win then
        local split_cmd = ({
            h = 'leftabove vsplit',
            l = 'rightbelow vsplit',
            k = 'leftabove split',
            j = 'rightbelow split',
        })[direction]

        vim.cmd(split_cmd .. ' ' .. vim.fn.fnameescape(file))
    else
        vim.cmd('edit ' .. vim.fn.fnameescape(file))
        vim.cmd(vim.fn.winnr('#') .. 'wincmd w')
    end
end

for _, dir in ipairs({ 'h', 'l', 'k', 'j' }) do
    vim.keymap.set('n', 'gf' .. dir, function()
        open_file_in_split(dir)
    end, { silent = true, desc = 'Open file in split to the ' .. ({ h='left', l='right', k='up', j='down' })[dir] })
end
