local M = {}
local config = require("takku.config")
local utils = require("takku.utils")
local state = require("takku.state")

local function validate_cursor_position(cursor_pos, lines)
  if not lines or #lines == 0 then
    return { 1, 0 } -- Buffer has 1 line even if the file is empty
  end

  -- Ensure cursor_pos is valid
  if not cursor_pos or type(cursor_pos) ~= "table" or #cursor_pos < 2 then
    return { 1, 0 } -- Default to the start of the file
  end

  local line, col = cursor_pos[1], cursor_pos[2]

  -- Validate line number
  if type(line) ~= "number" or line < 1 then
    line = 1
  elseif line > #lines then
    line = #lines
  end

  -- Validate column number
  if type(col) ~= "number" or col < 0 then
    col = 0
  else
    -- Ensure the line exists before checking its length
    local current_line = lines[line] or ""
    if col > #current_line then
      col = #current_line
    end
  end

  return { line, col }
end

local function file_exists(file_path)
  local stat = vim.loop.fs_stat(file_path)
  return stat ~= nil
end

function M.show_telescope_ui(file_list, on_delete)
  local has_telescope, _ = pcall(require, "telescope")
  if not has_telescope then
    vim.notify("Telescope.nvim is required for this feature", vim.log.levels.ERROR)
    return
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local previewers = require("telescope.previewers")

  local previewer = previewers.new_buffer_previewer({
    title = "File Preview",
    define_preview = function(self, entry, _)
      local file_path = entry.value

      if not file_exists(file_path) then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "File not found: " .. file_path })
        return
      end

      local cursor_pos = state.cursor_positions[file_path] or { 1, 0 }
      local lines = vim.fn.readfile(file_path)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      vim.schedule(function()
        if vim.api.nvim_win_is_valid(self.state.winid) and vim.api.nvim_buf_is_valid(self.state.bufnr) then
          local buffer_lines = vim.api.nvim_buf_get_lines(self.state.bufnr, 0, -1, false)
          cursor_pos = validate_cursor_position(cursor_pos, buffer_lines)
          pcall(vim.api.nvim_win_set_cursor, self.state.winid, cursor_pos)
        else
          vim.notify("Invalid window or buffer", vim.log.levels.WARN)
        end
      end)
    end,
  })

  pickers.new({}, {
    prompt_title = "Takku List",
    finder = finders.new_table({
      results = file_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = utils.get_filename(entry),
          ordinal = utils.get_filename(entry),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)
      -- Open selected file
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. selection.value)
        end
      end)

      -- Delete file from list (mapped to <C-d>)
      map("i", "<C-d>", function()
        local selection = action_state.get_selected_entry()
        if selection then
          on_delete(selection.value)
          actions.close(prompt_bufnr)
          M.show_list(file_list, on_delete) -- Refresh the list
        end
      end)

      return true
    end,
  }):find()
end

function M.show_native_ui(file_list)
  vim.ui.select(
    file_list,
    {
      prompt = "Takku List",
      format_item = function(item)
        return utils.get_filename(item)
      end,
    },
    function(choice)
      if choice then
        if not file_exists(choice) then
          vim.notify("File has been removed: " .. choice, vim.log.levels.WARN)
          return
        end
        local cursor_pos = state.cursor_positions[choice] or { 1, 0 }

        vim.cmd("edit " .. choice)
        vim.api.nvim_win_set_cursor(0, cursor_pos)
      end
    end
  )
end

function M.show_list(file_list, on_delete)
  local use_telescope = config.config.enable_telescope_integration
  if use_telescope then
    local ok, _ = pcall(require, "telescope")
    if not ok then
      vim.notify("Telescope not installed, using native UI", vim.log.levels.WARN)
      use_telescope = false
    end
  end

  if use_telescope then
    M.show_telescope_ui(file_list, on_delete)
  else
    M.show_native_ui(file_list)
  end
end

return M
