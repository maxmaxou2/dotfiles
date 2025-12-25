-- Function to map keys
local function map(mode, lhs, rhs, options)
    options = options or { noremap = true, silent = true }
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = " "
map ('n', '<leader>e', '<cmd>Oil<CR>') -- Toggle file explorer

-- Diagnostic floating window
map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>')

-- Additional commands for resizing windows
map('n', '<C-Up>', ':resize +2<CR>')             -- Increase height
map('n', '<C-Down>', ':resize -2<CR>')           -- Decrease height
map('n', '<C-Left>', ':vertical resize -2<CR>')  -- Decrease width
map('n', '<C-Right>', ':vertical resize +2<CR>') -- Increase width

-- Copy to clipboard
map('v', '<leader>y', '"+y')
map('n', '<leader>Y', '"+yg_')
map('n', '<leader>y', '"+y')
map('n', '<leader>yy', '"+yy')

-- Paste from clipboard
map('n', '<leader>p', '"+p')
map('n', '<leader>P', '"+P')
map('v', '<leader>p', '"+p')
map('v', '<leader>P', '"+P')

-- Save easily
map('n', '<C-s>', ':w<CR>')
map('i', '<C-s>', '<Esc>:w<CR>')
map('v', '<C-s>', '<Esc>:w<CR>')

-- Indent Unindent easily
map('n', '<S-Tab>', '<<_')
map('i', '<S-Tab>', '<C-D>')
map('v', '<Tab>', '>gv')
map('v', '<S-Tab>', '<gv')
map('n', '<C-i>', '<C-i>')

-- Breakpoint made easy
map('n', '<leader>bp', 'obreakpoint()<ESC>')
map('n', '<leader>bd', 'o__import__("dagster")._utils.forked_pdb.ForkedPdb().set_trace()<ESC>')

-- Moving around
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- In new split actions
map('n', '<leader>gd', '<C-w>v<C-l>gd', { noremap = false, silent = true })
map('n', '<leader>gg', '<C-w>v<C-l>gg', { noremap = false, silent = true })
map('n', '<leader>gr', '<C-w>v<C-l>gr', { noremap = false, silent = true })
vim.keymap.set('n', '<C-w>q', function()
    vim.cmd('quit')           -- Fermer le split actuel
    vim.cmd('TmuxNavigateLeft') -- Fermer le split actuel
end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-w><C-q>', function()
    vim.cmd('quit')           -- Fermer le split actuel
    vim.cmd('TmuxNavigateLeft') -- Fermer le split actuel
end, { noremap = true, silent = true })

-- Resize splits using Ctrl + Shift + h/j/k/l
map('n', '<C-Left>', ':vertical resize -2<CR>')
map('n', '<C-Right>', ':vertical resize +2<CR>')
map('n', '<C-Down>', ':resize +2<CR>')
map('n', '<C-Up>', ':resize -2<CR>')

-- Copy filepath, filename and parent directory to press papier
vim.keymap.set('n', '<leader>yp', function()
    vim.fn.setreg('+', vim.fn.expand('%:p'))
    print('Chemin complet copié !')
end, { desc = 'Copier chemin absolu' })
vim.keymap.set('n', '<leader>yn', function()
    vim.fn.setreg('+', vim.fn.expand('%:t'))
    print('Nom du fichier copié !')
end, { desc = 'Copier nom du fichier' })
vim.keymap.set('n', '<leader>yd', function()
    vim.fn.setreg('+', vim.fn.fnamemodify(vim.fn.expand('%:p:h'), ':p'))
    print('Dossier parent copié !')
end, { desc = 'Copier dossier parent' })

-- Toggle cursor lock (keep cursor at same screen row)
vim.keymap.set("n", "<Space><Space>", function()
  require("maxignol.cursor_lock").toggle()
end, { desc = "Toggle cursor lock (keep cursor at same screen row)" })
