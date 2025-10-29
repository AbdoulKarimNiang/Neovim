return {
  {
    "jgrocho/pq-neovim-syntax-files",
    ft = { "pq", "powerquery", "pqm", "dax", "mquery" },
    config = function()
      -- The plugin will handle filetype detection automatically
      -- Just ensure we use 'pq' as the primary filetype
      vim.filetype.add({
        extension = {
          pq = "pq",
          pqm = "pq",
          dax = "pq",
          mquery = "pq",
        },
      })
    end,
  },
}
