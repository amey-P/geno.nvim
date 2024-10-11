-- Telescope imports
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local telescope_themes = require "telescope.themes"
local telescope_conf = require("telescope.config").values
local telescope_actions = require "telescope.actions"
local telescope_action_state = require "telescope.actions.state"

-- Local imports
local ui = require("geno.ui")
local utils = require("geno.utils")
local builtin_prompts = require("geno.prompts")
local openai = require("geno.openai")

geno = {}

-- Default options
local default_options = {
    model = "openai/gpt-4o",
    prompts = builtin_prompts,
}
for k, v in pairs(default_options) do geno[k] = v end

-- Override default options
-- TODO: Add Prompts
geno.setup = function(opts) for k, v in pairs(opts) do geno[k] = v end end

-- Get models
function geno.set_model()
    local all_models = {}

    -- Load OpenAI models
    local openai_models = openai.get_models()
    for _, model in ipairs(openai_models) do
        table.insert(all_models, model)
    end

    -- Telescope Picker
    pickers.new(telescope_themes.get_dropdown(), {
        prompt_title = "Available Models",
        finder = finders.new_table {
            results = all_models,
        },
        sorter = telescope_conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            telescope_actions.select_default:replace(function()
                telescope_actions.close(prompt_bufnr)
                geno.model = telescope_action_state.get_selected_entry().value
            end)
            return true
        end,
    }):find()
end

function geno.invoke(prompt_name, selection, filetype)
    local prompt = geno.prompts[prompt_name]

    -- Get chat model's function
    local model_name = prompt['model'] or geno.model
    local model_family = string.match(model_name, "([^/]+)")
    local chat = require("geno." .. model_family).chat

    -- Generate and output
    local system, user = utils.process_prompt(prompt, user_input, selection, filetype)

    if prompt['replace'] then
        inserter = utils.insert_text
    else
        inserter = function (_, _, _) end
    end
    local update_response, buffer, window = ui.create_output_window()

    -- Buffer keymaps
    opts = { noremap = true, silent = true, buffer = buffer }
    vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(window, true) end, opts)
    vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(window, true) end, opts)

    -- Generate Response
    local result = chat(model_name, system, user, update_response)

    -- Handle Response
    vim.keymap.set('n', 'a', inserter, opts)
    vim.keymap.set('n', 'y', function()
        vim.api.nvim_command("normal! ggyG")
        vim.api.nvim_win_close(window, true)
    end, opts)
    vim.keymap.set('n', 'r', function() 
        vim.api.nvim_win_close(window, true)
        geno.invoke(prompt_name, selection)
    end, opts)
end

function geno.invoke_helper(args)
    local selection = utils.get_selection()
    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    local prompt_name = args.fargs[1]
    if prompt_name then
        return geno.invoke(prompt_name, selection, filetype)
    end

    local prompt_names = {}
    for name, _ in pairs(geno.prompts) do
        table.insert(prompt_names, name)
    end

    -- Telescope Picker
    pickers.new(telescope_themes.get_dropdown(), {
        prompt_title = "Action",
        finder = finders.new_table {
            results = prompt_names,
        },
        sorter = telescope_conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            telescope_actions.select_default:replace(function()
                telescope_actions.close(prompt_bufnr)
                local prompt_name = telescope_action_state.get_selected_entry().value
                geno.invoke(prompt_name, selection, filetype)
            end)
            return true
        end,
    }):find()
end

-- Create User Commands
vim.api.nvim_create_user_command("GenoSetModel", geno.set_model, {})
vim.api.nvim_create_user_command(
    "GenoInvoke", 
    geno.invoke_helper, 
    {
        range = true,
        nargs = '?', 
        complete = function() 
            local prompt_names = {}
            for name, _ in pairs(geno.prompts) do
                table.insert(prompt_names, name)
            end
            return prompt_names
        end
    }
)

-- Keybindings
vim.keymap.set('n', "<leader>[", ":GenoInvoke<CR>", { noremap = true, silent = true })
vim.keymap.set('v', "<leader>[", ":GenoInvoke<CR>", { noremap = true, silent = true })

return geno
