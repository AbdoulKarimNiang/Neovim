-- lua/plugins/lint.lua - linters for the filetypes no language server covers.
--
-- Deliberately small. Most languages here already get diagnostics from their
-- server, and a second source would only duplicate them:
--   python      ruff (lint) + pyright (types)
--   rust        rust_analyzer with clippy
--   lua         lua_ls
--   powershell  powershell_es already runs PSScriptAnalyzer
--   json/yaml   schema validation via SchemaStore
-- Dockerfiles and shell scripts were the real gaps: both produced no
-- diagnostics at all before this.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      dockerfile = { "hadolint" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
    }

    -- Mason's bin directory is not on PATH, so point each linter at the
    -- executable it installed.
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
    for _, name in ipairs({ "hadolint", "shellcheck" }) do
      local linter = lint.linters[name]
      local hits = vim.fn.glob(mason_bin .. name .. "*", false, true)
      if linter and hits[1] then
        linter.cmd = hits[1]
      end
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function()
        -- Skip buffers that are not real files on disk.
        if vim.bo.buftype ~= "" then
          return
        end
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Lint buffer" })

    -- This plugin loads on BufReadPost, so for the file Neovim was started
    -- with, that event has already fired by the time the autocmd above is
    -- registered, and filetype detection has not run yet either - try_lint()
    -- would see an empty filetype and pick no linter. Schedule the first pass
    -- so it happens once the filetype is known.
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
          vim.api.nvim_buf_call(buf, function()
            lint.try_lint()
          end)
        end
      end
    end)
  end,
}
