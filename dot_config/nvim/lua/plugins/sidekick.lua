-- Override sidekick's opencode CLI launch to run through the Headroom proxy.
-- `headroom wrap opencode` starts the proxy (127.0.0.1:8787), injects
-- OPENCODE_CONFIG_CONTENT pointing providers at the proxy, and launches opencode.
-- `--copilot-subscription` reuses existing Copilot creds (VS Code apps.json /
-- keychain / env) so no blocked device-code login is needed.
return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      tools = {
        opencode = {
          cmd = { "headroom", "wrap", "opencode", "--copilot-subscription" },
        },
      },
    },
  },
}
