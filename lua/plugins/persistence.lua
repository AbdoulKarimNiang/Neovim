-- lua/plugins/persistence.lua - per-directory sessions.
--
-- Saves the open buffers, splits and folds when Neovim exits, one session per
-- working directory and per git branch. Nothing is restored automatically:
-- <leader>ps brings back the session for the current directory, or use the
-- dashboard's "p" button.
return {
  "folke/persistence.nvim",
  -- Upstream's recommended trigger: session saving starts once a file is read.
  event = "BufReadPre",
  init = function()
    -- Neovim's default also saves `blank` (empty windows such as the oil and
    -- yazi floats), `help` panes and `terminal` buffers, which restore as
    -- fresh shells. Keep only what is worth getting back.
    vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize" }
  end,
  opts = {
    -- Separate sessions per git branch: switching branches does not reopen
    -- files that may not exist on the other one.
    branch = true,
  },
  keys = {
    {
      "<leader>ps",
      function()
        require("persistence").load()
      end,
      desc = "Restore session (this directory)",
    },
    {
      "<leader>pS",
      function()
        require("persistence").select()
      end,
      desc = "Select a session",
    },
    {
      "<leader>pl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>pd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't save this session on exit",
    },
  },
}
