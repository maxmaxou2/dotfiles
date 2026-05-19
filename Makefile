.PHONY: help setup xcode-clt brew stow stay-alert context-mode verify-symlinks

STAY_ALERT_REPO ?= git@github.com:maxmaxou2/stay-alert.git
STAY_ALERT_DIR  ?= $(HOME)/src/stay-alert
STOW_PACKAGES   ?= clang-format claude conda hammerspoon karabiner nvim opencode pdb rich ssh tmux zsh

help:
	@echo "Targets:"
	@echo "  setup            Run xcode-clt, brew, stow, stay-alert, context-mode"
	@echo "  xcode-clt        Install Xcode Command Line Tools (provides swiftc) if missing"
	@echo "  brew             Symlink .Brewfile and run brew bundle --global"
	@echo "  stow             Symlink dotfile packages via GNU stow (--restow for idempotency)"
	@echo "  stay-alert       Clone (if missing) and install stay-alert (bun link + init)"
	@echo "  context-mode     Install context-mode globally via npm (opencode plugin + claude hook)"
	@echo "  verify-symlinks  Check that critical claude/opencode configs are symlinked into HOME"

setup: xcode-clt brew stow stay-alert context-mode verify-symlinks

xcode-clt:
	@xcode-select -p >/dev/null 2>&1 || xcode-select --install

brew:
	@test -L $(HOME)/.Brewfile || ln -s $(CURDIR)/.Brewfile $(HOME)/.Brewfile
	brew bundle --global

stow:
	stow --restow $(STOW_PACKAGES)

stay-alert:
	@test -d $(STAY_ALERT_DIR) || git clone $(STAY_ALERT_REPO) $(STAY_ALERT_DIR)
	$(MAKE) -C $(STAY_ALERT_DIR) setup

context-mode:
	@command -v npm >/dev/null 2>&1 || { echo "npm not found — install node first (brew install node)"; exit 1; }
	npm install -g context-mode
	@context-mode --version >/dev/null 2>&1 && echo "context-mode installed: $$(context-mode --version)" || echo "context-mode install verify failed"
	@mkdir -p $(HOME)/.config/opencode
	@test -L $(HOME)/.config/opencode/AGENTS.md || ln -sf ../../dotfiles/opencode/.config/opencode/AGENTS.md $(HOME)/.config/opencode/AGENTS.md
	@echo "AGENTS.md symlinked: $$(readlink $(HOME)/.config/opencode/AGENTS.md)"

verify-symlinks:
	@echo "Verifying critical symlinks..."
	@for f in $(HOME)/.claude/settings.json $(HOME)/.claude/hooks $(HOME)/.claude/skills $(HOME)/.config/opencode/opencode.json $(HOME)/.config/opencode/AGENTS.md $(HOME)/.Brewfile; do \
		if [ -L "$$f" ]; then echo "  ok  $$f -> $$(readlink $$f)"; \
		elif [ -e "$$f" ]; then echo "  WARN $$f exists but is NOT a symlink (run 'make stow' after removing real file)"; \
		else echo "  MISS $$f missing"; fi; \
	done
