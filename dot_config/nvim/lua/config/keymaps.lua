-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Paste without losing text
vim.keymap.set("v", "p", '"_dP')
-- Exit Insert Mode
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc" })
-- View In Word Shortcut
vim.keymap.set("n", "vv", "viw", { desc = "View In Word" })
--- Cellular Automation
vim.keymap.set("n", "<leader>uml", "<cmd>CellularAutomaton make_it_rain<CR>")
vim.keymap.set("n", "<leader>umg", "<cmd>CellularAutomaton game_of_life<CR>")

-- Markdown task creation
vim.keymap.set("i", "<C-t>", "- [ ] ", { desc = "Insert markdown task" })
vim.keymap.set("n", "<leader>ot", "o- [ ] ", { desc = "Create new markdown task", silent = true })

-- Surrounding words with backticks
vim.keymap.set("n", "gs", 'ciw`<C-r>"`<Esc>', { noremap = true })

local M = {}

function M.open_dstask_split()
  -- open vertical split and make it e.g. 30 columns wide
  vim.cmd("vsplit")
  -- open terminal in this window, running dstask
  vim.cmd("terminal dstask")
  --    here we use bash -lc, but if you use zsh/fish just change it appropriately!
  local shell = os.getenv("SHELL") or "zsh"
  local cmd = string.format([[terminal %s -lc "dstask; exec %s"]], shell, shell)
  vim.cmd(cmd)
  -- enter terminal-mode
  vim.cmd("startinsert")
end

-- map it to <leader>d
vim.keymap.set("n", "<leader>N", M.open_dstask_split, { desc = "Open dstask in small vertical split" })
