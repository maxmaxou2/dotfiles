local g = vim.g
local o = vim.o
local opt = vim.opt

--Smart search
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true  -- Override 'ignorecase' if search contains uppercase letters

--File Reloading
o.autoread = true
o.scrolloff = 7

--Line Numbering
vim.wo.relativenumber = true
vim.wo.number = true

--Indenting
g.python_recommended_style = 0
g.rust_recommended_style = 0
opt.tabstop = 4
opt.smartindent = true
opt.shiftwidth = 4
opt.expandtab = true

-- Recommended by avante.nvim
opt.laststatus = 3
opt.swapfile = false

-- Diagnostic formatting
vim.diagnostic.config({
  float = {
    border = "rounded",
    source = "always", -- always show the source (LSP name)
    focusable = true,
    header = "",
    prefix = "",
  },
})
