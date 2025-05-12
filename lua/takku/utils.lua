local M = {}

function M.tbl_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function M.get_filename(path)
  return path:match("^.+/(.+)$") or path
end

function M.get_relative_path(path)
  local cwd = vim.fn.getcwd()
  if path:sub(1, #cwd) == cwd then
    return path:sub(#cwd + 2) -- +2 to remove the leading slash
  end
  return path
end

return M
