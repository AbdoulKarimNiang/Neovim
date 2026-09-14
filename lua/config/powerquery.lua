-- config/powerquery.lua - Power Query / M language server.
--
-- Not available from Mason or nvim-lspconfig. The server is the one shipped
-- inside Microsoft's VS Code extension (github.com/microsoft/vscode-powerquery,
-- MIT): server/dist/server.js. It calls createConnection() with no arguments,
-- so vscode-languageserver takes the transport from the command line and
-- `node server.js --stdio` works outside VS Code.
--
-- Two details it needs, each of which made completion come back empty:
--   * languageId "powerquery" - it ignores documents opened as "pq", which is
--     the filetype pq-syntax assigns;
--   * a "powerquery" settings section, answered to workspace/configuration.
--
-- :PowerQueryUpdate downloads the latest extension and extracts the server.
-- Opening a Power Query file with the server missing does that automatically.

local M = {}

local root = vim.fs.joinpath(vim.fn.stdpath("data"), "powerquery-ls")
local server_js = vim.fs.joinpath(root, "extension", "server", "dist", "server.js")
local vsix_url =
  "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/PowerQuery/vsextensions/vscode-powerquery/latest/vspackage"

-- pq-syntax maps .dax to the same "pq" filetype, but DAX is a different
-- language; the M server would report every DAX expression as an error.
local skip_extensions = { dax = true }

local function installed_version()
  local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(root, "extension", "package.json"))
  if not ok then
    return nil
  end
  return table.concat(lines, "\n"):match('"version"%s*:%s*"([^"]+)"')
end

local function notify(msg, level)
  vim.notify("PowerQuery: " .. msg, level or vim.log.levels.INFO)
end

--- Download the extension package and extract the server, asynchronously.
--- vim.system() runs its exit callback in a fast event context, where Vimscript
--- functions (vim.fn.*, vim.env) raise E5560 - so everything that needs them is
--- computed up front, and the callbacks are scheduled onto the main loop.
---@param on_done? fun(ok: boolean)
function M.install(on_done)
  on_done = on_done or function() end
  vim.fn.mkdir(root, "p")
  local vsix = vim.fs.joinpath(root, "vscode-powerquery.vsix")
  -- A .vsix is a zip. On Windows the `tar` on PATH is often Git's GNU tar,
  -- which cannot read zip archives; the bsdtar in System32 can.
  local extract = vim.fn.has("win32") == 1
      and {
        vim.fs.joinpath(vim.env.SystemRoot or "C:/Windows", "System32", "tar.exe"),
        "-xf",
        vsix,
        "-C",
        root,
        "extension/package.json",
        "extension/server/dist",
      }
    or { "unzip", "-o", "-q", vsix, "extension/package.json", "extension/server/dist/*", "-d", root }

  notify("downloading language server...")
  vim.system(
    { "curl", "-sSfL", "--compressed", "-o", vsix, vsix_url },
    {},
    vim.schedule_wrap(function(dl)
      if dl.code ~= 0 then
        notify("download failed: " .. vim.trim(dl.stderr or ""), vim.log.levels.ERROR)
        return on_done(false)
      end
      vim.system(
        extract,
        {},
        vim.schedule_wrap(function(ex)
          local ok = ex.code == 0 and vim.uv.fs_stat(server_js) ~= nil
          if ok then
            notify("language server " .. (installed_version() or "?") .. " installed")
          else
            notify("extraction failed: " .. vim.trim(ex.stderr or ""), vim.log.levels.ERROR)
          end
          on_done(ok)
        end)
      )
    end)
  )
end

function M.setup()
  vim.lsp.config("powerquery_ls", {
    cmd = { "node", server_js, "--stdio" },
    filetypes = { "pq" },
    get_language_id = function()
      return "powerquery"
    end,
    root_dir = function(bufnr, on_dir)
      local name = vim.api.nvim_buf_get_name(bufnr)
      if skip_extensions[(vim.fn.fnamemodify(name, ":e")):lower()] then
        return
      end
      on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fs.dirname(name))
    end,
    -- Defaults copied from the extension's package.json.
    settings = {
      powerquery = {
        general = { locale = "en-US", mode = "Power Query", experimental = false },
        diagnostics = { isWorkspaceCacheAllowed = true, typeStrategy = "Primitive" },
        timeout = { symbolTimeoutInMs = 2000 },
        benchmark = { enable = false },
      },
    },
  })

  local function enable()
    vim.lsp.enable("powerquery_ls")
    -- vim.lsp.enable() attaches to already-open buffers only once startup has
    -- finished (it checks v:vim_did_enter / did_filetype()). An install that
    -- completes earlier would leave the file that triggered it unattached, so
    -- re-run just Neovim's LSP FileType handler for open Power Query buffers.
    -- Scoped to that group, so ftplugins do not run again.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "pq" then
        pcall(vim.api.nvim_exec_autocmds, "FileType", { group = "nvim.lsp.enable", buffer = buf })
      end
    end
  end

  vim.api.nvim_create_user_command("PowerQueryUpdate", function()
    M.install(function(ok)
      if ok then
        enable()
      end
    end)
  end, { desc = "Download or refresh the Power Query language server" })

  if vim.uv.fs_stat(server_js) then
    enable()
    return
  end

  -- Not installed yet: fetch it the first time a Power Query file is opened.
  -- vim.lsp.enable() then attaches to the buffers that are already open.
  local installing = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "pq",
    group = vim.api.nvim_create_augroup("powerquery-install", { clear = true }),
    callback = function(event)
      local ext = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ":e"):lower()
      if installing or skip_extensions[ext] or vim.uv.fs_stat(server_js) then
        return
      end
      installing = true
      M.install(function(ok)
        installing = false
        if ok then
          enable()
        end
      end)
    end,
  })
end

return M
