local config = require("takku.config")
local utils = require("takku.utils")
local ui = require("takku.ui")

local M = {}

M.file_list = {}
M.cursor_positions = {}

function M.add_file()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return end
  if not vim.tbl_contains(M.file_list, file_path) then
    table.insert(M.file_list, file_path)
    if #M.file_list > config.config.max_files then
      table.remove(M.file_list, 1)
    end
    if config.config.notifications then
      vim.notify("[Takku] Added: " .. utils.get_filename(file_path), vim.log.levels.INFO)
    end
  else
    if config.config.notifications then
      vim.notify("[Takku] Already in list: " .. utils.get_filename(file_path), vim.log.levels.WARN)
    end
  end
  M.save_cursor_position()
end

function M.remove_file(file_path)
  for i, path in ipairs(M.file_list) do
    if path == file_path then
      table.remove(M.file_list, i)
      M.cursor_positions[path] = nil
      if config.config.notifications then
        vim.notify("[Takku] Removed: " .. utils.get_filename(path), vim.log.levels.WARN)
      end
      return
    end
  end
end

function M.save_cursor_position()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path ~= "" then
    M.cursor_positions[file_path] = vim.api.nvim_win_get_cursor(0)
  end
end

function M.goto_file(index)
  if M.file_list[index] then
    vim.cmd("edit " .. M.file_list[index])
    if M.cursor_positions[M.file_list[index]] then
      vim.api.nvim_win_set_cursor(0, M.cursor_positions[M.file_list[index]])
    end
  end
end

function M.show_file_list()
  ui.show_list(M.file_list, M.remove_file)
end

function M.setup_mappings()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  map("n", config.config.mappings.add_file, M.add_file, opts)
  map("n", config.config.mappings.delete_file, function()
    M.remove_file(vim.api.nvim_buf_get_name(0))
  end, opts)

  for i = 1, config.config.max_files do
    map("n", config.config.mappings.goto_file .. i, function()
      M.goto_file(i)
    end, opts)
  end

  map("n", config.config.mappings.show_list, M.show_file_list, opts)
end

function M.setup()
  M.setup_mappings()
  vim.api.nvim_create_autocmd("BufLeave", {
    callback = M.save_cursor_position,
  })
end

return M
