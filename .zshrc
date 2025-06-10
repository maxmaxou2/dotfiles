# Load base config (public, shared in dotfiles)
source "$HOME/.zshrc_base"

# Load private config (local secrets, aliases, tokens, etc.)
[ -f "$HOME/.zshrc_private" ] && source "$HOME/.zshrc_private"
