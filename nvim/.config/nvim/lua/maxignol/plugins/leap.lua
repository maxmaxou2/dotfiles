return {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
        local leap = require('leap')
        vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
        vim.keymap.set('n',               'S', '<Plug>(leap-from-window)')
        leap.opts.preview_filter = function () return false end
    end
}
