return {
    "vim-test/vim-test",
    dependencies = {"samharju/yeet.nvim"},
    config = function()
        -- Define a custom strategy using yeet
        vim.g['test#custom_strategies'] = {
            yeet_tmux = function(cmd)
                local yeet = require("yeet")
                yeet.execute(cmd)
            end,
            yeet_tmux_snapshot = function(cmd)
                local yeet = require("yeet")
                yeet.execute(cmd .. " --snapshot")
            end
        }
        vim.g['test#strategy'] = 'yeet_tmux'

        -- Add remaps
        vim.keymap.set("n", '<leader>t', ':TestNearest<CR>')
        vim.keymap.set("n", '<leader>T', ':TestFile<CR>')
        -- vim.keymap.set("n", '<leader>a', ':TestSuite<CR>')
        vim.keymap.set("n", '<leader>l', ':TestLast<CR>')
        vim.keymap.set("n", '<leader>g', ':TestVisit<CR>')

        -- Add a remap for running tests with --snapshot
        vim.keymap.set("n", '<leader>s', function()
            local test_strategy = vim.g['test#strategy']
            vim.g['test#strategy'] = 'yeet_tmux_snapshot'
            vim.cmd('TestNearest')
            vim.g['test#strategy'] = test_strategy -- Restore the original strategy
        end)
    end
}
