vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Keymaps for nvim being made for qwerty and not azerty...
local key_swaps = {
    ['1'] = '&', ['&'] = '1',
    ['2'] = 'é', ['é'] = '2',
    ['3'] = '"', ['"'] = '3',
    ['4'] = "'", ["'"] = '4',
    ['5'] = '(', ['('] = '5',
    ['6'] = '§', ['§'] = '6',
    ['7'] = 'è', ['è'] = '7',
    ['8'] = '!', ['!'] = '8',
    ['9'] = 'ç', ['ç'] = '9',
    ['0'] = 'à', ['à'] = '0',
    --['a'] = "q", ['q'] = 'a',
    ['w'] = 'z', ['z'] = 'w',
    ['°'] = ')', [')'] = '°',
    ['-'] = '_', ['_'] = '-',
    --['m'] = ':', [':'] = 'm',
    --['k'] = 'h', ['l'] = 'j',
    --['m'] = 'k', ['ù'] = 'l',
    --['`'] = ':', 
    
}

-- Set options for mappings
local opts = { noremap = true, silent = true }

-- Loop through and set the mappings in normal mode
for key, swap in pairs(key_swaps) do
  vim.api.nvim_set_keymap('n', key, swap, opts)
  vim.api.nvim_set_keymap('v', key, swap, opts)
end

-- Function to map keys
local function map(mode, lhs, rhs, options)
    local options = options or {}
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Additional commands for resizing windows
map('n', '<C-Up>',    ':resize +2<CR>', opts)     -- Increase height
map('n', '<C-Down>',  ':resize -2<CR>', opts)     -- Decrease height
map('n', '<C-Left>',  ':vertical resize -2<CR>', opts) -- Decrease width
map('n', '<C-Right>', ':vertical resize +2<CR>', opts) -- Increase width

-- Copy to clipboard
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', opts)
vim.api.nvim_set_keymap('n', '<leader>Y', '"+yg_', opts)
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', opts)
vim.api.nvim_set_keymap('n', '<leader>yy', '"+yy', opts)

-- Paste from clipboard
vim.api.nvim_set_keymap('n', '<leader>p', '"+p', opts)
vim.api.nvim_set_keymap('n', '<leader>P', '"+P', opts)
vim.api.nvim_set_keymap('v', '<leader>p', '"+p', opts)
vim.api.nvim_set_keymap('v', '<leader>P', '"+P', opts)

-- Save easily
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', opts)
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>', opts)
vim.api.nvim_set_keymap('v', '<C-s>', '<Esc>:w<CR>', opts)

-- Indent Unindent easily
vim.api.nvim_set_keymap('n', '<S-Tab>', '<<_', opts)
vim.api.nvim_set_keymap('i', '<S-Tab>', '<C-D>', opts)
vim.api.nvim_set_keymap('v', '<Tab>', '>gv', opts)
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', opts)
vim.api.nvim_set_keymap('n', '<C-i>', '<C-i>', opts)

-- Breakpoint made easy
vim.api.nvim_set_keymap('n', '<leader>bp', 'obreakpoint()<ESC>', opts)
vim.api.nvim_set_keymap('n', '<leader>bd', 'o__import__("dagster")._utils.forked_pdb.ForkedPdb().set_trace()<ESC>', opts)
