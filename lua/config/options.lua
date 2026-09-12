-- config/options.lua - General Neovim settings

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- File handling
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.confirm = true

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Mouse support
opt.mouse = "a"

-- Folding
opt.foldmethod = "indent"
opt.foldlevel = 99

-- Update time for better user experience
opt.updatetime = 250
opt.timeoutlen = 300

-- Display
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Enable hex, octal, and binary number recognition
opt.nrformats = "bin,hex,octal"

-- Encoding settings
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Enable better display of special characters
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
