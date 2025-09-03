return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic", -- or "basic" / "strict"
            },
          },
        },
      },
      jinja_lsp = {
        filetypes = { "jinja", "jinja2", "j2", "yaml.j2" },
        settings = {},
      },
    },
  },
}
