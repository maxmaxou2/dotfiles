# Load base config (public, shared in dotfiles)
source "$HOME/.zshrc_base"

# Load private config (local secrets, aliases, tokens, etc.)
[ -f "$HOME/.zshrc_private" ] && source "$HOME/.zshrc_private"

# Load ssh agent
[ -f ~/.ssh/agent.sh ] && source ~/.ssh/agent.sh

# bun completions
[ -s "/Users/maxence/.bun/_bun" ] && source "/Users/maxence/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
