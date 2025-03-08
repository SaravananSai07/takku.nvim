local M = {}

M.config = require("takku.config")
M.core = require("takku.core")

function M.setup(user_config)
  M.config.setup(user_config)
  M.core.setup()
end

return M
