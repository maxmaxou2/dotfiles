return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            python = { "ruff_fix", "ruff_format" },
            javascript = { "prettier", "eslint_d" },
            typescript = { "prettier", "eslint_d" },
            vue = { "prettier", "eslint_d" },
            json = { "prettier" },
            lua = { "stylua" },
            markdown = { "prettier" },
        },
    }
}
