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

-- Markdown task checkbox
vim.keymap.set("n", "<leader>o", function() end, { desc = "󰠮 Obsidian" })
vim.keymap.set("n", "<leader>ot", "i- [ ] <Esc>", { desc = "󰄬 Insert task checkbox", buffer = true })
vim.keymap.set("i", "<C-t>", "- [ ] ", { desc = "Insert task checkbox", buffer = true })
