-- Keymaps for nvim being made for qwerty and not azerty...
local nv_key_swaps = {
    ['&'] = '1',
    ['é'] = '2',
    ['"'] = '3',
    ["'"] = '4',
    ['('] = '5',
    ['§'] = '6',
    ['è'] = '7',
    ['!'] = '8',
    ['ç'] = '9',
    ['à'] = '0',
    ['1'] = '&',
    ['2'] = 'é',
    ['3'] = '"',
    ['4'] = "'",
    ['5'] = '(',
    ['6'] = '§',
    ['7'] = 'è',
    ['8'] = '!',
    ['9'] = 'ç',
    ['0'] = 'à',
    ['z'] = 'w',
    ['Z'] = 'W',
    ['w'] = 'z',
    ['W'] = 'Z',
    ['°'] = ')',
    [')'] = '°',
    ['-'] = '_',
    ['_'] = '-',
}
local opts = { noremap = true, silent = true }
-- for key, swap in pairs(nv_key_swaps) do
--     vim.api.nvim_set_keymap('n', key, swap, opts)
--     vim.api.nvim_set_keymap('v', key, swap, opts)
--     vim.api.nvim_set_keymap('o', key, swap, opts)
-- end
