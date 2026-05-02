local parsers = {
    'bash',
    'c',
    "css",
    'diff',
    "gitignore",
    "go",
    'html',
    "javascript",
    "json",
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'query',
    "typescript",
    "tsx",
    'vim',
    'vimdoc'
}

return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = parsers,
            sync_install = false,
            auto_install = true,
            indent = { enable = true }
        })
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.opt.foldlevelstart = 99
    end,
}
