return {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        {
            "<leader>dv",
            function()
                -- Check if Diffview is already open
                local view = require("diffview.lib").get_current_view()
                if view then
                    vim.cmd("DiffviewClose")
                else
                    vim.cmd("DiffviewOpen")
                end
            end,
            desc = "Toggle Diffview",
        }, { "<leader>df", ":DiffviewToggleFiles<CR>", desc = "Toggle File Panel" },
        {
            "<leader>dd",
            function()
                local file = vim.fn.expand("%")
                vim.cmd("DiffviewFileHistory " .. file)
            end,
            desc = "Diff current file with history"
        },
    },
    config = function()
        require("diffview").setup({
            file_panel = {
                enable = false,
            },
            view = {
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                },
            },
        })
    end
}
