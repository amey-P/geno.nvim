M = {}

-- Ensure function is called before window creation
function M.process_prompt(prompt, default_input)
    local system = prompt['system']
    local user = prompt['user']

    -- Prompt builder
    if string.match(system, "$input") or string.match(user, "$input") then
        vim.ui.input({ prompt = "Prompt|> ", default = default_input },
            function(user_input)
                system = string.gsub(system, "$input", user_input)
                user = string.gsub(user, "$input", user_input)
            end
        )
    end

    -- Selection builder
    if string.match(system, "$selection") or string.match(user, "$selection") then
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        -- Error handling in case nothing is selected
        if not start_pos or not end_pos or start_pos[2] < 1 or end_pos[2] < 1 then
            vim.notify("No Selection found...")
        else
            local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

            -- Adjust first and last lines based on selection positions
            lines[1] = lines[1]:sub(start_pos[3], -1)
            if #lines > 1 then -- Only trim the last line if there are multiple lines
                lines[#lines] = lines[#lines]:sub(1, end_pos[3])
            end
            local selection = table.concat(lines, "\n") 
            system.gsub(system, "$selection", selection)
            user.gsub(user, "$selection", selection)
        end
    end

    return system, user
end

funtion M.insert_text(text, buffer)
    -- Inserts text into the buffer where the cursor is
    -- Replaces the current selection if there is one
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    
end

return M
