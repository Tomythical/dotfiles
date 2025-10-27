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
-- lua/custom/dstask.lua
local M = {}
local has_job, Job = pcall(require, "plenary.job")
if not has_job then
  vim.notify("plenary.job required for dstask integration", vim.log.levels.ERROR)
  return M
end

local LIST_CMD = "dstask show-active --"
local SIDE_WIDTH_PCT = 0.35

local function ensure_priority_highlights()
  pcall(vim.api.nvim_set_hl, 0, "DSTaskPriorityP1", { fg = "#ff6b6b", bold = true })
  pcall(vim.api.nvim_set_hl, 0, "DSTaskPriorityP2", { fg = "#ffb86b", bold = true })
  pcall(vim.api.nvim_set_hl, 0, "DSTaskPriorityP3", { fg = "#8be9fd", bold = false })
end

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

local function try_decode_json(s)
  if not s or s == "" then
    return nil
  end
  local ok, parsed = pcall(vim.fn.json_decode, s)
  if ok and type(parsed) == "table" then
    return parsed
  end
  local s_i, e_i = s:find("%[.*%]", 1)
  if s_i and e_i then
    ok, parsed = pcall(vim.fn.json_decode, s:sub(s_i, e_i))
    if ok and type(parsed) == "table" then
      return parsed
    end
  end
  return nil
end

-- ensure text & value are strings to satisfy snacks matcher
local function build_items_from_json(json_str)
  local parsed = try_decode_json(json_str)
  if not parsed then
    return nil, "failed to parse json"
  end
  local items = {}
  for _, task in ipairs(parsed) do
    local id = tostring(task.id or task.uuid or "")
    local summary = tostring(task.summary or "")
    local project = (task.project and task.project ~= "") and tostring(task.project) or nil
    local priority = (task.priority and task.priority ~= "") and tostring(task.priority) or nil

    local parts = {}
    if priority then
      table.insert(parts, "[" .. priority .. "]")
    end
    if project then
      table.insert(parts, "(" .. project .. ")")
    end
    table.insert(parts, summary)
    local label = table.concat(parts, " "):gsub("%s+$", "")

    -- minimal canonical item shape for snacks matcher and format
    table.insert(items, {
      id = id,
      value = id, -- used by matcher / preview
      text = (label ~= "" and label) or summary or id, -- REQUIRED string for matcher
      label = label, -- used in format display
      summary = summary,
      project = project,
      priority = priority,
      raw = task,
    })
  end
  return items
end

-- async preview helper using ctx.preview:set_lines(...)
local function preview_note_async(ctx, id)
  if not ctx or not ctx.preview then
    return
  end
  if not id or id == "" then
    pcall(function()
      ctx.preview:set_lines({ "(no id)" })
    end)
    return
  end

  -- highlight preview buffer (optional)
  pcall(function()
    ctx.preview:highlight({ ft = "markdown" })
  end)

  -- cancel running process
  if ctx.preview.state and ctx.preview.state.process then
    pcall(function()
      ctx.preview.state.process:kill(9)
    end)
  end

  ctx.preview.state = ctx.preview.state or {}
  ctx.preview.state.process = vim.system({ "dstask", "note", tostring(id) }, { text = true }, function(res)
    local lines
    if res and res.code == 0 then
      lines = vim.split((res.stdout or ""):gsub("\r", ""), "\n", { plain = true })
      if #lines == 0 then
        lines = { "(empty note)" }
      end
    else
      local err = (res and res.stderr ~= "" and res.stderr) or ("exit:" .. tostring(res and res.code or "nil"))
      lines = { "Unable to fetch note:", err }
    end
    vim.schedule(function()
      pcall(function()
        ctx.preview:set_lines(lines)
      end)
    end)
  end)
end

-- attempt common snacks.picker invocation shapes with format + preview + confirm
local function try_snacks_picker_with_preview(items)
  local ok, picker_mod = pcall(require, "snacks.picker")
  if not ok or not picker_mod then
    return false
  end

  local function format_fn(item)
    local label = tostring((item and (item.label or item.text)) or "")
    local pr = item and item.priority or nil
    local hl = (pr and ("DSTaskPriority" .. pr)) or nil
    -- return rows; each row may be a string or { text, hl_group }
    return { { label, hl } }
  end

  local function preview_fn(ctx)
    local item = nil
    pcall(function()
      item = ctx.item or (ctx.current and ctx.current({ fallback = true }))
    end)
    if not item then
      pcall(function()
        ctx.preview:set_lines({ "(no selection)" })
      end)
      return
    end
    local id = tostring(item.value or item.id or item.text or "")
    preview_note_async(ctx, id)
  end

  local function confirm_fn(picker, item)
    pcall(function()
      picker:close()
    end)
    local id = tostring((item and (item.value or item.id or item.text)) or "")
    if id ~= "" then
      open_side_terminal(id)
    end
  end

  local opts = {
    title = "dstask",
    items = items,
    format = format_fn,
    preview = preview_fn,
    confirm = confirm_fn,
  }

  local callers = {
    function()
      return picker_mod.pick(nil, opts)
    end,
    function()
      return picker_mod.pick(opts)
    end,
    function()
      return picker_mod(nil, opts)
    end,
    function()
      return picker_mod(opts)
    end,
  }

  for _, call in ipairs(callers) do
    local ok2 = pcall(call)
    if ok2 then
      return true
    end
  end

  return false
end

function M.pick()
  Job:new({
    command = "bash",
    args = { "-lc", LIST_CMD .. " 2>&1" },
    on_exit = vim.schedule_wrap(function(job)
      local out_lines = job:result() or {}
      local out = table.concat(out_lines, "\n")
      if out == "" then
        vim.notify("dstask next returned no output", vim.log.levels.INFO)
        return
      end

      local items, err = build_items_from_json(out)
      if not items then
        vim.notify("dstask json parse error: " .. (err or "unknown"), vim.log.levels.ERROR)
        -- show raw output for debugging
        vim.cmd("split | enew | setlocal buftype=nofile bufhidden=wipe noswapfile")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out, "\n"))
        vim.bo.filetype = "json"
        return
      end

      if vim.tbl_isempty(items) then
        vim.notify("no tasks parsed", vim.log.levels.INFO)
        return
      end

      ensure_priority_highlights()

      local used = try_snacks_picker_with_preview(items)
      if used then
        return
      end

      -- fallback: vim.ui.select (no preview / no hl)
      local labels = vim.tbl_map(function(it)
        return it.text
      end, items)
      vim.ui.select(labels, { prompt = "dstask" }, function(choice)
        if not choice then
          return
        end
        for _, it in ipairs(items) do
          if it.text == choice then
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

return M
