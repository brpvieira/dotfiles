return {
	"folke/todo-comments.nvim",
	event = "VimEnter",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local opts = { signs = true }
		require("todo-comments").setup(opts)
		vim.keymap.set("n", "]t", function()
			require("todo-comments").jump_next()
		end, { desc = "Next todo comment" })

		vim.keymap.set("n", "[t", function()
			require("todo-comments").jump_prev()
		end, { desc = "Previous todo comment" })

		vim.keymap.set("n", "<leader>tt", function()
            require("trouble").toggle("todo")
		end, { desc = "[T]odos (Trouble)" })
	end,
}
