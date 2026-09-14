-- lua/plugins/neotest.lua - run tests from the editor.
--
-- Adapters for the languages used here. None of them depend on the old
-- nvim-treesitter module API, which the `main` branch removed; they only need
-- the parsers, which are installed.
--   python  neotest-python (pytest)
--   rust    neotest-rust, which drives cargo-nextest - enabled only when
--           cargo-nextest is installed, so a missing tool gives no errors
--
-- Zig is deliberately absent. neotest-zig injects its own test runner, and on
-- Zig 0.15 that runner does not compile (std.ArrayList(...).init was removed
-- in 0.15), so every Zig test was reported as failed. Upstream still targets
-- 0.14; re-add "lawrence-laz/neotest-zig" once it supports the installed Zig.
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-python",
    "rouge8/neotest-rust",
  },
  keys = {
    {
      "<leader>tn",
      function()
        require("neotest").run.run()
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run tests in file",
    },
    {
      "<leader>tl",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Re-run last test",
    },
    {
      "<leader>tS",
      function()
        require("neotest").run.stop()
      end,
      desc = "Stop test run",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle test summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open({ enter = true })
      end,
      desc = "Show test output",
    },
    {
      "<leader>tO",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Toggle output panel",
    },
    {
      "[t",
      function()
        require("neotest").jump.prev({ status = "failed" })
      end,
      desc = "Previous failed test",
    },
    {
      "]t",
      function()
        require("neotest").jump.next({ status = "failed" })
      end,
      desc = "Next failed test",
    },
  },
  config = function()
    local adapters = {
      require("neotest-python")({
        runner = "pytest",
        -- Work around an upstream fallback bug (neotest-python base.lua):
        --   exepath("python3") or exepath("python") or "python"
        -- exepath() returns "" when a program is missing, and "" is truthy in
        -- Lua. With no python3 on Windows it launched an empty command, the run
        -- died at once, and every test was reported as failed. Keep the
        -- adapter's own detection (VIRTUAL_ENV, local venv, Pipenv, Poetry,
        -- uv) and only repair the empty fallback.
        python = function(root)
          local cmd = require("neotest-python.base").get_python_command(root)
          if cmd[1] and cmd[1] ~= "" then
            return cmd
          end
          local nio = require("nio")
          for _, exe in ipairs({ "python3", "python" }) do
            local path = nio.fn.exepath(exe)
            if path ~= "" then
              return { path }
            end
          end
          return { "python" }
        end,
      }),
    }

    if vim.fn.executable("cargo-nextest") == 1 then
      table.insert(adapters, require("neotest-rust")({}))
    end

    require("neotest").setup({
      adapters = adapters,
      status = { virtual_text = true },
      output = { open_on_run = false },
    })
  end,
}
