-- lua/plugins/yazi.lua
-- Yazi file manager integration for Neovim

return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    -- Open yazi at the current file location
    {
      "<leader>e",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at current file",
    },
    -- Open yazi at current working directory
    {
      "<leader>E",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi at working directory",
    },
    -- Resume last yazi session
    {
      "<leader>yr",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume last yazi session",
    },
  },
  opts = {
    -- Don't hijack netrw by default
    open_for_directories = false,

    -- Open splits and quickfix as yazi tabs for easy navigation
    open_multiple_tabs = true,

    -- Floating window configuration
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,

    -- Keymaps inside yazi
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-s>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>",
    },

    -- Integration with telescope (since you have telescope configured)
    integrations = {
      --- Grep in directory using telescope
      grep_in_directory = function(directory)
        require("telescope.builtin").live_grep({
          search_dirs = { directory },
          prompt_title = "Live Grep in " .. vim.fn.fnamemodify(directory, ":t"),
        })
      end,

      --- Find files in directory using telescope
      find_in_directory = function(directory)
        require("telescope.builtin").find_files({
          cwd = directory,
          prompt_title = "Find Files in " .. vim.fn.fnamemodify(directory, ":t"),
        })
      end,

      --- Replace in directory (if you have spectre or similar)
      replace_in_directory = function(directory)
        -- You can integrate with nvim-spectre if you have it installed
        -- require("spectre").open_file_search({ cwd = directory })

        -- Fallback to telescope + live_grep for now
        require("telescope.builtin").live_grep({
          search_dirs = { directory },
          prompt_title = "Search & Replace in " .. vim.fn.fnamemodify(directory, ":t"),
        })
      end,
    },

    -- Log level for debugging (set to "off" for normal use)
    log_level = vim.log.levels.OFF,
  },
}
