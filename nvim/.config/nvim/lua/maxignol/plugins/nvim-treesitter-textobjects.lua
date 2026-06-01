return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    -- loads alongside nvim-treesitter (which is lazy=false on main)
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,
            },
            move = {
                set_jumps = true,
            },
        })

        local select = require("nvim-treesitter-textobjects.select")
        local swap = require("nvim-treesitter-textobjects.swap")
        local move = require("nvim-treesitter-textobjects.move")

        -- select: { lhs, capture }
        local selections = {
            { "a=", "@assignment.outer" },
            { "i=", "@assignment.inner" },
            { "l=", "@assignment.lhs" },
            { "r=", "@assignment.rhs" },
            { "aa", "@parameter.outer" },
            { "ia", "@parameter.inner" },
            { "ai", "@conditional.outer" },
            { "ii", "@conditional.inner" },
            { "al", "@loop.outer" },
            { "il", "@loop.inner" },
            { "af", "@call.outer" },
            { "if", "@call.inner" },
            { "am", "@function.outer" },
            { "im", "@function.inner" },
            { "ac", "@class.outer" },
            { "ic", "@class.inner" },
        }
        for _, m in ipairs(selections) do
            vim.keymap.set({ "x", "o" }, m[1], function()
                select.select_textobject(m[2], "textobjects")
            end, { desc = "Select " .. m[2] })
        end

        -- swap
        vim.keymap.set("n", "<leader>na", function()
            swap.swap_next("@parameter.inner")
        end, { desc = "Swap parameter with next" })
        vim.keymap.set("n", "<leader>nm", function()
            swap.swap_next("@function.outer")
        end, { desc = "Swap function with next" })
        vim.keymap.set("n", "<leader>pa", function()
            swap.swap_previous("@parameter.inner")
        end, { desc = "Swap parameter with previous" })
        vim.keymap.set("n", "<leader>pm", function()
            swap.swap_previous("@function.outer")
        end, { desc = "Swap function with previous" })

        -- move: { lhs, capture, group? }
        local function map_move(fn, maps)
            for _, m in ipairs(maps) do
                vim.keymap.set({ "n", "x", "o" }, m[1], function()
                    fn(m[2], m[3] or "textobjects")
                end, { desc = m[1] })
            end
        end

        map_move(move.goto_next_start, {
            { "]f", "@call.outer" },
            { "]m", "@function.outer" },
            { "]c", "@class.outer" },
            { "]i", "@conditional.outer" },
            { "]l", "@loop.outer" },
            { "]s", "@local.scope", "locals" },
            { "]z", "@fold", "folds" },
        })
        map_move(move.goto_next_end, {
            { "]F", "@call.outer" },
            { "]M", "@function.outer" },
            { "]C", "@class.outer" },
            { "]I", "@conditional.outer" },
            { "]L", "@loop.outer" },
        })
        map_move(move.goto_previous_start, {
            { "[f", "@call.outer" },
            { "[m", "@function.outer" },
            { "[c", "@class.outer" },
            { "[i", "@conditional.outer" },
            { "[l", "@loop.outer" },
        })
        map_move(move.goto_previous_end, {
            { "[F", "@call.outer" },
            { "[M", "@function.outer" },
            { "[C", "@class.outer" },
            { "[I", "@conditional.outer" },
            { "[L", "@loop.outer" },
        })

        local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

        -- vim way: ; goes the direction you were moving.
        vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
        vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

        -- make builtin f, F, t, T repeatable with ; and ,
        vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
    end,
}
