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
    },
  },
}
