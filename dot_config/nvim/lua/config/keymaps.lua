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

-- local M = {}
--
-- function M.open_dstask_split()
--   -- open vertical split and make it e.g. 30 columns wide
--   vim.cmd("vsplit")
--   -- open terminal in this window, running dstask
--   vim.cmd("terminal dstask")
--   -- enter terminal-mode
--   vim.cmd("startinsert")
-- end

local snacks = require("snacks")
local M = {}

function M.dstask_edit_snacks()
  local lines = vim.fn.systemlist("dstask --format '{{id}}\t{{summary}}'")
  if vim.v.shell_error ~= 0 or #lines == 0 then
    vim.notify("No tasks found or dstask error", vim.log.levels.ERROR)
    return
  end

  -- build items for snacks: { label = "ID: Summary", value = ID }
  local items = vim.tbl_map(function(line)
    local id, summary = line:match("^(%S+)\t(.+)$")
    return { label = id .. ": " .. summary, value = id }
  end, lines)

  snacks.picker({
    prompt = "Edit dstask > ",
    items = items,
    on_select = function(item)
      vim.cmd("vsplit | vertical resize 40")
      local shell = os.getenv("SHELL") or "bash"
      vim.cmd(string.format([[terminal %s -lc "dstask edit %s; exec %s"]], shell, item.value, shell))
      vim.cmd("startinsert")
    end,
  })
end

vim.keymap.set("n", "<leader>e", M.dstask_edit_snacks, {
  desc = "Pick dstask task to edit (Snacks)",
})
