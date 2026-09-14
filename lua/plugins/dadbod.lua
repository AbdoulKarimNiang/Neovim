-- lua/plugins/dadbod.lua - SQL client: vim-dadbod, its UI and completion.
--
-- dadbod shells out to each database's own CLI. Supported upstream: BigQuery,
-- ClickHouse, DuckDB, Impala, MongoDB, MySQL/MariaDB, Oracle, PostgreSQL,
-- Presto, Redis, Snowflake, SQL Server, SQLite. Found on this machine: psql,
-- mysql, duckdb (sqlcmd for SQL Server is not installed).
--
-- Not supported: Databricks has no dadbod adapter. Redshift is not listed
-- either, but speaks the PostgreSQL wire protocol, so a postgresql:// URL
-- through psql is the usual route (an inference, not upstream-documented).
--
-- Credentials: :DBUIAddConnection stores URLs, passwords included, in PLAIN
-- TEXT under g:db_ui_save_location. It is pinned below to Neovim's data
-- directory so it can never end up inside this git repository. Prefer
-- supplying secrets through environment variables ($DBUI_URL, or g:dbs built
-- from os.getenv) instead of saving them.
return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  -- "DB" is listed so the plain :DB command exists before the UI has been
  -- opened. Without it, :DB in a SQL buffer failed with E464 "Ambiguous use of
  -- user-defined command": vim-dadbod was not loaded yet, so the name only
  -- prefix-matched the DBUI* stubs.
  cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  keys = {
    { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "Toggle database UI" },
    { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "Attach buffer to a database" },
    { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "Add database connection" },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    -- Outside the config repo on purpose: saved connections are plain text.
    vim.g.db_ui_save_location = vim.fs.joinpath(vim.fn.stdpath("data"), "db_ui")

    -- Table (and, where supported, column) completion in SQL buffers.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      group = vim.api.nvim_create_augroup("dadbod-completion", { clear = true }),
      callback = function()
        require("cmp").setup.buffer({
          sources = {
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
          },
        })
      end,
    })
  end,
}
