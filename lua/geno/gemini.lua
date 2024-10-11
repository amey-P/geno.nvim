local utils = require("geno.utils")
M = {}

function M.get_models()
    local api_key = vim.env.GOOGLE_API_KEY -- Get API key from environment
    local cmd = string.format("curl https://generativelanguage.googleapis.com/v1beta/models?key=%s", api_key)

    local handle = io.popen(cmd)
    local result = handle:read("*a")  
    handle:close()

    local models = vim.fn.json_decode(result)
    local chat_models = {}
    for _, model in ipairs(models['data']) do
        if string.match(model['id'], "gpt") then
            table.insert(chat_models, "openai/" .. model['id'])
        end
    end

    return chat_models
end

function M.chat(model, system, user, callback)
    local api_key = vim.env.GOOGLE_API_KEY
    local endpoint = "https://generativelanguage.googleapis.com/v1beta/models/"\ 
                        .. model\
                        .. ":generateContent?key="\
                        .. api_key

    messages = {
        {role = "system", content = system},
        {role = "user", content = user},
    }

    local data = {
        model = string.sub(model, 8),
        messages = messages,
        temperature = 1,
        stream = true
    }

    local curl_cmd = [[curl]]
        .. string.format(" --silent")
        .. string.format(" -H 'Content-Type: application/json'")
        .. string.format(" -H 'Authorization: Bearer %s'", api_key)
        .. string.format(" -X POST -d '%s'", vim.fn.json_encode(data))
        .. string.format(" '%s'", endpoint)

    local unprocessed = ""
    local job_id = vim.fn.jobstart(curl_cmd, {
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line ~= "data: [DONE]" and line ~= "" then
                    local success, chunk = pcall(vim.fn.json_decode, string.sub(line, 7))
                    if success then
                        local msg = chunk.choices[1].delta.content
                        if msg then
                            callback(msg)
                        end
                    end
                else
                    unprocessed = unprocessed .. line
                end
            end
        end,
        on_exit = function(job_id, exit_code, _)
            if exit_code ~= 0 then
                print("Error running curl command:", exit_code)
            end
        end
    })
end

return M
