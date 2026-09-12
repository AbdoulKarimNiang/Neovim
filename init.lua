-- init.lua - Main Neovim configuration entry point

-- Set leader key early (before loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Nerd Font is installed (FiraCode Nerd Font) - enables icon glyphs in plugins
vim.g.have_nerd_font = true

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Use simpler directory check for Windows
if not vim.fn.isdirectory(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

-- IMPORTANT: Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with plugin specifications
require("lazy").setup({
  -- Load all plugins from lua/plugins/ directory
  { import = "plugins" }
}, {
  ui = {
    border = "rounded",
  },
  change_detection = {
    notify = false,
  },
})

-- Additional settings for Windows
if vim.fn.has("win32") == 1 then
  -- Prefer PowerShell 7 (pwsh) over Windows PowerShell 5.1.
  -- 5.1 emits OEM/cp1252 on stdout, which mangles UTF-8 output (Nerd Font
  -- glyphs, accented text) in :terminal, :! and filter commands such as
  -- <leader>jf. Recipe follows :help shell-powershell.
  local has_pwsh = vim.fn.executable("pwsh") == 1
  vim.opt.shell = has_pwsh and "pwsh" or "powershell"

  if has_pwsh then
    vim.opt.shellcmdflag = table.concat({
      "-NoLogo",
      "-NoProfile",
      "-NonInteractive",
      "-ExecutionPolicy RemoteSigned",
      "-Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
        .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
        .. "$PSStyle.OutputRendering='plaintext';"
        .. "Remove-Alias -Force -ErrorAction SilentlyContinue tee;",
    }, " ")
  else
    -- 5.1 has no $PSStyle and no Remove-Alias; set encoding only.
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned "
      .. "-Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
  end

  -- %% is an escaped literal '%' in these options; %s is the filename slot.
  vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.opt.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

-- JSON specific indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Persistent undo
-- Create undo directory if it doesn't exist (Windows path)
local undo_dir = vim.fn.expand('~/AppData/Local/nvim/undo')
if vim.fn.isdirectory(undo_dir) == 0 then
    vim.fn.mkdir(undo_dir, 'p')
end

-- Enable persistent undo
vim.opt.undofile = true
vim.opt.undodir = undo_dir
vim.opt.undolevels = 1000      -- Maximum number of changes that can be undone
vim.opt.undoreload = 10000     -- Maximum number lines to save for undo on buffer reload
