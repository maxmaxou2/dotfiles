return {
    "mason-org/mason.nvim",
    config = function()
        -- Reserve a space in the gutter
        -- This will avoid an annoying layout shift in the screen
        vim.opt.signcolumn = 'yes'

        -- This is where you enable features that only work
        -- if there is a language server active in the file
        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                local opts = { buffer = event.buf }

                -- Those are already handled by Telescope
                -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gk', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)

                -- Optional: manual format key
                vim.keymap.set({ "n", "x" }, "<F3>", function()
                    require("conform").format({ async = true }, function(err)
                        if not err then
                            local mode = vim.api.nvim_get_mode().mode
                            if vim.startswith(string.lower(mode), "v") then
                                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n",
                                    true)
                            end
                        end
                        vim.cmd("write")
                    end)
                end, { desc = "Format with conform" })
            end,
        })
        require('mason').setup({})
    end
}
