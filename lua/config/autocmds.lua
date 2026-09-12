-- config/autocmds.lua - Auto commands

local api = vim.api

-- Highlight when yanking (copying) text
api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    -- vim.highlight was renamed to vim.hl in 0.11; the old name survives only
    -- as a deprecated alias (see vim/_editor.lua, _defer_deprecated_module).
    vim.hl.on_yank()
  end,
})

-- Remove trailing whitespace on save
api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  group = api.nvim_create_augroup("remove-trailing-whitespace", { clear = true }),
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto resize panes when resizing nvim window
api.nvim_create_autocmd("VimResized", {
  desc = "Auto resize panes when resizing nvim window",
  group = api.nvim_create_augroup("auto-resize", { clear = true }),
  command = "tabdo wincmd =",
})

-- Close certain windows with 'q'
api.nvim_create_autocmd("FileType", {
  desc = "Close certain windows with 'q'",
  group = api.nvim_create_augroup("close-with-q", { clear = true }),
  pattern = {
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create directories when saving files
api.nvim_create_autocmd("BufWritePre", {
  desc = "Auto-create directories when saving files",
  group = api.nvim_create_augroup("auto-create-dir", { clear = true }),
  callback = function()
    local dir = vim.fn.fnamemodify(vim.fn.expand("<afile>"), ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Set specific settings for different file types
api.nvim_create_autocmd("FileType", {
  desc = "Set specific settings for different file types",
  group = api.nvim_create_augroup("filetype-settings", { clear = true }),
  pattern = { "python", "javascript", "typescript", "rust", "lua" },
  callback = function()
    local ft = vim.bo.filetype
    if ft == "python" then
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
    elseif ft == "javascript" or ft == "typescript" then
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
    elseif ft == "rust" then
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
    elseif ft == "lua" then
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
    end
  end,
})

-- Return to last edit position when opening files
api.nvim_create_autocmd("BufReadPost", {
  desc = "Return to last edit position when opening files",
  group = api.nvim_create_augroup("last-position", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- JSON folding and formatting
api.nvim_create_autocmd("FileType", {
  desc = "JSON specific settings",
  group = api.nvim_create_augroup("json-settings", { clear = true }),
  pattern = { "json", "jsonc" },
  callback = function()
    -- Folding is global and treesitter-driven; do not override foldmethod
    -- here, it would replace the treesitter expression with syntax folding.
    vim.opt_local.foldlevel = 2

    -- Better indentation
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})
