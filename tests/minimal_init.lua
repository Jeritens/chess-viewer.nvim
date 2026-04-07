local root = vim.fn.fnamemodify('.', ':p')

vim.opt.rtp:append(root)

local plenary_path = vim.fn.expand('~/.local/share/nvim/lazy/plenary.nvim')
vim.opt.rtp:append(plenary_path)

vim.cmd('runtime! plugin/plenary.vim')
