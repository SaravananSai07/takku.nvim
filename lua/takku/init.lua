local M = {}

M.config = require("takku.config")
M.core = require("takku.core")

function M.setup(opts)
  M.config.setup(opts)
  M.core.setup()
end

return M
