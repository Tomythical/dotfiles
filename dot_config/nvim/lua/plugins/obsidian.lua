return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  priority = 1000,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "Obsidian new",
    "Obsidian search",
    "Obsidian quick_switch",
    "Obsidian follow_link",
    "Obsidian backlinks",
    "Obsidian today",
    "Obsidian template",
    "Obsidian open",
    "Obsidian link_new",
    "Obsidian toggle_checkbox",
    "Obsidian rename",
    "Obsidian follow_link",
    "Obsidian yesterday",
  },
  keys = {
    { "<leader>on", "<cmd>Obsidian new<CR>", desc = "󱞂 New Obsidian note" },
    { "<leader>os", "<cmd>Obsidian quick_switch<CR>", desc = "󰤵 Find Obsidian note" },
    { "<leader>og", "<cmd>Obsidian search<CR>", desc = " Search in Obsidian vault" },
    { "<leader>of", "<cmd>Obsidian follow_link<CR>", desc = "Follow Obsidian Note Link" },
    { "<leader>od", "<cmd>Obsidian today<CR>", desc = " Open today's daily note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<CR>", desc = " Open yesterday's daily note" },
    { "<leader>oo", "<cmd>Obsidian open<CR>", desc = " Open in Obsidian app" },
    { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Find backlinks" },
    { "<leader>ox", "<cmd>Obsidian toggle_checkbox<CR>", desc = "󰱑 Toggle checkbox" },
    { "<leader>or", "<cmd>Obsidian rename<CR>", desc = "Rename note" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<CR>", desc = "Quick switch note" },
    { "<leader>ol", "<cmd>Obsidian link_new<CR>", desc = "Create link" },
  },
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
    -- checkboxes = {
    --   ["x"] = { char = "✔", hl_group = "ObsidianDone" },
    --   [" "] = { char = "☐", hl_group = "ObsidianTodo" },
    --   [">"] = { char = ">", hl_group = "ObsidianRightArrow" },
    --   ["-"] = { char = "-", hl_group = "ObsidianCanceled" },
    --   ["!"] = { char = "󱈸", hl_group = "ObsidianImportant" },
    -- },
    ui = {
      enable = false,
      ignore_conceal_warn = true,
      bullets = { char = "-", hl_group = "ObsidianBullet" },
    },
    picker = {
      name = "snacks.pick",
    },
    preferred_link_style = "wiki",
    checkbox = {
      order = { " ", "x", "~", "!" },
    },
  },
}
