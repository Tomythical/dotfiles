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

local has_snacks, snacks = pcall(require, "snacks")
if not has_snacks then
  vim.notify("snacks.nvim is required for dstask picker", vim.log.levels.ERROR)
  return
end
local M = {}

--- Parse `dstask` output -> use snacks.picker -> open VS split to edit
function M.dstask_edit_snacks()
  local raw = vim.fn.systemlist("dstask")
  if vim.v.shell_error ~= 0 or #raw <= 1 then
    vim.notify("`dstask` returned no tasks or errored", vim.log.levels.ERROR)
    return
  end

  local items = {}
  for i = 2, #raw do
    local line = raw[i]
    local parts = vim.split(line, "%s%s+")
    if #parts >= 4 then
      local id = parts[1]
      local summary = table.concat(vim.list_slice(parts, 4, #parts), "  ")
      table.insert(items, {
        label = id .. ": " .. summary,
        value = id,
      })
    end
  end

  if vim.tbl_isempty(items) then
    vim.notify("No tasks found", vim.log.levels.ERROR)
    return
  end

  snacks.picker.pick({
    prompt = "dstask: edit > ",
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
  desc = "Pick dstask task to edit (snacks.nvim)",
})
