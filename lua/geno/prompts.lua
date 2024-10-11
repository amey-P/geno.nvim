return {
    Ask = { system="You are a helpful assistant", user = "$input", replace = false},
    Generate = { system="You are a helpful assistant. Follow the instructions given by the user without any additional comments", user = "$input", replace = true},
    Summarize = { system="You summarize user inputs and return back the summary", user = "$selection", replace=true},
    -- chat = {system = "", name = "Chat", prompt = "$input"},
    -- ask = {system = "", name = "Ask", prompt = "Regarding the following text, $input:\n$text"},
    -- change = {
    --     system = "",
    --     name = "Change",
    --     prompt = "Change the following text, $input, just output the final text without additional quotes around it:\n$text",
    --     replace = true
    -- },
    -- enhance_grammar_spelling = {
    --     system = "",
    --     name = "Enhance_Grammar_Spelling",
    --     prompt = "Modify the following text to improve grammar and spelling, just output the final text without additional quotes around it:\n$text",
    --     replace = true
    -- },
    -- enhance_wording = {
    --     name = "Enhance Wording",
    --     system = "Modify the following text to use better wording, just output the final text without additional quotes around it",
    --     user = "$selection",
    --     visual_mode = true,
    --     replace = true
    -- },
    ["Make Concise"] = {
        system = "Modify the following text to make it as simple and concise as possible, just output the final text without additional quotes around it",
        user = "$selection",
        visual_mode = true,
        replace = true
    },
    -- make_list = {
    --     system = "",
    --     name = "Make_List",
    --     prompt = "Render the following text as a markdown list:\n$text",
    --     replace = true
    -- },
    -- make_table = {
    --     system = "",
    --     name = "Make_Table",
    --     prompt = "Render the following text as a markdown table:\n$text",
    --     replace = true
    -- },
    ["Review Code"] = {
        system = "You are a expert $filetype programmer who writes elegant, concise and readable code",
        user = "Review the following code and make concise suggestions:\n```$filetype\n$text\n```"
    },
    ["Enhance Code"] = {
        system = "You are a expert $filetype programmer who writes elegant, concise and readable code",
        prompt = "Enhance the following code, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
        replace = true,
        extract = "```$filetype\n(.-)```"
    },
    -- change_code = {
    --     system = "",
    --     name = "Change_Code",
    --     prompt = "Regarding the following code, $input, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
    --     replace = true,
    --     extract = "```$filetype\n(.-)```"
    -- }
}
