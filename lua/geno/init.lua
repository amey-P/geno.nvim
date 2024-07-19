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

function geno.invoke(prompt_name, user_input)
    local prompt = geno.prompts[prompt_name]

    -- Get chat model's function
    local model_name = prompt['model'] or geno.model
    local model_family = string.match(model_name, "([^/]+)")
    local chat = require("geno." .. model_family).chat

    -- Generate and output
    local original_buffer = vim.api.nvim_get_current_buf()
    local accepted = false
    local user_input = user_input or ""
    local system, user, user_input = utils.process_prompt(prompt, user_input)
    print(system, user, user_input)

    if prompt['replace'] then
        inserter = utils.insert_text
    else
        inserter = function () end
    end
    local update_response, buffer, window = ui.create_output_window()

    -- Buffer keymaps
    opts = { noremap = true, silent = true, buffer = buffer }
    local function map_output_window_key(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(window, true) end, opts)
    vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(window, true) end, opts)

    -- Generate Response
    local response = chat(model_name, system, user, update_response)

    -- Handle Response
    vim.keymap.set('n', 'a', function() 
        vim.api.nvim_win_close(window, true)
        inserter(response, original_buffer)
        accepted = True
    end, opts)
    vim.keymap.set('n', 'r', function() 
        vim.api.nvim_win_close(window, true)
        geno.invoke(prompt_name, user_input)
    end, opts)
end

function geno.invoke_helper(args)
    local prompt_name = args.fargs[1]
    if prompt_name then
        return geno.invoke(prompt_name)
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
                prompt_name = telescope_action_state.get_selected_entry().value
                geno.invoke(prompt_name)
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
vim.keymap.set('n', "<Leader>[", ":GenoInvoke<CR>", { noremap = true, silent = true })

return geno
