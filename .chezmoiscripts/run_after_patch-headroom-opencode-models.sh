#!/usr/bin/env bash
# run_after_patch-headroom-opencode-models.sh
#
# WHY THIS EXISTS
# ----------------
# `headroom wrap opencode --copilot-subscription` injects an opencode provider
# named `headroom` whose model list comes from a hardcoded dict,
# HEADROOM_OPENCODE_MODELS, in the installed headroom-ai package:
#   .../headroom/providers/opencode/config.py
#
# Upstream ships DASHED model IDs (e.g. "claude-opus-4-6"). Those route through
# the proxy to api.githubcopilot.com, whose catalog uses DOTTED IDs
# ("claude-opus-4.6"), so Copilot returns HTTP 400 "requested model is not
# supported". We patch the dict to dotted IDs.
#
# The patch lives inside a uv-managed tool install, so `uv tool upgrade
# headroom-ai` (or a reinstall) reverts it. This script re-applies the patch
# idempotently on every `chezmoi apply`. It is a no-op once the file already
# contains the dotted IDs.
#
# FAILURE MODES
#   * Package path not found (headroom not installed / different layout):
#     script logs and exits 0 (do not block chezmoi apply).
#   * Upstream restructures the dict: the anchored replace no longer matches;
#     script logs a warning and exits 0 so apply still succeeds. Re-verify by
#     running the smoke test in the header of the printed message.
set -euo pipefail

log() { printf 'run_after headroom-models: %s\n' "$*" >&2; }

# Resolve the config.py inside the uv tool install. The python3.NN dir changes
# across interpreter upgrades, so glob it instead of hardcoding python3.13.
shopt -s nullglob
candidates=(
  "$HOME/.local/share/uv/tools/headroom-ai"/lib/python3.*/site-packages/headroom/providers/opencode/config.py
)
shopt -u nullglob

if (( ${#candidates[@]} == 0 )); then
  log "headroom-ai config.py not found; nothing to patch (ok)."
  exit 0
fi

target="${candidates[0]}"

# The Python step below is itself idempotent: it rewrites the dict block to a
# canonical dotted form and only writes if bytes actually change. No separate
# bash grep guard (a prose mention of a dashed ID in comments would defeat it).
python3 - "$target" <<'PY'
import re
import sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()

new_block = '''HEADROOM_OPENCODE_MODELS: dict[str, Any] = {
    "claude-sonnet-4.6": {
        "name": "Claude Sonnet 4.6",
        "limit": {"context": 200000, "output": 16384},
    },
    "claude-opus-4.6": {
        "name": "Claude Opus 4.6",
        "limit": {"context": 200000, "output": 16384},
    },
    "claude-opus-4.8": {
        "name": "Claude Opus 4.8",
        "limit": {"context": 200000, "output": 16384},
    },
    "gpt-4o": {
        "name": "GPT-4o",
        "limit": {"context": 128000, "output": 16384},
    },
    "gpt-4.1": {
        "name": "GPT-4.1",
        "limit": {"context": 1048576, "output": 32768},
    },
}'''

# Match the assignment through the first line that is exactly "}" at column 0.
pattern = re.compile(
    r"^HEADROOM_OPENCODE_MODELS\s*:\s*dict\[str,\s*Any\]\s*=\s*\{.*?^\}",
    re.DOTALL | re.MULTILINE,
)

if not pattern.search(src):
    sys.stderr.write(
        "run_after headroom-models: HEADROOM_OPENCODE_MODELS block not found; "
        "upstream layout may have changed. Leaving file untouched.\n"
    )
    # Exit 0: never block chezmoi apply on an upstream refactor.
    sys.exit(0)

patched = pattern.sub(new_block, src, count=1)
if patched != src:
    open(path, "w", encoding="utf-8").write(patched)
    sys.stderr.write("run_after headroom-models: patch written.\n")
else:
    sys.stderr.write("run_after headroom-models: no change needed.\n")
PY

log "done."
