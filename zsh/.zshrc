# Load base config (public, shared in dotfiles)
source "$HOME/.zshrc_base"

# Load private config (local secrets, aliases, tokens, etc.)
[ -f "$HOME/.zshrc_private" ] && source "$HOME/.zshrc_private"

# Load ssh agent
[ -f ~/.ssh/agent.sh ] && source ~/.ssh/agent.sh

export PATH="$HOME/.bun/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# postgresql@16 (keg-only — both @14 and @16 installed, neither auto-linked)
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"


# Ensure ~/.local/bin is on PATH (claude, uv, etc. — before uv's env script)
export PATH="$HOME/.local/bin:$PATH"

# jaynalerts begin (managed — do not edit)
if [[ -n ${ZSH_VERSION-} ]] && command -v jaynalerts >/dev/null 2>&1; then
  zmodload zsh/datetime 2>/dev/null
  typeset -g __jaynalerts_start=0
  typeset -g __jaynalerts_cmd=""
  __jaynalerts_preexec() {
    __jaynalerts_start=$EPOCHREALTIME
    __jaynalerts_cmd=$1
  }
  __jaynalerts_precmd() {
    local ec=$?
    [[ -z $__jaynalerts_cmd ]] && return
    local dur_ms=$(( (EPOCHREALTIME - __jaynalerts_start) * 1000 ))
    jaynalerts notify-command --cmd "$__jaynalerts_cmd" --exit $ec --duration-ms ${dur_ms%.*} >/dev/null 2>&1 &!
    __jaynalerts_cmd=""
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook preexec __jaynalerts_preexec
  add-zsh-hook precmd __jaynalerts_precmd
fi
# jaynalerts end
