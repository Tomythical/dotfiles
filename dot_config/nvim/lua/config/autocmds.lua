-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "yaml" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function(event)
    local title = "vim"
    if event.file ~= "" then
      title = string.format("vim: %s", vim.fs.basename(event.file))
    end

    vim.fn.system({ "wezterm", "cli", "set-tab-title", title })
  end,
})
