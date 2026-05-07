-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


vim.g.netrw_banner = 0        -- Hide the help banner at the top
vim.g.netrw_liststyle = 3     -- Tree style view (indented folders)
vim.g.netrw_browse_split = 4  -- Open files in the previous window
vim.g.netrw_altv = 1          -- Open vertical splits to the right
vim.g.netrw_winsize = 25      -- Set sidebar width to 25% of the screen
