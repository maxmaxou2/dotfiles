local function fold_to_level(level)
    local function inner()
        return require("ufo").closeFoldsWith(level)
    end
    return inner
end

local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}

    local suffix = ("  %d lines"):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. ("."):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    local spaces = string.rep(".", 80 - curWidth - sufWidth)
    suffix = " " .. spaces .. suffix
    table.insert(newVirtText, { suffix, "Comment" })
    return newVirtText
end

return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
        local ufo = require("ufo")
        -- folding
        vim.o.foldcolumn = "0" -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        ufo.setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
            fold_virt_text_handler = handler,
        })
        vim.keymap.set("n", "zR", ufo.openAllFolds)
        vim.keymap.set("n", "<leader>z1", fold_to_level(0))
        vim.keymap.set("n", "<leader>z2", fold_to_level(1))
        vim.keymap.set("n", '<leader>z3', fold_to_level(2))
        vim.keymap.set("n", "<leader>z4", fold_to_level(3))
        vim.keymap.set("n", "<leader>z5", fold_to_level(4))
    end,
}
