local M = {}

M.file_list = {}
M.cursor_positions = {}

function M.get_project_id()
  local cwd = vim.fn.getcwd()
  return cwd:gsub("/", "_"):gsub(":", "_")
end

function M.get_state_file_path()
  local data_dir = vim.fn.stdpath("data")
  local takku_dir = data_dir .. "/takku"

  -- Create directory if it doesn't exist
  if not vim.fn.isdirectory(takku_dir) or vim.fn.isdirectory(takku_dir) ~= 1 then
    vim.fn.mkdir(takku_dir, "p")
  end

  return takku_dir .. "/project_" .. M.get_project_id() .. ".json"
end

function M.save_state()
  local state_file = M.get_state_file_path()
  local state_data = {
    file_list = M.file_list,
    cursor_positions = M.cursor_positions
  }

  local json = vim.fn.json_encode(state_data)

  local file = io.open(state_file, "w")
  if file then
    file:write(json)
    file:close()
  end
end

function M.load_state()
  local state_file = M.get_state_file_path()

  local file = io.open(state_file, "r")
  if file then
    local content = file:read("*all")
    file:close()

    if content and content ~= "" then
      local ok, state_data = pcall(vim.fn.json_decode, content)
      if ok and state_data then
        -- Validate file paths before loading
        if state_data.file_list then
          M.file_list = {}
          for _, path in ipairs(state_data.file_list) do
            if vim.fn.filereadable(path) == 1 then
              table.insert(M.file_list, path)
            end
          end
        end
        if #M.file_list > 0 then
          vim.notify("[Takku] Loaded list (" .. #M.file_list .. " files)", vim.log.levels.INFO)
        end

        if state_data.cursor_positions then
          M.cursor_positions = state_data.cursor_positions
        end
      end
    end
  end
end

return M
