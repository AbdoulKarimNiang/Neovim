-- lua/plugins/lsp.lua - language servers for the languages actually used here:
-- PowerShell, Python, Rust, Lua, JavaScript/TypeScript, Zig (+ json/yaml/toml).
--
-- Neovim 0.11 ships the LSP framework natively, and nvim-lspconfig now ships
-- plain data files under lsp/. So servers are configured with vim.lsp.config()
-- and turned on with vim.lsp.enable() - the old lspconfig[server].setup{} entry
-- point is not used.
return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "v", package_pending = ">", package_uninstalled = "x" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      -- JSON/YAML schema catalogue: without it yamlls and jsonls parse the
      -- file but have no idea what the keys are supposed to be.
      "b0o/SchemaStore.nvim",
    },
    config = function()
      local mason_root = vim.fn.stdpath("data") .. "/mason"

      -- Advertise nvim-cmp's extra client capabilities to every server.
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Per-server overrides. Anything not listed here uses the defaults that
      -- nvim-lspconfig ships in its lsp/<name>.lua.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              -- Make the Neovim runtime visible so editing this config gets
              -- completion and diagnostics for vim.* APIs.
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              -- ruff owns import organisation and lint; avoid duplicate hints.
              diagnosticSeverityOverrides = { reportUnusedImport = "none" },
            },
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { allFeatures = true },
          },
        },
      })

      -- powershell_es needs an explicit cmd here for two reasons:
      --  1. it locates PowerShellEditorServices through $env:PSModulePath, and
      --     Mason installs it outside that path;
      --  2. the cmd nvim-lspconfig ships passes "-LogLevel Information", which
      --     the PSES build Mason vendors rejects - its ValidateSet is
      --     Diagnostic,Verbose,Normal,Warning,Error - so the server exits 1.
      local pses = mason_root .. "/packages/powershell-editor-services"
      local pses_cache = vim.fn.stdpath("cache")
      vim.lsp.config("powershell_es", {
        cmd = {
          "pwsh",
          "-NoLogo",
          "-NoProfile",
          "-Command",
          ("& '%s/PowerShellEditorServices/Start-EditorServices.ps1' -BundledModulesPath '%s' "):format(pses, pses)
            .. ("-LogPath '%s/powershell_es.log' -SessionDetailsPath '%s/powershell_es.session.json' "):format(
              pses_cache,
              pses_cache
            )
            .. "-FeatureFlags @() -AdditionalModules @() -HostName nvim -HostProfileId 0 "
            .. "-HostVersion 1.0.0 -Stdio -LogLevel Normal",
        },
        settings = { powershell = { codeFormatting = { Preset = "OTBS" } } },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
            -- Use the catalogue bundled by SchemaStore.nvim rather than having
            -- the server fetch its own at startup.
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas({
              extra = {
                {
                  name = "Kubernetes",
                  description = "Kubernetes manifest",
                  -- "kubernetes" is a keyword yaml-language-server resolves
                  -- against its bundled k8s schemas, not a URL.
                  url = "kubernetes",
                  fileMatch = {
                    "k8s/**/*.yaml",
                    "k8s/**/*.yml",
                    "manifests/**/*.yaml",
                    "manifests/**/*.yml",
                    "*.k8s.yaml",
                    "deploy*.yaml",
                    "deployment*.yaml",
                    "service*.yaml",
                    "ingress*.yaml",
                    "configmap*.yaml",
                    "statefulset*.yaml",
                    "daemonset*.yaml",
                  },
                },
              },
            }),
          },
        },
      })

      local servers = {
        "lua_ls",
        "pyright",
        "ruff",
        "rust_analyzer",
        "ts_ls",
        "zls",
        "powershell_es",
        "jsonls",
        "yamlls",
        "taplo",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        -- Enable explicitly below rather than letting mason-lspconfig do it,
        -- so the enabled set is visible in this file.
        automatic_enable = false,
      })

      vim.lsp.enable(servers)

      -- Buffer-local keymaps, bound only once a server actually attaches.
      -- Prefixes line up with the which-key groups: c=Code, r=Rename, w=Workspace, d=Document.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gi", vim.lsp.buf.implementation, "Goto implementation")
          map("gy", vim.lsp.buf.type_definition, "Goto type definition")
          map("K", vim.lsp.buf.hover, "Hover documentation")

          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          -- <leader>cf is owned by conform.nvim.

          map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
          map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
          map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
          map("<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "List workspace folders")

          -- Highlight other references to the symbol under the cursor.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = { spacing = 2, source = "if_many" },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "\u{f0159} ",
            [vim.diagnostic.severity.WARN] = "\u{f0026} ",
            [vim.diagnostic.severity.INFO] = "\u{f02fd} ",
            [vim.diagnostic.severity.HINT] = "\u{f0335} ",
          },
        } or true,
      })
    end,
  },
}
