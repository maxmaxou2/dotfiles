return {
    "vim-test/vim-test",
    dependencies = {"samharju/yeet.nvim"},
    config = function()
        -- Define a custom strategy using yeet
        vim.g['test#custom_strategies'] = {
            yeet_tmux = function(cmd)
                local yeet = require("yeet")
                yeet.execute(cmd)
            end
        }
        vim.g['test#strategy'] = 'yeet_tmux'

        -- Add remaps
        vim.keymap.set("n", '<leader>t', ':TestNearest<CR>')
        vim.keymap.set("n", '<leader>T', ':TestFile<CR>')
        vim.keymap.set("n", '<leader>a', ':TestSuite<CR>')
        vim.keymap.set("n", '<leader>l', ':TestLast<CR>')
        vim.keymap.set("n", '<leader>g', ':TestVisit<CR>')
    end
}
