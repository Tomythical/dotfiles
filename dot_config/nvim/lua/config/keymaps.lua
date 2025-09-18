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

-- lua/custom/dstask.lua
local M = {}
local ok, Job = pcall(require, "plenary.job")
if not ok then
  vim.notify("plenary.job required for dstask integration", vim.log.levels.ERROR)
  return M
end

local LIST_CMD = "dstask show --json" -- adjust if your dstask CLI differs
local SIDE_WIDTH_PCT = 0.35

local function open_side_terminal(id)
  if not id or id == "" then
    return
  end
  local width = math.floor(vim.o.columns * SIDE_WIDTH_PCT)
  vim.cmd("vsplit")
  vim.cmd("vertical resize " .. width)
  vim.cmd("terminal dstask note " .. vim.fn.shellescape(tostring(id)))
  vim.cmd("startinsert")
end

local function build_items_from_json(json_str)
  local ok, parsed = pcall(vim.fn.json_decode, json_str)
  if not ok or type(parsed) ~= "table" then
    return nil, "failed to parse dstask json"
  end
  local items = {}
  for _, task in ipairs(parsed) do
    local id = task.id or task.uuid or ""
    local summary = task.summary or ("[" .. tostring(id) .. "]")
    table.insert(items, { id = id, label = tostring(summary) })
  end
  return items
end

function M.pick()
  Job:new({
    command = "bash",
    args = { "-lc", LIST_CMD },
    on_exit = vim.schedule_wrap(function(j)
      local lines = j:result()
      if not lines or vim.tbl_isempty(lines) then
        vim.notify("No dstask output", vim.log.levels.INFO)
        return
      end
      local json = table.concat(lines, "\n")
      local items, err = build_items_from_json(json)
      if not items then
        vim.notify("dstask json parse error: " .. (err or "unknown"), vim.log.levels.ERROR)
        return
      end

      local snacks_ok, snacks = pcall(require, "snacks")
      if snacks_ok and type(snacks.picker) == "function" then
        snacks.picker({
          prompt = "dstask",
          items = items,
          get_label = function(it)
            return it.label
          end,
          on_choice = function(choice)
            local id
            if type(choice) == "number" then
              id = items[choice] and items[choice].id
            elseif type(choice) == "table" then
              id = choice.id
            elseif type(choice) == "string" then
              for _, it in ipairs(items) do
                if it.label == choice then
                  id = it.id
                  break
                end
              end
            end
            if id then
              open_side_terminal(id)
            end
          end,
        })
        return
      end

      -- fallback to vim.ui.select
      local labels = vim.tbl_map(function(it)
        return it.label
      end, items)
      vim.ui.select(labels, { prompt = "dstask" }, function(choice)
        if not choice then
          return
        end
        for _, it in ipairs(items) do
          if it.label == choice then
            open_side_terminal(it.id)
            return
          end
        end
      end)
    end),
  }):start()
end

vim.keymap.set("n", "<leader>T", function()
  M.pick()
end, { desc = "dstask: pick task and edit note" })
