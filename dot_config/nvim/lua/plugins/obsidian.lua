return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  priority = 1000,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "ObsidianNew",
    "ObsidianSearch",
    "ObsidianQuickSwitch",
    "ObsidianFollowLink",
    "ObsidianBacklinks",
    "ObsidianToday",
    "ObsidianTemplate",
    "ObsidianOpen",
    "ObsidianLinkNew",
    "ObsidianToggleCheckbox",
    "ObsidianRename",
    "ObsidianFollowLink",
    "ObsidianYesterday",
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "󱞂 New Obsidian note" },
    { "<leader>os", "<cmd>ObsidianQuickSwitch<CR>", desc = "󰤵 Find Obsidian note" },
    { "<leader>og", "<cmd>ObsidianSearch<CR>", desc = " Search in Obsidian vault" },
    { "<leader>of", "<cmd>ObsidianFollowLink<CR>", desc = "Follow Obsidian Note Link" },
    { "<leader>od", "<cmd>ObsidianToday<CR>", desc = " Open today's daily note" },
    { "<leader>oy", "<cmd>ObsidianYesterday<CR>", desc = " Open yesterday's daily note" },
    { "<leader>oo", "<cmd>ObsidianOpen<CR>", desc = " Open in Obsidian app" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Find backlinks" },
    { "<leader>ox", "<cmd>ObsidianToggleCheckbox<CR>", desc = "󰱑 Toggle checkbox" },
    { "<leader>or", "<cmd>ObsidianRename<CR>", desc = "Rename note" },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", desc = "Quick switch note" },
    { "<leader>ol", "<cmd>ObsidianLink<CR>", desc = "Create link" },
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = {
      {
        name = "work",
        path = "~/repos/DEVOPS/devops-obsidian/",
      },
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },

    notes_subdir = "Thomas/Notes",
    new_notes_location = "notes_subdir",

    note_id_func = function(title)
      if not title or title == "" then
        return tostring(os.time())
      end
      return title:gsub("[^A-Za-z0-9-]", "-"):gsub("%-+", "-"):gsub("^-+", ""):gsub("-+$", "")
    end,

    daily_notes = {
      folder = "Thomas/Daily Notes",
      date_format = "%a %b-%e",
    },
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        ["!"] = { char = "", hl_group = "ObsidianImportant" },
      },
      ignore_conceal_warn = true,
      bullets = { char = "-", hl_group = "ObsidianBullet" },
    },
    picker = {
      name = "snacks.pick",
    },
    preferred_link_style = "wiki",
  },
  checkbox = {
    order = { " ", "x", "~", "!", ">" },
  },
}
