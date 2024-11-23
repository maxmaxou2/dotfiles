-- Keymaps for nvim being made for qwerty and not azerty...
local key_swaps = {
    ['1'] = '&',
    ['&'] = '1',
    ['2'] = 'é',
    ['é'] = '2',
    ['3'] = '"',
    ['"'] = '3',
    ['4'] = "'",
    ["'"] = '4',
    ['5'] = '(',
    ['('] = '5',
    ['6'] = '§',
    ['§'] = '6',
    ['7'] = 'è',
    ['è'] = '7',
    ['8'] = '!',
    ['!'] = '8',
    ['9'] = 'ç',
    ['ç'] = '9',
    ['0'] = 'à',
    ['à'] = '0',
    ['w'] = 'z',
    ['z'] = 'w',
    ['°'] = ')',
    [')'] = '°',
    ['-'] = '_',
    ['_'] = '-',
}
local opts = { noremap = true, silent = true }
for key, swap in pairs(key_swaps) do
    vim.api.nvim_set_keymap('n', key, swap, opts)
    vim.api.nvim_set_keymap('v', key, swap, opts)
end
