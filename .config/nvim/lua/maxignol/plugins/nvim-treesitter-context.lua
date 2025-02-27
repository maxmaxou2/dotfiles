return {
    "nvim-treesitter/nvim-treesitter-context",
    lazy=true,
    config = function()
        require('treesitter-context').setup {
            enable = true,
            multiwindow = false,
            max_lines = 5,
            min_window_height = 0,
            line_numbers = true,
            multiline_threshold = 1,
            trim_scope = 'outer',
            mode = 'topline',
            separator = nil,
            zindex = 20,
            on_attach = nil,
        }
    end,
}
