-- lua/plugins/oil.lua - edit a directory as if it were a text buffer.
--
-- Complements yazi.nvim rather than replacing it. Yazi is a floating browser
-- with preview; oil is the fast path for the three operations that matter
-- most: create, rename, delete. You edit the listing like text and :w applies
-- it - type a name to create a file, add a trailing / to make a directory,
-- dd to delete, change the text to rename. Nothing is written to disk until
-- you save, and oil shows a confirmation of every change first.
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Must load eagerly so it can take over netrw when nvim is given a directory.
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    { "<leader>-", "<cmd>Oil --float<cr>", desc = "Open parent directory (oil, float)" },
  },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = false,
    watch_for_changes = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 4,
      max_width = 120,
      max_height = 40,
      border = "rounded",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
      ["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
      ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open in new tab" },
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-r>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
    },
  },
}
