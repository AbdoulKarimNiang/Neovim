-- config/filetypes.lua - filetype routing Neovim does not do on its own.
--
-- Both rules exist so the right language server attaches. Without them a Helm
-- template and a compose file are both just "yaml", which means helm_ls and
-- docker_compose_language_service never start, and yamlls reports the Go
-- templating in a chart as invalid YAML.

--- Walk up from a Helm template looking for the Chart.yaml that defines it.
--- Guards against treating any directory called templates/ as a Helm chart.
---@param path string
---@return boolean
local function in_helm_chart(path)
  local dir = vim.fs.dirname(path)
  for _ = 1, 5 do
    if dir == nil or dir == "" then
      return false
    end
    if vim.uv.fs_stat(dir .. "/Chart.yaml") then
      return true
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      return false
    end
    dir = parent
  end
  return false
end

vim.filetype.add({
  pattern = {
    -- Helm chart templates: only when a Chart.yaml sits above them.
    [".*/templates/.*%.ya?ml"] = function(path)
      return in_helm_chart(path) and "helm" or nil
    end,
    [".*/templates/.*%.tpl"] = function(path)
      return in_helm_chart(path) and "helm" or nil
    end,
    -- Compose files. The dotted filetype keeps every yaml ftplugin, syntax and
    -- schema behaviour and simply adds the compose server on top.
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    ["compose.*%.ya?ml"] = "yaml.docker-compose",
  },
})
