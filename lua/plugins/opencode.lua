-- lua/plugins/opencode.lua
-- Connects to an opencode server running in Neovim's cwd; if none is found,
-- starts one in a vsplit with `opencode --port` (plugin default).
-- Models/providers live in ~/.config/opencode/opencode.json, not here.
-- `go`/`goo` from the README are left unmapped: `go` is builtin (goto byte).
return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    "folke/snacks.nvim",
  },
  init = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}
  end,
  keys = {
    { "<leader>oa", function() require("opencode").ask("@this: ") end, mode = { "n", "x" }, desc = "Ask opencode" },
    { "<leader>os", function() require("opencode").select() end, mode = { "n", "x" }, desc = "Select opencode action" },
    {
      "<leader>op",
      function() return require("opencode").operator("@this ") end,
      mode = { "n", "x" },
      expr = true,
      desc = "Append range to opencode prompt",
    },
    {
      "<leader>ol",
      function() return require("opencode").operator("@this ") .. "_" end,
      expr = true,
      desc = "Append line to opencode prompt",
    },
    { "<leader>on", function() require("opencode").command("session.new") end, desc = "New opencode session" },
    { "<leader>oi", function() require("opencode").command("session.interrupt") end, desc = "Interrupt opencode" },
  },
}
