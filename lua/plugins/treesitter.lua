-- lua/plugins/treesitter.lua - nvim-treesitter `main` branch (Neovim 0.12+).
--
-- `main` is a full rewrite of the archived `master` branch and is not
-- configured through require("nvim-treesitter.configs").setup{} any more.
-- It only installs parsers and queries; every feature is switched on here:
--   highlighting  vim.treesitter.start()                (Neovim core)
--   folds         vim.treesitter.foldexpr()             (global, config/options.lua)
--   indentation   nvim-treesitter's indentexpr          (experimental upstream)
--   selection     Neovim's built-in an / in             (replaces incremental_selection)
-- master had to go: on 0.12 its query code calls iter_matches({ all = false }),
-- an option Neovim 0.12 removed, so every textobject key raised E5108.

-- Parsers installed up front. Anything else is installed on first use by the
-- FileType autocmd below, which stands in for master's `auto_install = true`.
local ensure_installed = {
  "bash",
  "c",
  "css",
  "dockerfile",
  "gitcommit",
  "gitignore",
  "hcl",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "powershell",
  "python",
  "rust",
  "scss",
  "sql",
  "terraform",
  "toml",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "zig",
}

-- Windows: compiling parsers on `main` needs MSVC. The tree-sitter CLI from
-- winget is an MSVC build and calls cl.exe; gcc cannot link the \?\ paths
-- it passes and `zig cc` rejects its target triple. cl.exe is not on PATH
-- outside a Developer shell, so load the environment vcvars64.bat produces -
-- but only when a compile is actually about to happen (~2.5 s), never on a
-- normal start. Requires Visual Studio with the C++ toolset and a Windows SDK.
local msvc_ready = vim.fn.has("win32") == 0 or vim.fn.executable("cl.exe") == 1

local function load_msvc_env()
  if msvc_ready then
    return true
  end
  local installer = vim.fs.joinpath(vim.env["ProgramFiles(x86)"] or "", "Microsoft Visual Studio/Installer")
  local vswhere = installer .. "/vswhere.exe"
  if vim.fn.executable(vswhere) ~= 1 then
    return false
  end
  local vs = vim
    .system({
      vswhere,
      "-latest",
      "-products",
      "*",
      "-requires",
      "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
      "-property",
      "installationPath",
    }, { text = true })
    :wait()
  local root = vim.trim(vs.stdout or "")
  if vs.code ~= 0 or root == "" then
    return false
  end
  local vcvars = (root .. "/VC/Auxiliary/Build/vcvars64.bat"):gsub("/", string.char(92))
  -- vcvars64.bat looks vswhere up by name, so give this one call the
  -- installer directory on PATH.
  local r = vim
    .system({ "cmd.exe", "/d", "/c", vcvars, "&&", "set" }, {
      text = true,
      env = { PATH = installer .. ";" .. vim.env.PATH },
    })
    :wait()
  if r.code ~= 0 then
    return false
  end
  for line in r.stdout:gmatch("[^\r\n]+") do
    local key, value = line:match("^([^=]+)=(.*)$")
    if key and ({ PATH = true, INCLUDE = true, LIB = true, LIBPATH = true })[key:upper()] then
      vim.env[key:upper()] = value
    end
  end
  msvc_ready = vim.fn.executable("cl.exe") == 1
  return msvc_ready
end

-- Every compile path - :TSInstall, :TSUpdate, :TSInstallFromGrammar and the
-- Lua API - goes through these two functions, so wrap them once.
local function wrap_installer()
  local install = require("nvim-treesitter.install")
  if install._msvc_wrapped then
    return
  end
  for _, name in ipairs({ "install", "update" }) do
    local original = install[name]
    install[name] = function(...)
      load_msvc_env()
      return original(...)
    end
  end
  install._msvc_wrapped = true
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- Upstream: "This plugin does not support lazy-loading."
    lazy = false,
    -- A function rather than ":TSUpdate": on a fresh install lazy.nvim can run
    -- the build before config(), and the compiler wrapper must be in place.
    build = function()
      wrap_installer()
      require("nvim-treesitter").update():wait(300000)
    end,
    config = function()
      wrap_installer()
      local ts = require("nvim-treesitter")

      -- Only hand install() the parsers that are genuinely missing, so an
      -- ordinary start never pays for loading the MSVC environment.
      local installed = {}
      for _, lang in ipairs(ts.get_installed("parsers")) do
        installed[lang] = true
      end
      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, ensure_installed)

      local available = {}
      for _, lang in ipairs(ts.get_available()) do
        available[lang] = true
      end

      ---@return boolean started
      local function enable(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
          return false
        end
        -- Only languages that ship an indents query; otherwise keep the
        -- filetype's own indentexpr instead of flattening everything to 0.
        if vim.treesitter.query.get(lang, "indents") then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        return true
      end

      -- Languages with a compile in flight. Both the startup batch below and
      -- the FileType auto-install consult it: without a shared guard, opening
      -- a file whose parser is in the batch started a second tree-sitter
      -- build of the same parser, and the two collided on its lock file
      -- ("Lock file ... appears stale"), failing both.
      local installing = {}

      if #missing > 0 then
        for _, lang in ipairs(missing) do
          installing[lang] = true
        end
        ts.install(missing):await(function()
          for _, lang in ipairs(missing) do
            installing[lang] = nil
          end
          -- Buffers opened while the batch ran could not start highlighting
          -- at the time; retry them now that the parsers exist.
          vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
                local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype) or vim.bo[buf].filetype
                if not vim.treesitter.highlighter.active[buf] then
                  enable(buf, lang)
                end
              end
            end
          end)
        end)
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-enable", { clear = true }),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(event.match) or event.match
          if enable(event.buf, lang) or not available[lang] or installing[lang] then
            return
          end
          -- Parser exists upstream but is not installed yet: fetch it, then
          -- attach to the buffer that asked for it.
          installing[lang] = true
          ts.install(lang):await(function(err)
            installing[lang] = nil
            if not err then
              vim.schedule(function()
                enable(event.buf, lang)
              end)
            end
          end)
        end,
      })

      -- Incremental selection. master's module is gone on `main`; Neovim 0.12
      -- provides it natively as the visual-mode defaults `an` (parent node)
      -- and `in` (child node). These keep the old <C-space> / <BS> keys.
      vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start treesitter node selection" })
      vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand selection to parent node" })
      vim.keymap.set("x", "<BS>", "in", { remap = true, desc = "Shrink selection to child node" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      -- Neovim's own python and rust ftplugins define buffer-local ]] [[ ]m [m.
      -- Buffer-local maps beat the global ones below, so without these guards
      -- the textobject moves would silently not apply in those two languages.
      -- Per-language on purpose: g:no_plugin_maps would disable every
      -- filetype's built-in maps.
      vim.g.no_python_maps = true
      vim.g.no_rust_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      for keys, capture in pairs({
        aa = "@parameter.outer",
        ia = "@parameter.inner",
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
      }) do
        vim.keymap.set({ "x", "o" }, keys, function()
          select.select_textobject(capture, "textobjects")
        end, { desc = "Select " .. capture })
      end

      local move = require("nvim-treesitter-textobjects.move")
      for _, m in ipairs({
        { "]m", "goto_next_start", "@function.outer" },
        { "]]", "goto_next_start", "@class.outer" },
        { "]M", "goto_next_end", "@function.outer" },
        { "][", "goto_next_end", "@class.outer" },
        { "[m", "goto_previous_start", "@function.outer" },
        { "[[", "goto_previous_start", "@class.outer" },
        { "[M", "goto_previous_end", "@function.outer" },
        { "[]", "goto_previous_end", "@class.outer" },
      }) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function()
          move[m[2]](m[3], "textobjects")
        end, { desc = m[2]:gsub("_", " ") .. " " .. m[3] })
      end
    end,
  },
}
