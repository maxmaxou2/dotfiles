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
        local max_filesize = 5 * 1024 -- 5 KB
        vim.api.nvim_create_augroup('JsonSyntax', { clear = true })
        vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufReadPost' }, {
            pattern = "*.json$",
            callback = function()
                local file = vim.fn.expand("%:p")
                local filesize = vim.fn.getfsize(file)
                if filesize > max_filesize then
                    vim.api.nvim_echo({{"File too large, disabling syntax", "WarningMsg"}}, false, {})
                    vim.cmd("setlocal syntax=off")
                else
                    vim.cmd("setlocal syntax=json")
                end
            end,
            group = 'JsonSyntax',
        })
    end
}
