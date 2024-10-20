# Geno.nvim
A rip-off version of [Gen.nvim](https://github.com/David-Kunz/gen.nvim) which supports proprietary LLMs as well.  
Geno.nvim allows you to interact with chat LLMs from neovim to refine or  
produce text/code. 
Includes Telescope integrations and flexible prompt definitions which users can extend
**Supported Models:**
- [X] OpenAI
- [ ] Anthropic
- [ ] Gemini (Gemini, not vertex)


# Features:
- [X] Newlines in output rendering
- [ ] Custom Prompts from user
- [ ] Custom models invocation
- [ ] Using selection as context
    - [ ] Using current file as context if no selection
- [ ] Inserting to replace selection
- [ ] `$filtype` support in prompts
- [ ] Prompts should either be a string or a function
- [ ] 'y' shortcut to yank whole buffer and close. default buffer '"'
