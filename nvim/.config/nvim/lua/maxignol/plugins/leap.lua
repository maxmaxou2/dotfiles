return {
    "ggandor/leap.nvim",
    config = function()
        local leap = require('leap')
        leap.create_default_mappings()
        leap.opts.preview_filter = function () return false end
    end
}
