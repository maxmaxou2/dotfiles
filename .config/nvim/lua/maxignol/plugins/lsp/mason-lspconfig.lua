return {
    'williamboman/mason-lspconfig.nvim',
    config = function()
        require('mason-lspconfig').setup({
            handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup({})
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
