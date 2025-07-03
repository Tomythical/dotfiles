return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ["python"] = {
          "ruff_format",
        },
        ["terraform"] = { "terraform_fmt" },
        ["yaml"] = { "yamlfix" },
        -- ["markdown"] = { "mdformat" },
        ["markdown"] = {},
      },
      formatters = {
        ruff_format = {
          prepend_args = {},
        },
      },
    },
  },
}
