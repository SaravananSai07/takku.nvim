local config = require("takku.config")
local utils = require("takku.utils")
local ui = require("takku.ui")
local state = require("takku.state")

local M = {}

local function keymap_opts(desc)
  return { noremap = true, silent = true, desc = desc }
end

function M.add_file()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return end
  if not vim.tbl_contains(state.file_list, file_path) then
    table.insert(state.file_list, file_path)
    if #state.file_list > config.config.max_files then
      table.remove(state.file_list, 1)
    end
    if config.config.notifications then
      vim.notify("[Takku] Added: " .. utils.get_filename(file_path), vim.log.levels.INFO)
    end
    M.setup_numbered_mappings()
  else
    if config.config.notifications then
      vim.notify("[Takku] Already in list: " .. utils.get_filename(file_path), vim.log.levels.WARN)
    end
  end
  M.save_cursor_position()
  state.save_state()
end

function M.remove_file(file_path)
  for i, path in ipairs(state.file_list) do
    if path == file_path then
      table.remove(state.file_list, i)
      state.cursor_positions[path] = nil
      if config.config.notifications then
        vim.notify("[Takku] Removed: " .. utils.get_filename(path), vim.log.levels.WARN)
      end
      M.setup_numbered_mappings()
      return
    end
  end
  state.save_state()
end

function M.save_cursor_position()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path ~= "" then
    state.cursor_positions[file_path] = vim.api.nvim_win_get_cursor(0)
  end
end

function M.goto_file(index)
  if state.file_list[index] then
    vim.cmd("edit " .. state.file_list[index])
    if state.cursor_positions[state.file_list[index]] then
      vim.api.nvim_win_set_cursor(0, state.cursor_positions[state.file_list[index]])
    end
  end
end

function M.show_file_list()
  ui.show_list(state.file_list, M.remove_file)
end

local function tbl_indexof(t, value)
  for i, v in ipairs(t) do
    if v == value then
      return i
    end
  end
  return nil
end

function M.next_file()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_index = tbl_indexof(state.file_list, current_file)
  if current_index then
    local next_index = current_index % #state.file_list + 1
    M.goto_file(next_index)
  else
    if #state.file_list > 0 then
      M.goto_file(1)
    end
  end
end

function M.prev_file()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_index = tbl_indexof(state.file_list, current_file)
  if current_index then
    local prev_index = (current_index - 2) % #state.file_list + 1
    M.goto_file(prev_index)
  else
    if #state.file_list > 0 then
      M.goto_file(#state.file_list)
    end
  end
end

function M.setup_mappings()
  local map = vim.keymap.set

  map("n", config.config.mappings.add_file, M.add_file, keymap_opts("Takku add file"))
  map("n", config.config.mappings.delete_file, function()
    M.remove_file(vim.api.nvim_buf_get_name(0))
  end, keymap_opts("Takku delete file"))

  map("n", config.config.mappings.next_file, M.next_file, keymap_opts("Takku next file"))
  map("n", config.config.mappings.prev_file, M.prev_file, keymap_opts("Takku previous file"))

  M.setup_numbered_mappings()

  map("n", config.config.mappings.show_list, M.show_file_list, keymap_opts("Takku list files"))
end

function M.setup_numbered_mappings()
  local map = vim.keymap.set

  for i = 1, #state.file_list do
    if i > config.config.max_files then
      break
    end
    local file_path = state.file_list[i]
    map("n", config.config.mappings.goto_file .. i, function()
      M.goto_file(i)
    end, keymap_opts("Open " .. utils.get_relative_path(file_path)))
  end
end

function M.setup()
  M.setup_mappings()

  state.load_state()
  M.setup_numbered_mappings()

  vim.api.nvim_create_autocmd("BufLeave", {
    callback = M.save_cursor_position,
  })
end

return M
