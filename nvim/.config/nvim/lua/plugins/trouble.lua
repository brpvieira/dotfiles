return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    {
      "<leader>tx",
      desc = "Buffer Diagnostics (Trouble)",
      function ()
        require("trouble").toggle({
          mode = "diagnostics",
          filter = {
            buf = 0
          }
        })
      end,
    },
    {
      "<leader>tX",
      desc = "Global Diagnostics (Trouble)",
      function ()
        require("trouble").toggle("diagnostics")
      end,
    },
    {
      "<leader>ts",
      desc = "Buffer Symbols (Trouble)",
      function ()
        require("trouble").toggle({
          mode = "symbols",
          filter = { buf = 0 },
          focus = false,
          win = { position = 'right' }
        })
      end,
    },
    -- {
    --   "<leader>tS",
    --   desc = "Global Symbols (Trouble)",
    --   function ()
    --     require("trouble").toggle({
    --       mode = "symbols",
    --       focus = false,
    --       win = { position = 'right' }
    --     })
    --   end,
    -- },
    {
      "<leader>tl",
      desc = "LSP Definitions / references / ... (Trouble)",
      function ()
        require("trouble").toggle({
          mode = "lsp",
          focus = false,
          win = { position = 'right' }
        })
      end,
    },
    {
      "<leader>tL",
      desc = "Location List (Trouble)",
      function ()
        require("trouble").toggle("loclist")
      end,
    },
    {
      "<leader>tQ",
      desc = "Quickfix List (Trouble)",
      function ()
        require("trouble").toggle("qflist")
      end,
    },

    gb = { -- example of a custom action that toggles the active view filter
      action = function(view)
        view:filter({ buf = 0 }, { toggle = true })
      end,
      desc = "Toggle Current Buffer Filter",
    },

    s = { -- example of a custom action that toggles the severity
      action = function(view)
        local f = view:get_filter("severity")
        local severity = ((f and f.filter.severity or 0) + 1) % 5
        view:filter({ severity = severity }, {
          id = "severity",
          template = "{hl:Title}Filter:{hl} {severity}",
          del = severity == 0,
        })
      end,
      desc = "Toggle Severity Filter",
    },
  },
  auto_close = true, -- auto close when there are no items
}
