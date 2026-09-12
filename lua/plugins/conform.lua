-- lua/plugins/conform.lua - formatting for the languages used here.
--
-- Format-on-save is OFF by default. Reformatting a whole file the moment you
-- save it produces enormous diffs in repositories that do not share your
-- formatter settings. Toggle it per session with <leader>uf, or turn it on
-- permanently by setting vim.g.autoformat = true in init.lua.
--
-- External tools this expects, beyond what mason-lspconfig already pulls in:
--   :MasonInstall stylua prettier
-- rustfmt ships with the Rust toolchain and zigfmt with zig, both on PATH.
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
      -- ps1 has no standalone CLI formatter; powershell_es formats over LSP,
      -- which the lsp_format fallback below picks up.
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
