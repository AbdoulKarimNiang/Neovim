return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- ... other dependencies
  },
  cmd = "Telescope",
  keys = {
    -- Declared here rather than inside config() so the plugin can stay lazy:
    -- keymaps set in config() only exist once something else has loaded it.
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
    { "<leader>fc", function() require("telescope.builtin").commands() end, desc = "Commands" },
    { "<leader>fk", function() require("telescope.builtin").keymaps() end, desc = "Keymaps" },
    { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Find word under cursor" },
    { "<leader>gF", function() require("telescope.builtin").git_files() end, desc = "Git files (picker)" },
    { "<leader>gC", function() require("telescope.builtin").git_commits() end, desc = "Git commits (picker)" },
    { "<leader>gb", function() require("telescope.builtin").git_branches() end, desc = "Git branches (picker)" },
    { "<leader>lr", function() require("telescope.builtin").lsp_references() end, desc = "LSP references" },
    { "<leader>ld", function() require("telescope.builtin").lsp_definitions() end, desc = "LSP definitions" },
    { "<leader>ls", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document symbols" },
    { "<leader>lw", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace symbols" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        -- Default configuration for telescope goes here:
        prompt_prefix = "🔍 ",
        selection_caret = "➤ ",
        path_display = { "truncate" },

        -- These are Lua patterns, not globs. "*.exe" is a valid pattern but
        -- means "a literal asterisk, any char, exe", so it never matched a
        -- real filename; the extension filters below were all dead.
        -- [/\\] covers both separators, since paths arrive backslashed on
        -- Windows depending on which finder produced them.
        file_ignore_patterns = {
          "%.git[/\\]",
          "node_modules[/\\]",
          "__pycache__[/\\]",
          "%.venv[/\\]",
          "venv[/\\]",
          "dist[/\\]",
          "build[/\\]",
          "target[/\\]",
          "%.exe$",
          "%.dll$",
          "%.pdb$",
          "%.pyc$",
        },

        -- Keybindings within telescope
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-c>"] = actions.close,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },

      pickers = {
        -- Configuration for specific pickers
        find_files = {
          theme = "dropdown",
          previewer = false,
          hidden = false, -- do not list dotfiles; flip to true for .env/.gitignore
        },

        live_grep = {
          theme = "dropdown",
          additional_args = function(opts)
            return { "--hidden" } -- Search in hidden files too
          end,
        },

        buffers = {
          theme = "dropdown",
          previewer = false,
          initial_mode = "normal",
          mappings = {
            i = {
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              ["dd"] = actions.delete_buffer,
            },
          },
        },

        git_files = {
          theme = "dropdown",
          previewer = false,
        },

        help_tags = {
          theme = "dropdown",
        },

        -- LSP pickers (great for your languages)
        lsp_references = {
          theme = "dropdown",
        },

        lsp_definitions = {
          theme = "dropdown",
        },

        lsp_document_symbols = {
          theme = "dropdown",
        },
      },

      extensions = {
        -- Extensions configuration goes here
      },
    })

  end,
}
