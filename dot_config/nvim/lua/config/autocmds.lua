-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "yaml" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local root = require("lazyvim.util").root.get()
    vim.fn.chdir(root)
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.j2",
  command = "set filetype=jinja",
})

-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "markdown" },
--   callback = function()
--     -- Set up keymaps for markdown files
--     -- The '<leader>m' group will be automatically created by which-key
--     vim.keymap.set("n", "<leader>", function() end, { desc = "Markdown" })
--     vim.keymap.set("n", "<leader>mt", "i- [ ] <Esc>", { desc = "Insert task checkbox", buffer = true })
--     vim.keymap.set("i", "<C-t>", "- [ ] ", { desc = "Insert task checkbox", buffer = true })
--   end,
-- })
