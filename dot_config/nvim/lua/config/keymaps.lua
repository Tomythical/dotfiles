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
  -- enter terminal-mode
  vim.cmd("startinsert")
end

local N = {}

-- open a horizontal split and run `dstask note <ID>`
function N.open_dstask_note()
  -- 1. ask for the task ID
  local task_id = vim.fn.input("DSTask note for ID: ")
  if task_id == "" then
    print("Aborted: no ID given")
    return
  end

  -- 2. split & resize to e.g. 10 lines tall
  vim.cmd("split")

  -- 3. launch your shell to run dstask note and then stay at a prompt
  local cmd = string.format("terminal dstask note %s", task_id)
  vim.cmd(cmd)

  -- 4. enter insert mode in the terminal
  vim.cmd("startinsert")
end

-- map it to <leader>d
vim.keymap.set("n", "<leader>N", M.open_dstask_split, { desc = "Open dstask in small vertical split" })
-- map it to <leader>n
vim.keymap.set("n", "<leader>n", N.open_dstask_note, { desc = "Open horizontal dstask note terminal" })
