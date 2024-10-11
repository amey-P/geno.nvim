M = {}

-- Ensure function is called before window creation
function M.process_prompt(prompt, default_input, selection, filetype)
    local system = prompt['system']
    local user = prompt['user']


    system = system.gsub(system, "$filetype", filetype)
    user = system.gsub(user, "$filetype", filetype)
    system = system.gsub(system, "$text", selection)
    user = user.gsub(user, "$text", selection)

    if string.match(system, "$input") or string.match(user, "$input") then
        vim.ui.input({ prompt = "Prompt|> ", default = default_input },
            function(user_input)
                system = string.gsub(system, "$input", user_input)
                user = string.gsub(user, "$input", user_input)
            end
        )
    end

    return system, user
end


function M.insert_text()
    local reg_info = vim.fn.getreginfo('"')
    vim.api.nvim_command("normal! ggyG")

    vim.api.nvim_win_close(0, true)
    local mode = vim.fn.mode()
    if (mode == "v") or (mode == "V") then
        vim.api.nvim_command("normal! \"_dP")
    else
        vim.api.nvim_command("normal! P")
    end
    vim.fn.setreg('"', reg_info)
end


function M.get_selection()
    if not ((vim.fn.mode() == "v") or (vim.fn.mode() == "V")) then
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return table.concat(lines, '\n')
    end
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '\n')
end

return M
