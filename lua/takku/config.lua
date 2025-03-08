local M = {}

M.default_config = {
  mappings = {
    next_file = "<leader>tn",
    prev_file = "<leader>tp",
    add_file = "<leader>ta",
    delete_file = "<leader>td",
    goto_file = "<leader>t",
    show_list = "<leader>tl",
  },
  max_files = 7,
  enable_telescope_integration = true,
  notifications = true,
}

M.config = {}

function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.default_config, user_config or {})
end

return M
