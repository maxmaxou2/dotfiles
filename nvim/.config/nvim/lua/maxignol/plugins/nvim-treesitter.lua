return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- main branch does NOT support lazy-loading
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")

        ts.setup({})

        local ensure_installed = {
            "python",
            "json",
            "javascript",
            "typescript",
            "tsx",
            "yaml",
            "html",
            "css",
            "prisma",
            "markdown",
            "markdown_inline",
            "svelte",
            "graphql",
            "bash",
            "lua",
            "vim",
            "vue",
            "dockerfile",
            "gitignore",
            "query",
        }

        -- async, no-op for already-installed parsers
        ts.install(ensure_installed)

        -- main branch enables nothing automatically. Start highlight + indent
        -- per buffer when a parser is available.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("maxignol_treesitter", { clear = true }),
            callback = function(args)
                local buf = args.buf
                local ft = vim.bo[buf].filetype
                local lang = vim.treesitter.language.get_lang(ft)
                if not lang then
                    return
                end
                -- only proceed if a parser is actually installed/available
                if not pcall(vim.treesitter.language.add, lang) then
                    return
                end
                pcall(vim.treesitter.start, buf, lang)
                -- experimental treesitter indentation
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
