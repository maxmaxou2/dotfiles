# Load base config (public, shared in dotfiles)
source "$HOME/.zshrc_base"

# Load private config (local secrets, aliases, tokens, etc.)
[ -f "$HOME/.zshrc_private" ] && source "$HOME/.zshrc_private"

# Load ssh agent
[ -f ~/.ssh/agent.sh ] && source ~/.ssh/agent.sh

export PATH="$HOME/.bun/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# stay-alert begin (managed — do not edit)
if [[ -n ${ZSH_VERSION-} ]] && command -v stay-alert >/dev/null 2>&1; then
  zmodload zsh/datetime 2>/dev/null
  typeset -g __stay_alert_start=0
  typeset -g __stay_alert_cmd=""
  __stay_alert_preexec() {
    __stay_alert_start=$EPOCHREALTIME
    __stay_alert_cmd=$1
  }
  __stay_alert_precmd() {
    local ec=$?
    [[ -z $__stay_alert_cmd ]] && return
    local dur_ms=$(( (EPOCHREALTIME - __stay_alert_start) * 1000 ))
    stay-alert notify-command --cmd "$__stay_alert_cmd" --exit $ec --duration-ms ${dur_ms%.*} >/dev/null 2>&1 &!
    __stay_alert_cmd=""
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook preexec __stay_alert_preexec
  add-zsh-hook precmd __stay_alert_precmd
fi
# stay-alert end
