return {
  "linux-cultist/venv-selector.nvim",
  cmd = "VenvSelect",
  enabled = function()
    -- safe check: returns true only if telescope can be required
    return pcall(require, "telescope")
  end,
  opts = {
    settings = {
      options = {
        notify_user_on_venv_activation = true,
      },
    },
  },
  -- Call config for python files and load the cached venv automatically
  ft = "python",
  keys = {
    { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", mode = "n" },
  },
}

