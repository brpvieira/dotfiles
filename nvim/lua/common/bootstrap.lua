vim.g.logger = require("common.log")
 
function GetVersionString()
  local v = vim.version()
  return "v" .. v.major .. "_" .. v.minor .. "_" .. v.patch
end

local version = GetVersionString()
local config = vim.fn.stdpath("config") .. "/lua/" .. version
local data = vim.fn.stdpath("data") .. "/" .. version

local paths = {
  config = config,
  data = data,
  lazy_data = data .. "/lazy",
  lazy_plugins = version .. "/plugins",
}

vim.opt.rtp:prepend(paths.data)

vim.g.bootstrap = {
  prefix = version,
  paths = paths
}

