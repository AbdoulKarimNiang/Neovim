return {
  "folke/which-key.nvim",
  event = "VimEnter",
  config = function()
    require("which-key").setup()

    -- These labels must match the prefixes that are really bound. The previous
    -- set was inherited from kickstart.nvim and described an LSP layout this
    -- config did not have: <leader>c/<leader>r/<leader>w had no mappings under
    -- them at all, and <leader>s was labelled Search while every <leader>s key
    -- is a window split.
    require("which-key").add({
      { "<leader>a", group = "[A]I / Claude Code" },
      { "<leader>b", group = "[B]uffer" },
      { "<leader>c", group = "[C]ode (LSP)" },
      { "<leader>d", group = "[D]iagnostics / [D]ocument" },
      { "<leader>f", group = "[F]ind / files" },
      { "<leader>g", group = "[G]it" },
      { "<leader>j", group = "[J]SON" },
      { "<leader>l", group = "[L]SP pickers / location list" },
      { "<leader>m", group = "[M]olten (Jupyter)" },
      { "<leader>p", group = "[P]roject" },
      { "<leader>q", group = "[Q]uickfix" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>s", group = "[S]plit windows" },
      { "<leader>t", group = "[T]erminal" },
      { "<leader>u", group = "[U]I toggles" },
      { "<leader>w", group = "[W]orkspace (LSP)" },
      { "<leader>y", group = "[Y]azi" },
    })
  end,
}
