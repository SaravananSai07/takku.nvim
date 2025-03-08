local M = {}
local config = require("takku.config")
local utils = require("takku.utils")

function M.show_telescope_ui(file_list, on_delete)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values

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
            end
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("edit " .. selection.value)
            end)

            actions._delete:replace(function()
                local selection = action_state.get_selected_entry()
                on_delete(selection.value)
                actions.close(prompt_bufnr)
                M.show_list(file_list, on_delete) -- Refresh
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
                vim.cmd("edit " .. choice)
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
