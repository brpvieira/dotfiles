local parsers = {
    "lua",
    "vim",
    "vimdoc",
    "query",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "css",
    "json",
    "gitignore",
    "go",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master", -- Explicitly use the legacy branch
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = parsers,
                highlight = { enable = true },
            })
        end
    },
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		lazy = false,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
					},
				},
			})
		end,
	},
}
