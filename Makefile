.PHONY: help setup xcode-clt brew stow stay-alert

STAY_ALERT_REPO ?= git@github.com:maxmaxou2/stay-alert.git
STAY_ALERT_DIR  ?= $(HOME)/src/stay-alert
STOW_PACKAGES   ?= clang-format claude conda hammerspoon karabiner nvim opencode pdb rich ssh tmux zsh

help:
	@echo "Targets:"
	@echo "  setup       Run xcode-clt, brew, stow, and stay-alert"
	@echo "  xcode-clt   Install Xcode Command Line Tools (provides swiftc) if missing"
	@echo "  brew        Symlink .Brewfile and run brew bundle --global"
	@echo "  stow        Symlink dotfile packages via GNU stow"
	@echo "  stay-alert  Clone (if missing) and install stay-alert (bun link + init)"

setup: xcode-clt brew stow stay-alert

xcode-clt:
	@xcode-select -p >/dev/null 2>&1 || xcode-select --install

brew:
	@test -L $(HOME)/.Brewfile || ln -s $(CURDIR)/.Brewfile $(HOME)/.Brewfile
	brew bundle --global

stow:
	stow $(STOW_PACKAGES)

stay-alert:
	@test -d $(STAY_ALERT_DIR) || git clone $(STAY_ALERT_REPO) $(STAY_ALERT_DIR)
	$(MAKE) -C $(STAY_ALERT_DIR) setup
