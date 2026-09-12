return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      -- prev_hunk/next_hunk are documented as deprecated in favour of nav_hunk().
      vim.keymap.set("n", "<leader>gp", function()
        gs.nav_hunk("prev")
      end, { buffer = bufnr, desc = "Previous Hunk" })
      vim.keymap.set("n", "<leader>gn", function()
        gs.nav_hunk("next")
      end, { buffer = bufnr, desc = "Next Hunk" })
      vim.keymap.set("n", "<leader>ph", gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
    end,
  },
}
