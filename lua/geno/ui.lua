local utils = require("geno.utils")

UI = {}

local DEFAULT_HEIGHT_COVERAGE = 0.5
local DEFAULT_WIDTH_COVERAGE = 0.9

function UI.win_params(vert_coverage, hori_coverage)
    local vert_coverage = vert_coverage or DEFAULT_HEIGHT_COVERAGE
    local hori_coverage = hori_coverage or DEFAULT_WIDTH_COVERAGE

    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local anchor_y = math.floor(height * (1 - vert_coverage) / 2)
    local anchor_x = math.floor(width * (1 - hori_coverage) / 2)

    return {
        col = anchor_x,
        row = anchor_y,
        height = math.floor(height * vert_coverage),
        width = math.floor(width * hori_coverage),
    }
end

-- Native vim
function UI.create_output_window()
    local output_bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer for output
    local win_params = UI.win_params()
    local output_winnr = vim.api.nvim_open_win(output_bufnr, true, {
        relative = 'editor',
        width = win_params.width,
        height = win_params.height,
        row = win_params.row,
        col = win_params.col,
        border = 'rounded',
        style = 'minimal',
    })
    vim.api.nvim_win_set_cursor(output_winnr, {1, 0})
    vim.api.nvim_command('redraw')
    vim.api.nvim_buf_set_option(output_bufnr, "filetype", "markdown")
    vim.api.nvim_buf_set_option(output_bufnr, 'modifiable', false)

    
    -- Function to append text to the buffer
    local function append_to_output(text)
        if result == nil then
            result = ""
        end
        result = result .. text
        local last_line_num = vim.api.nvim_buf_line_count(output_bufnr)
        local last_line = vim.api.nvim_buf_get_lines(output_bufnr, last_line_num - 1, last_line_num, false)[1]
        local new_last_line = last_line .. text
        local lines = vim.split(new_last_line, "\n")

        vim.api.nvim_buf_set_option(output_bufnr, 'modifiable', true)
        vim.api.nvim_buf_set_lines(output_bufnr, last_line_num - 1, last_line_num, false, lines) 
        vim.api.nvim_command('redraw')
        vim.api.nvim_win_set_cursor(output_winnr, {last_line_num, 0})
        vim.api.nvim_buf_set_option(output_bufnr, 'modifiable', false)
    end

    return append_to_output, output_bufnr, output_winnr
end

return UI
