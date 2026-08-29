return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Optional but highly recommended: creates an beautiful IDE-like debugging UI
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      config = function()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup()
        -- Auto open/close layout windows when debugging starts/stops
        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
      end
    }
  },
  config = function()
    local dap = require("dap")
    -- Modern JS/TS Debugger Adapter Configuration
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = {
        command = 'js-debug-adapter', -- Managed & exposed globally via Mason paths
        args = { '${port}' },
      }
    }

    local function assign(t1, t2)
      local result = {}
      -- Merge hash-style keys, t2 overrides t1
      for k, v in pairs(t1) do
        if type(k) ~= "number" then result[k] = v end
      end
      for k, v in pairs(t2) do
        if type(k) ~= "number" then result[k] = v end
      end
      -- Concatenate array-style keys instead of overwriting by index
      for _, v in ipairs(t1) do table.insert(result, v) end
      for _, v in ipairs(t2) do table.insert(result, v) end
      return result
    end

    -- Returns the target file, relative to the workspace: the last token in
    -- the leading run of positional args (skipping the node executable and
    -- any node flags before it). For `node app.js -c web.js` that's `app.js`;
    -- for `node cli.js test.js --configFile cfg.js` that's `test.js` — either
    -- way, a flag's own value (e.g. `web.js` after `-c`) is never mistaken
    -- for a positional, since it doesn't start the run.
    local function target_file_relative_to_workspace(cmd, workspace)
      local tokens = {}
      for token in cmd:gmatch("%S+") do table.insert(tokens, token) end

      local target
      local in_positional_block = false
      for i = 2, #tokens do -- skip the node executable (1st token)
        local token = tokens[i]
        if vim.startswith(token, "-") then
          if in_positional_block then break end
        else
          in_positional_block = true
          target = token
        end
      end

      target = target or cmd
      if vim.startswith(target, workspace) then
        target = target:sub(#workspace + 2) -- +2 strips the trailing "/" too
      end
      return target
    end

    local function get_process()
      -- Get the current root/workspace directory
      local workspace = vim.fn.getcwd()

      return require('dap.utils').pick_process({
        filter = function(proc)
          -- proc.name holds the full command line (ps ah CMD column), not just the binary name
          local cmd = proc.name:lower()

          -- 1. Ensure it's a node process
          local is_node = string.find(cmd, "node") ~= nil

          -- 2. Only actual debug targets expose --inspect(-brk) as their own flag.
          -- This also excludes wrapper processes (e.g. mocha.js) that merely
          -- forward it to a spawned child via --node-option.
          local is_debuggable = string.find(cmd, "%-%-inspect") ~= nil

          -- 3. Ensure the full command string contains your workspace folder path
          -- (Using vim.pesc to safely escape special path characters like dashes/dots)
          local matches_workspace = string.find(cmd, vim.pesc(workspace:lower())) ~= nil

          return is_node and is_debuggable and matches_workspace
        end,
        label = function(proc)
          local target = target_file_relative_to_workspace(proc.name, workspace)
          return string.format("id=%d %s", proc.pid, target)
        end,
      })
    end

    local js_defaults = {
        type = "pwa-node",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        -- Crucial Fixes for "provisionalBreakpoint / unverified" errors:
        localRoot = vim.fn.getcwd(),
        remoteRoot = vim.fn.getcwd(),

        -- Force the debugger to scan everything in the workspace folder for mapping matches
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**"
        },

        -- Allows breakpoints to bind cleanly to code using native ES Modules (import/export)
        attachExistingChildren = false,

        skipFiles = { "<node_internals>/**" },
    }

    local mocha_args = {
      "--configFile=${workspaceFolder}/config/local/tests.js",
      "--reporter", "tap",
      "--no-color", -- suppress colored output
      "--bail", -- stop after first failure
      "--no-timeouts", -- don't let mocha kill the test while you're stepping through code
    }

    -- Language Configurations
    local js_config = {
      assign(js_defaults, {
        name = "Launch Current File",
        request = "launch",
        program = "${file}",
      }),
      assign(js_defaults, {
        name = "Attach to Running Process",
        request = "attach",
        processId = get_process,
      }),
      assign(js_defaults, {
        name = "Debug Mocha (current file)",
        request = "launch",
        -- _mocha avoids the mocha.js wrapper spawning a child process,
        -- which otherwise breaks breakpoint binding.
        program = "${workspaceFolder}/node_modules/mocha/bin/_mocha",
        args = assign(mocha_args, {
          "${file}", -- run only the active file in your buffer
        }),
        console = "integratedTerminal",
      }),
      assign(js_defaults, {
        name = "Debug Mocha (current file with args)",
        request = "launch",
        -- _mocha avoids the mocha.js wrapper spawning a child process,
        -- which otherwise breaks breakpoint binding.
        program = "${workspaceFolder}/node_modules/mocha/bin/_mocha",
        args = function()
          local args = assign(mocha_args, {
            "${file}", -- run only the active file in your buffer
          })
          -- Extra args, forwarded to the target script after ${file}
          for word in vim.fn.input("Additional args: "):gmatch("%S+") do
            table.insert(args, word)
          end
          return args
        end,
        console = "integratedTerminal",
      }),
      assign(js_defaults, {
        name = "Debug Mocha (entire suite)",
        request = "launch",
        -- _mocha avoids the mocha.js wrapper spawning a child process,
        -- which otherwise breaks breakpoint binding.
        program = "${workspaceFolder}/node_modules/mocha/bin/_mocha",
        args = assign({
          "--spec", "${workspaceFolder}/tests/**/*.test.js",
          "--exclude","${workspaceFolder}/tests/**/*.external.test.js"
        }, mocha_args),
        console = "integratedTerminal",
      }),
    }

    -- Apply configurations to both JavaScript and TypeScript ecosystems
    dap.configurations.javascript = js_config
    dap.configurations.typescript = js_config

    vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "DAP Continue / Start" })
    vim.keymap.set('n', '<F6>', function() require('dap').step_into() end, { desc = "DAP Step Into" })
    vim.keymap.set('n', '<F7>', function() require('dap').step_out() end, { desc = "DAP Step Out" })
    vim.keymap.set('n', '<F8>', function() require('dap').step_over() end, { desc = "DAP Step Over" })
    vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
    vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "DAP Conditional Breakpoint" })
    vim.keymap.set('n', '<Leader>ui', function() require('dapui').toggle() end, { desc = "DAP Toggle UI Layout" })
    vim.keymap.set('n', '<leader>dc', function() require('dap').run_to_cursor() end, { desc = 'Debug: Run to Cursor' })
  end,
}
