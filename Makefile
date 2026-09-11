.PHONY: help setup xcode-clt brew stow jaynalerts context-mode agentmemory litellm restart-litellm pi codex tmux-plugins verify-symlinks

# Private repo under the jaynlabs org, so SSH (HTTPS would need a PAT anyway).
# A fresh Mac therefore needs its key on GitHub before `make setup` reaches here.
JAYNALERTS_REPO ?= git@github.com:jaynlabs/jaynalerts.git
JAYNALERTS_DIR  ?= $(HOME)/src/jaynalerts
STOW_PACKAGES   ?= clang-format claude codex conda hammerspoon karabiner litellm nvim opencode pdb pi rich ssh tmux tmuxp zsh

# /opt/homebrew on Apple Silicon, /usr/local on Intel.
BREW_PREFIX     ?= $(shell brew --prefix 2>/dev/null || echo /opt/homebrew)
# launchd jobs inherit almost nothing, so the plists carry an explicit PATH.
LAUNCHD_PATH    ?= $(HOME)/.local/bin:$(BREW_PREFIX)/bin:/usr/local/bin:/usr/bin:/bin

help:
	@echo "Targets:"
	@echo "  setup            Run xcode-clt, brew, stow, jaynalerts, context-mode, tmux-plugins"
	@echo "  xcode-clt        Install Xcode Command Line Tools (provides swiftc) if missing"
	@echo "  brew             Symlink .Brewfile and run brew bundle --global"
	@echo "  stow             Symlink dotfile packages via GNU stow (--restow for idempotency)"
	@echo "  jaynalerts       Clone (if missing) and install jaynalerts (bun link + init)"
	@echo "  context-mode     Install context-mode globally via npm (opencode plugin only)"
	@echo "  agentmemory      Install agentmemory (npm), launchd autostart server, claude plugin"
	@echo "  litellm          Install litellm proxy (uv), launchd autostart, Vertex/Gemini for agentmemory compression"
	@echo "  pi               Install the pi coding agent (npm) and link its stowed config"
	@echo "  codex            Install the Codex CLI (npm) and link its stowed config"
	@echo "  tmux-plugins     Bootstrap TPM and install tmux plugins"
	@echo "  verify-symlinks  Check that critical claude/opencode configs are symlinked into HOME"

setup: xcode-clt brew stow jaynalerts context-mode agentmemory litellm pi codex tmux-plugins verify-symlinks

xcode-clt:
	@xcode-select -p >/dev/null 2>&1 || xcode-select --install

brew:
	@test -L $(HOME)/.Brewfile || ln -s $(CURDIR)/.Brewfile $(HOME)/.Brewfile
	-brew bundle --global

# --dir/--target are passed explicitly because stow otherwise installs into the
# repo's PARENT directory, which is only $$HOME when the repo sits at ~/dotfiles.
stow:
	@find $(CURDIR) -name .DS_Store -not -path "$(CURDIR)/.git/*" -delete
	stow --restow --dir=$(CURDIR) --target=$(HOME) $(STOW_PACKAGES)

# jaynalerts' own `make setup` runs `jaynalerts init --shell-rc ~/.zshrc`, which
# writes its managed block into the stowed ~/.zshrc — i.e. into zsh/.zshrc in this
# repo. That is intentional (the block stays version controlled) and idempotent,
# but it means `make stow` has to have run first.
jaynalerts: stow
	@test -d $(JAYNALERTS_DIR) || git clone $(JAYNALERTS_REPO) $(JAYNALERTS_DIR)
	$(MAKE) -C $(JAYNALERTS_DIR) setup
	@mkdir -p $(CURDIR)/opencode/.config/opencode/node_modules
	@ln -sfn $(JAYNALERTS_DIR) $(CURDIR)/opencode/.config/opencode/node_modules/jaynalerts
	@echo "opencode plugin resolution: node_modules/jaynalerts -> $(JAYNALERTS_DIR)"

context-mode:
	@command -v npm >/dev/null 2>&1 || { echo "npm not found — install node first (brew install node)"; exit 1; }
	npm install -g context-mode
	@command -v context-mode >/dev/null 2>&1 && echo "context-mode installed" || echo "context-mode install verify failed"
	@if [ -L $(HOME)/.config/opencode/AGENTS.md ] || [ -L $(HOME)/.config/opencode ]; then \
		echo "AGENTS.md linked via stow"; \
	else \
		echo "AGENTS.md not linked — run 'make stow' (opencode package)"; \
	fi

agentmemory:
	@command -v npm >/dev/null 2>&1 || { echo "npm not found — install node first (brew install node)"; exit 1; }
	npm install -g @agentmemory/agentmemory
	@command -v agentmemory >/dev/null 2>&1 && echo "agentmemory installed" || echo "agentmemory install verify failed"
	@mkdir -p $(HOME)/.agentmemory
	@if [ ! -f $(HOME)/.agentmemory/.env ]; then \
		cp $(CURDIR)/agentmemory/.env.example $(HOME)/.agentmemory/.env; \
		chmod 600 $(HOME)/.agentmemory/.env; \
		echo "ACTION REQUIRED: ~/.agentmemory/.env created from template."; \
		echo "                 Set OPENAI_API_KEY to the master_key from ~/.config/litellm/config.yaml."; \
	else echo "~/.agentmemory/.env exists — leaving as-is"; fi
	@if grep -q "REPLACE_WITH_LITELLM_MASTER_KEY" $(HOME)/.agentmemory/.env 2>/dev/null; then \
		echo "WARN: ~/.agentmemory/.env still has placeholder OPENAI_API_KEY — set it before daemon will compress observations"; \
	fi
	@mkdir -p $(HOME)/Library/LaunchAgents
	@BIN="$$(command -v agentmemory)"; \
	if [ -z "$$BIN" ]; then echo "agentmemory not on PATH — cannot render launchd plist"; exit 1; fi; \
	sed -e "/<!--/,/-->/d" -e "s|@HOME@|$(HOME)|g" -e "s|@PATH@|$(LAUNCHD_PATH)|g" -e "s|@AGENTMEMORY_BIN@|$$BIN|g" \
		$(CURDIR)/agentmemory/ai.agentmemory.plist.in > $(HOME)/Library/LaunchAgents/ai.agentmemory.plist
	@launchctl bootout gui/$$(id -u)/ai.agentmemory 2>/dev/null || true
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		launchctl print gui/$$(id -u)/ai.agentmemory >/dev/null 2>&1 || break; \
		sleep 1; \
	done
	@launchctl bootstrap gui/$$(id -u) $(HOME)/Library/LaunchAgents/ai.agentmemory.plist 2>/dev/null || launchctl load $(HOME)/Library/LaunchAgents/ai.agentmemory.plist
	@for i in $$(seq 1 15); do \
		curl -fsS http://localhost:3111/agentmemory/health >/dev/null 2>&1 && break; \
		sleep 2; \
	done; \
	curl -fsS http://localhost:3111/agentmemory/health >/dev/null 2>&1 \
		&& echo "server healthy: http://localhost:3111" \
		|| echo "server not responding after 30s (check ~/.agentmemory/daemon.log)"
	@claude plugin marketplace add rohitg00/agentmemory 2>/dev/null || true
	@claude plugin install agentmemory@agentmemory 2>/dev/null || echo "claude plugin install: run '/plugin install agentmemory' in Claude Code if CLI failed"
	@echo "Claude Code: hooks+skills+MCP via plugin. opencode: plugin+MCP+commands via 'make stow' (opencode package)."

litellm:
	@command -v uv >/dev/null 2>&1 || brew install uv
	uv tool install "litellm[proxy]" --with google-cloud-aiplatform --with google-auth --force
	@mkdir -p $(HOME)/.config/litellm
	@mkdir -p $(HOME)/Library/LaunchAgents
	@if [ ! -f $(HOME)/.config/litellm/.env ]; then \
		sed -e "s|@HOME@|$(HOME)|g" -e "s|@USER@|$$(id -un)|g" \
			$(CURDIR)/litellm/.config/litellm/.env.example > $(HOME)/.config/litellm/.env; \
		chmod 600 $(HOME)/.config/litellm/.env; \
		echo "ACTION REQUIRED: edit ~/.config/litellm/.env — LITELLM_MASTER_KEY, GITHUB_TOKEN,"; \
		echo "                 OPENCODE_API_KEY and VERTEX_PROJECT are empty in the template."; \
	else echo "~/.config/litellm/.env exists — leaving as-is"; fi
	@for v in LITELLM_MASTER_KEY VERTEX_PROJECT VERTEX_CREDENTIALS DATABASE_URL; do \
		grep -qE "^$$v=." $(HOME)/.config/litellm/.env 2>/dev/null || \
			echo "WARN: $$v unset in ~/.config/litellm/.env — config.yaml resolves it via os.environ/"; \
	done
	@BIN="$$(command -v litellm || echo $(HOME)/.local/bin/litellm)"; \
	sed -e "/<!--/,/-->/d" -e "s|@HOME@|$(HOME)|g" -e "s|@PATH@|$(LAUNCHD_PATH)|g" -e "s|@LITELLM_BIN@|$$BIN|g" \
		$(CURDIR)/litellm/ai.litellm.plist.in > $(HOME)/Library/LaunchAgents/ai.litellm.plist
	@launchctl bootout gui/$$(id -u)/ai.litellm 2>/dev/null || true
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		launchctl print gui/$$(id -u)/ai.litellm >/dev/null 2>&1 || break; \
		sleep 1; \
	done
	@launchctl bootstrap gui/$$(id -u) $(HOME)/Library/LaunchAgents/ai.litellm.plist 2>/dev/null || launchctl load $(HOME)/Library/LaunchAgents/ai.litellm.plist
	@if [ ! -f $(HOME)/.config/litellm/vertex-sa.json ]; then \
		echo "WARN: ~/.config/litellm/vertex-sa.json missing — Vertex calls will 401 (place GCP service-account JSON there, chmod 600)"; \
	fi
	@if ! grep -q "LITELLM_MASTER_KEY" $(HOME)/.zshrc_private 2>/dev/null; then \
		echo "ACTION REQUIRED: export LITELLM_MASTER_KEY=<master_key> in ~/.zshrc_private — opencode litellm provider (architect-gemini) sends empty bearer without it (401)"; \
	fi
	@for i in $$(seq 1 30); do \
		curl -fsS http://localhost:4000/health/liveliness >/dev/null 2>&1 && break; \
		sleep 2; \
	done; \
	if curl -fsS http://localhost:4000/health/liveliness >/dev/null 2>&1; then \
		echo "litellm healthy: http://localhost:4000"; \
	else \
		echo "litellm not responding after 60s — last log lines:"; \
		tail -20 $(HOME)/.config/litellm/litellm.log 2>/dev/null || echo "(no log at ~/.config/litellm/litellm.log)"; \
	fi

restart-litellm:
	@echo "Killing ai.litellm..."
	@launchctl bootout gui/$$(id -u)/ai.litellm 2>/dev/null || true
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		launchctl print gui/$$(id -u)/ai.litellm >/dev/null 2>&1 || break; \
		sleep 1; \
	done
	@echo "Starting ai.litellm..."
	@launchctl bootstrap gui/$$(id -u) $(HOME)/Library/LaunchAgents/ai.litellm.plist 2>/dev/null || launchctl load $(HOME)/Library/LaunchAgents/ai.litellm.plist
	@for i in $$(seq 1 30); do \
		curl -fsS http://localhost:4000/health/liveliness >/dev/null 2>&1 && break; \
		sleep 2; \
	done; \
	if curl -fsS http://localhost:4000/health/liveliness >/dev/null 2>&1; then \
		echo "litellm healthy: http://localhost:4000"; \
	else \
		echo "litellm not responding after 60s — last log lines:"; \
		tail -20 $(HOME)/.config/litellm/litellm.log 2>/dev/null || echo "(no log at ~/.config/litellm/litellm.log)"; \
	fi

# pi keeps auth.json, models-store.json, sessions/ and a vendored fd binary in
# ~/.pi/agent alongside its config, so only settings.json and extensions/ are
# stowed. `jaynalerts init --pi` rewrites extensions/jaynalerts.ts through the
# symlink, i.e. back into this repo — same deal as the managed ~/.zshrc block.
pi: stow
	@command -v npm >/dev/null 2>&1 || { echo "npm not found — install node first (brew install node)"; exit 1; }
	npm install -g @earendil-works/pi-coding-agent
	@command -v pi >/dev/null 2>&1 && echo "pi installed ($$(pi --version))" || echo "pi install verify failed"
	@if [ -L $(HOME)/.pi/agent/settings.json ]; then \
		echo "pi settings linked via stow"; \
	else \
		echo "pi settings not linked — remove $(HOME)/.pi/agent/settings.json, then run 'make stow'"; \
	fi

# Only the declarative half of ~/.codex is stowed (config.toml, hooks.json,
# agents/, rules/). Everything else there is runtime state — auth.json, the
# sqlite databases, sessions/, plugins/ cache — and stays machine-local.
# Codex rewrites config.toml and rules/default.rules itself as you trust projects
# and approve commands, so those edits land back in this repo through the symlink.
codex: stow
	@command -v npm >/dev/null 2>&1 || { echo "npm not found — install node first (brew install node)"; exit 1; }
	npm install -g @openai/codex
	@command -v codex >/dev/null 2>&1 && echo "codex installed ($$(codex --version))" || echo "codex install verify failed"
	@if [ -L $(HOME)/.codex/config.toml ]; then \
		echo "codex config linked via stow"; \
	else \
		echo "codex config not linked — remove $(HOME)/.codex/config.toml, then run 'make stow'"; \
	fi

tmux-plugins:
	@TPM_DIR="$(HOME)/.tmux/plugins/tpm"; \
	if [ ! -d "$$TPM_DIR" ]; then \
		echo "Cloning tmux-plugins/tpm..."; \
		git clone https://github.com/tmux-plugins/tpm "$$TPM_DIR"; \
	else \
		echo "tpm already cloned"; \
	fi
	@if ! command -v tmux >/dev/null 2>&1; then \
		echo "tmux not installed — skipping plugin install (run 'brew bundle --global' first)"; \
	elif [ ! -f $(HOME)/.tmux.conf ]; then \
		echo "~/.tmux.conf missing — run 'make stow' first, then re-run 'make tmux-plugins'"; \
		exit 1; \
	else \
		echo "Installing tmux plugins (via tpm)..."; \
		tmux start-server; \
		tmux source-file $(HOME)/.tmux.conf 2>/dev/null || true; \
		export TMUX_PLUGIN_MANAGER_PATH="$(HOME)/.tmux/plugins/"; \
		$(HOME)/.tmux/plugins/tpm/bin/install_plugins; \
	fi

# ~/.claude and ~/.config/opencode become real directories as soon as anything
# else writes into them, so check the stowed files rather than the directories.
verify-symlinks:
	@echo "Verifying critical symlinks..."
	@for f in $(HOME)/.claude/settings.json $(HOME)/.claude/CLAUDE.md \
	          $(HOME)/.config/opencode/opencode.json $(HOME)/.config/opencode/AGENTS.md \
	          $(HOME)/.pi/agent/settings.json $(HOME)/.codex/config.toml \
	          $(HOME)/.zshrc $(HOME)/.zshrc_base $(HOME)/.tmux.conf $(HOME)/.Brewfile; do \
		if [ -L "$$f" ]; then echo "  ok   $$f -> $$(readlink $$f)"; \
		elif [ -e "$$f" ]; then echo "  WARN $$f exists but is NOT a symlink (remove it, then 'make stow')"; \
		else echo "  MISS $$f missing (run 'make stow')"; fi; \
	done
