return {
    'williamboman/mason-lspconfig.nvim',
    config = function()
        require('mason-lspconfig').setup({
            handlers = {
                function(server_name)
                    local lspconfig = require('lspconfig')
                    local opts = {}
                    if server_name == "pylsp" then
                        opts = {
                            settings = {
                                pylsp = {
                                    plugins = {
                                        pycodestyle = { enabled = false },
                                        mccabe = { enabled = false },
                                        pyflakes = { enabled = false },
                                        yapf = {enabled = false},
                                        autopep8 = {enabled = false},
                                        ruff = {enabled=true,format={"I"}},
                                        rope_autoimport = { enabled = true, code_actions = {enabled = true}, completions = {enabled = false} },
                                    },
                                },
                            },
                        }
                    end
                    lspconfig[server_name].setup(opts)
                end,
            }
        })

        -- JSON SPEC
        -- Create an autocmd group to avoid duplicate definitions
        vim.api.nvim_create_augroup('JsonSyntax', { clear = true })
        vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufReadPost' }, {
            pattern = '*.json',
            command = 'setlocal syntax=json',
            group = 'JsonSyntax',
        })
    end
}
