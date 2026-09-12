-- config/keymaps.lua - Key mappings

local keymap = vim.keymap.set

-- Clear search highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save file
keymap("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Quit
keymap("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Navigate buffers
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Keep cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- Split windows
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Terminal
keymap("n", "<leader>tt", "<cmd>terminal<CR>", { desc = "Open terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Quick fix list
keymap("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix list" })
keymap("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap("n", "<leader>qn", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
keymap("n", "<leader>qp", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })

-- Location list
keymap("n", "<leader>lo", "<cmd>lopen<CR>", { desc = "Open location list" })
keymap("n", "<leader>lc", "<cmd>lclose<CR>", { desc = "Close location list" })
keymap("n", "<leader>ln", "<cmd>lnext<CR>", { desc = "Next location item" })
keymap("n", "<leader>lp", "<cmd>lprev<CR>", { desc = "Previous location item" })

-- Diagnostic keymaps
-- vim.diagnostic.goto_prev/goto_next are deprecated since 0.11 and scheduled
-- for removal in 0.13; vim.diagnostic.jump() replaces both.
keymap("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })
keymap("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic message" })
keymap("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- File manager keymaps (Yazi)
keymap("n", "<C-n>", "<cmd>Yazi<cr>", { desc = "Toggle Yazi file manager", silent = true })

-- Alternative file explorer mappings
keymap("n", "<leader>fe", "<cmd>Yazi<cr>", { desc = "File explorer (Yazi)", silent = true })
keymap("n", "<leader>fE", "<cmd>Yazi cwd<cr>", { desc = "File explorer at cwd", silent = true })

-- Open yazi with visual selection (useful for opening specific paths)
keymap("x", "<leader>e", "<cmd>Yazi<cr>", { desc = "Open yazi with selection", silent = true })

-- Quick directory navigation
keymap("n", "<leader>cd", function()
  vim.cmd("Yazi " .. vim.fn.expand("%:p:h"))
end, { desc = "Open yazi in current file directory", silent = true })

-- Project root navigation (if you have a root finder function)
keymap("n", "<leader>pr", function()
  local root = vim.fs.find({ ".git", "package.json", "Cargo.toml", "pyproject.toml" }, { upward = true })[1]
  if root then
    local project_root = vim.fn.fnamemodify(root, ":h")
    vim.cmd("Yazi " .. project_root)
  else
    vim.cmd("Yazi cwd")
  end
end, { desc = "Open yazi at project root", silent = true })

-- Molten (Jupyter) keymaps
keymap("n", "<leader>mi", "<cmd>MoltenInit<CR>", { desc = "Initialize Molten" })
keymap("n", "<leader>me", "<cmd>MoltenEvaluateOperator<CR>", { desc = "Evaluate operator" })
keymap("n", "<leader>ml", "<cmd>MoltenEvaluateLine<CR>", { desc = "Evaluate line" })
keymap("n", "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", { desc = "Re-evaluate cell" })
keymap("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Evaluate visual selection" })
keymap("n", "<leader>mh", "<cmd>MoltenHideOutput<CR>", { desc = "Hide output" })
keymap("n", "<leader>ms", "<cmd>MoltenShowOutput<CR>", { desc = "Show output" })
keymap("n", "<leader>md", "<cmd>MoltenDelete<CR>", { desc = "Delete Molten cell" })
keymap("n", "<leader>mo", "<cmd>MoltenOpenInBrowser<CR>", { desc = "Open in browser" })

-- Folding keymaps (works for JSON, code, etc.)
keymap("n", "za", "za", { desc = "Toggle fold" })
keymap("n", "zA", "zA", { desc = "Toggle fold recursively" })
keymap("n", "zo", "zo", { desc = "Open fold" })
keymap("n", "zc", "zc", { desc = "Close fold" })
keymap("n", "zR", "zR", { desc = "Open all folds" })
keymap("n", "zM", "zM", { desc = "Close all folds" })
keymap("n", "zr", "zr", { desc = "Reduce fold level" })
keymap("n", "zm", "zm", { desc = "Increase fold level" })

-- JSON specific keymaps
keymap("n", "<leader>jf", "<cmd>%!jq .<CR>", { desc = "Format JSON with jq" })
keymap("n", "<leader>jc", "<cmd>%!jq -c .<CR>", { desc = "Compact JSON" })
