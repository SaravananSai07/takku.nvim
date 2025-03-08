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

return M
