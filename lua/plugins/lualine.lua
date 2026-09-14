-- Set lualine as statusline
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Adapted from: https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/onedark.lua
    local colors = {
      blue = "#61afef",
      green = "#98c379",
      purple = "#c678dd",
      cyan = "#56b6c2",
      red1 = "#e06c75",
      red2 = "#be5046",
      yellow = "#e5c07b",
      fg = "#abb2bf",
      bg = "#282c34",
      gray1 = "#828997",
      gray2 = "#2c323c",
      gray3 = "#3e4452",
    }

    local onedark_theme = {
      normal = {
        a = { fg = colors.bg, bg = colors.green, gui = "bold" },
        b = { fg = colors.fg, bg = colors.gray3 },
        c = { fg = colors.fg, bg = colors.gray2 },
      },
      command = { a = { fg = colors.bg, bg = colors.yellow, gui = "bold" } },
      insert = { a = { fg = colors.bg, bg = colors.blue, gui = "bold" } },
      visual = { a = { fg = colors.bg, bg = colors.purple, gui = "bold" } },
      terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = "bold" } },
      replace = { a = { fg = colors.bg, bg = colors.red1, gui = "bold" } },
      inactive = {
        a = { fg = colors.gray1, bg = colors.bg, gui = "bold" },
        b = { fg = colors.gray1, bg = colors.bg },
        c = { fg = colors.gray1, bg = colors.gray2 },
      },
    }

    -- Import color theme based on environment variable NVIM_THEME
    local env_var_nvim_theme = os.getenv("NVIM_THEME") or "catppuccin"

    -- Define a table of themes
    local themes = {
      onedark = onedark_theme,
      catppuccin = "catppuccin",
    }

    local mode = {
      "mode",
      fmt = function(str)
        -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
        return " " .. str
      end,
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local filename = {
      "filename",
      file_status = true, -- displays file status (readonly status, modified status)
      -- Relative path: several files share a name (e.g. the Ran_PowerQuery*.pq
      -- variants) and the bare name did not tell them apart. Long paths are
      -- shortened from the left to fit.
      path = 1,
      shorting_target = 40,
    }

    -- Project: the git root's directory name, else the file's folder name.
    -- Cached per buffer because a file's project does not change, and this
    -- component is evaluated on every statusline redraw.
    local project = {
      function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
          return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end
        if not vim.b[buf].lualine_project then
          -- Outside git, use the file's own folder: the working directory can be
          -- unrelated (a file opened from Explorer may start nvim in System32).
          local root = vim.fs.root(buf, { ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
          vim.b[buf].lualine_project = vim.fn.fnamemodify(root, ":t")
        end
        return vim.b[buf].lualine_project
      end,
      icon = "\u{f0770}",
    }

    -- Language servers attached to the current buffer. Makes a server that
    -- failed to start (like a mismatched zls) visible at a glance.
    local lsp_clients = {
      function()
        local names = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          names[#names + 1] = client.name
        end
        return table.concat(names, " ")
      end,
      icon = "\u{f085}",
      cond = function()
        return hide_in_width() and #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end,
    }

    -- Format-on-save state. <leader>uf toggles it silently otherwise; shown in
    -- the warning colour while it is off.
    local format_on_save = {
      function()
        return vim.g.autoformat and "fmt" or "fmt off"
      end,
      icon = "\u{f0266}",
      color = function()
        return not vim.g.autoformat and "DiagnosticWarn" or nil
      end,
    }

    local diagnostics = {
      "diagnostics",
      sources = { "nvim_diagnostic" },
      sections = { "error", "warn" },
      symbols = { error = " ", warn = " ", info = " ", hint = " " },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      "diff",
      colored = true,
      symbols = {
        added = "+",
        modified = "~",
        removed = "-",
      },
    }

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = themes[env_var_nvim_theme], -- Set theme based on environment variable
        -- Some useful glyphs:
        -- https://www.nerdfonts.com/cheat-sheet
        --        
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "neo-tree", "Avante" },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { project, "branch" },
        lualine_c = { filename },
        -- encoding dropped: it was always utf-8 and only took space.
        lualine_x = { diagnostics, diff, lsp_clients, format_on_save, { "filetype", cond = hide_in_width } },
        lualine_y = { "location" },
        lualine_z = { "progress" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { { "location", padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { "fugitive" },
    })
  end,
}
