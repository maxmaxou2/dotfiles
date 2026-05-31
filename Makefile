.PHONY: help setup xcode-clt brew stow stay-alert context-mode agentmemory litellm tmux-plugins verify-symlinks

STAY_ALERT_REPO ?= git@github.com:maxmaxou2/stay-alert.git
STAY_ALERT_DIR  ?= $(HOME)/src/stay-alert
STOW_PACKAGES   ?= clang-format claude conda hammerspoon karabiner nvim opencode pdb rich ssh tmux tmuxp zsh

help:
	@echo "Targets:"
	@echo "  setup            Run xcode-clt, brew, stow, stay-alert, context-mode, tmux-plugins"
	@echo "  xcode-clt        Install Xcode Command Line Tools (provides swiftc) if missing"
	@echo "  brew             Symlink .Brewfile and run brew bundle --global"
	@echo "  stow             Symlink dotfile packages via GNU stow (--restow for idempotency)"
	@echo "  stay-alert       Clone (if missing) and install stay-alert (bun link + init)"
	@echo "  context-mode     Install context-mode globally via npm (opencode plugin + claude hook)"
	@echo "  agentmemory      Install agentmemory (npm), launchd autostart server, claude plugin"
	@echo "  litellm          Install litellm proxy (uv), launchd autostart, Vertex/Gemini for agentmemory compression"
	@echo "  tmux-plugins     Bootstrap TPM and install tmux plugins"
	@echo "  verify-symlinks  Check that critical claude/opencode configs are symlinked into HOME"

setup: xcode-clt brew stow stay-alert context-mode agentmemory litellm tmux-plugins verify-symlinks

xcode-clt:
	@xcode-select -p >/dev/null 2>&1 || xcode-select --install

brew:
	@test -L $(HOME)/.Brewfile || ln -s $(CURDIR)/.Brewfile $(HOME)/.Brewfile
	-brew bundle --global

stow:
	stow --restow $(STOW_PACKAGES)

stay-alert:
	@test -d $(STAY_ALERT_DIR) || git clone $(STAY_ALERT_REPO) $(STAY_ALERT_DIR)
	$(MAKE) -C $(STAY_ALERT_DIR) setup

context-mode:
	@command -v npm >/dev/null 2>&1 || { echo "npm not found — install node first (brew install node)"; exit 1; }
	npm install -g context-mode
	@command -v context-mode >/dev/null 2>&1 && echo "context-mode installed" || echo "context-mode install verify failed"
	@mkdir -p $(HOME)/.config/opencode
	@test -L $(HOME)/.config/opencode/AGENTS.md || ln -sf ../../dotfiles/opencode/.config/opencode/AGENTS.md $(HOME)/.config/opencode/AGENTS.md
	@echo "AGENTS.md symlinked: $$(readlink $(HOME)/.config/opencode/AGENTS.md)"

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
	@cp $(CURDIR)/agentmemory/ai.agentmemory.plist $(HOME)/Library/LaunchAgents/ai.agentmemory.plist
	@launchctl bootout gui/$$(id -u)/ai.agentmemory 2>/dev/null || true
	@launchctl bootstrap gui/$$(id -u) $(HOME)/Library/LaunchAgents/ai.agentmemory.plist 2>/dev/null || launchctl load $(HOME)/Library/LaunchAgents/ai.agentmemory.plist
	@sleep 1; curl -fsS http://localhost:3111/agentmemory/health >/dev/null 2>&1 && echo "server healthy: http://localhost:3111" || echo "server not responding yet (check ~/.agentmemory/daemon.log)"
	@claude plugin marketplace add rohitg00/agentmemory 2>/dev/null || true
	@claude plugin install agentmemory@agentmemory 2>/dev/null || echo "claude plugin install: run '/plugin install agentmemory' in Claude Code if CLI failed"
	@echo "Claude Code: hooks+skills+MCP via plugin. opencode: plugin+MCP+commands via 'make stow' (opencode package)."

litellm:
	@command -v uv >/dev/null 2>&1 || brew install uv
	uv tool install "litellm[proxy]" --with google-cloud-aiplatform --with google-auth --force
	@mkdir -p $(HOME)/.config/litellm
	@if [ ! -f $(HOME)/.config/litellm/config.yaml ]; then \
		cp $(CURDIR)/litellm/config.yaml.example $(HOME)/.config/litellm/config.yaml; \
		chmod 600 $(HOME)/.config/litellm/config.yaml; \
		echo "ACTION REQUIRED: edit ~/.config/litellm/config.yaml — set master_key + vertex_credentials path,"; \
		echo "                 place the Vertex service-account JSON at ~/.config/litellm/vertex-sa.json (chmod 600),"; \
		echo "                 then set agentmemory ~/.agentmemory/.env: OPENAI_API_KEY=<that master_key>,"; \
		echo "                 OPENAI_BASE_URL=http://localhost:4000, OPENAI_MODEL=gemini-flash,"; \
		echo "                 EMBEDDING_PROVIDER=local, AGENTMEMORY_AUTO_COMPRESS=true, MAX_TOKENS=1024."; \
	else echo "~/.config/litellm/config.yaml exists — leaving as-is"; fi
	@mkdir -p $(HOME)/Library/LaunchAgents
	@cp $(CURDIR)/litellm/ai.litellm.plist $(HOME)/Library/LaunchAgents/ai.litellm.plist
	@launchctl bootout gui/$$(id -u)/ai.litellm 2>/dev/null || true
	@launchctl bootstrap gui/$$(id -u) $(HOME)/Library/LaunchAgents/ai.litellm.plist 2>/dev/null || launchctl load $(HOME)/Library/LaunchAgents/ai.litellm.plist
	@if grep -q "REPLACE_WITH_RANDOM" $(HOME)/.config/litellm/config.yaml 2>/dev/null; then \
		echo "WARN: ~/.config/litellm/config.yaml still has placeholder master_key — edit it before litellm will accept calls"; \
	fi
	@if [ ! -f $(HOME)/.config/litellm/vertex-sa.json ]; then \
		echo "WARN: ~/.config/litellm/vertex-sa.json missing — Vertex calls will 401 (place GCP service-account JSON there, chmod 600)"; \
	fi
	@sleep 12; if curl -fsS http://localhost:4000/health/liveliness >/dev/null 2>&1; then \
		echo "litellm healthy: http://localhost:4000"; \
	else \
		echo "litellm not responding — last log lines:"; \
		tail -20 $(HOME)/.config/litellm/litellm.log 2>/dev/null || echo "(no log at ~/.config/litellm/litellm.log)"; \
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

verify-symlinks:
	@echo "Verifying critical symlinks..."
	@for f in $(HOME)/.claude $(HOME)/.config/opencode $(HOME)/.config/opencode/AGENTS.md $(HOME)/.Brewfile; do \
		if [ -L "$$f" ]; then echo "  ok  $$f -> $$(readlink $$f)"; \
		elif [ -e "$$f" ]; then echo "  WARN $$f exists but is NOT a symlink (run 'make stow' after removing real file)"; \
		else echo "  MISS $$f missing"; fi; \
	done
