-- lua/plugins/conform.lua - formatting for the languages used here.
--
-- Format-on-save is ON (vim.g.autoformat is set in init.lua), applying each
-- language's standard formatter. Note the trade-off: saving a file in a
-- repository that does not share these settings reformats the whole file and
-- produces a large diff. <leader>uf turns it off for the session.
--
-- External tools this expects, beyond what mason-lspconfig already pulls in:
--   :MasonInstall stylua prettier
-- rustfmt ships with the Rust toolchain and zigfmt with zig, both on PATH.
-- PSScriptAnalyzer is versioned inside the Mason package, so resolve the
-- module path by glob rather than pinning a version number.
local function psa_module()
  local hits = vim.fn.glob(
    vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/PSScriptAnalyzer/*/PSScriptAnalyzer.psd1",
    false,
    true
  )
  return hits[1]
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
    {
      "<leader>uf",
      function()
        vim.g.autoformat = not vim.g.autoformat
        vim.notify("Format on save: " .. (vim.g.autoformat and "ON" or "OFF"))
      end,
      desc = "Toggle format on save",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      -- ruff replaces black+isort and is already installed as the LSP.
      python = { "ruff_organize_imports", "ruff_format" },
      rust = { "rustfmt" },
      zig = { "zigfmt" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      toml = { "taplo" },
      ps1 = { "psscriptanalyzer" },
    },

    formatters = {
      -- PowerShell has no formatter binary. The standard one is
      -- Invoke-Formatter from PSScriptAnalyzer, which Mason already ships
      -- inside the powershell-editor-services package - the module is not
      -- installed system-wide, so it is imported by path.
      --
      -- The LSP cannot stand in here: powershell_es reports
      -- documentFormattingProvider = nil, so lsp_format = "fallback" finds no
      -- server and leaves .ps1 files untouched.
      psscriptanalyzer = {
        command = "pwsh",
        stdin = true,
        condition = function()
          return psa_module() ~= nil
        end,
        args = function()
          return {
            "-NoLogo",
            "-NoProfile",
            "-Command",
            table.concat({
              "[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();",
              ("Import-Module '%s' -ErrorAction Stop;"):format(psa_module()),
              "$src = [Console]::In.ReadToEnd();",
              -- OTBS matches the codeFormatting Preset set for powershell_es.
              "Invoke-Formatter -ScriptDefinition $src -Settings CodeFormattingOTBS",
            }, " "),
          }
        end,
      },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      if not vim.g.autoformat then
        return nil
      end
      return { timeout_ms = 3000, lsp_format = "fallback", bufnr = bufnr }
    end,
  },
}
