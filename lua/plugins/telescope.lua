return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- ... other dependencies
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.setup({
      defaults = {
        -- Default configuration for telescope goes here:
        prompt_prefix = "🔍 ",
        selection_caret = "➤ ",
        path_display = { "truncate" },

        -- File ignore patterns (great for Windows)
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "dist/",
          "build/",
          "target/",
          "*.exe",
          "*.dll",
          "*.pdb",
          "__pycache__/",
          "*.pyc",
          ".venv/",
          "venv/",
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
          hidden = false, -- Show hidden files (useful for .env, .gitignore, etc.)
        },

        live_grep = {
          theme = "dropdown",
          additional_args = function(opts)
            return {"--hidden"} -- Search in hidden files too
          end
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

    -- Key mappings for telescope (you can add these to your keymaps.lua instead)
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
    vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
    vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })

    -- Git related. Capitals here because vim-fugitive owns the lowercase
    -- pair: <leader>gf is Git fetch and <leader>gc is Git commit.
    vim.keymap.set('n', '<leader>gF', builtin.git_files, { desc = 'Git files (picker)' })
    vim.keymap.set('n', '<leader>gC', builtin.git_commits, { desc = 'Git commits (picker)' })
    vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches (picker)' })

    -- LSP related (works great with your languages)
    vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = 'LSP references' })
    vim.keymap.set('n', '<leader>ld', builtin.lsp_definitions, { desc = 'LSP definitions' })
    vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, { desc = 'Document symbols' })
    vim.keymap.set('n', '<leader>lw', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })

    -- Search for word under cursor
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find word under cursor' })
  end,
}

