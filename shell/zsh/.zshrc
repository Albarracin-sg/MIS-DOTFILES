# ==============================
# OH MY ZSH
# ==============================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

autoload -Uz add-zsh-hook
source "$ZSH/oh-my-zsh.sh"


# ==============================
# PROMPT Y HERRAMIENTAS SHELL
# ==============================

eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"

export STARSHIP_CONFIG="$HOME/.config/starship/current.toml"
[[ -f "$STARSHIP_CONFIG" ]] || export STARSHIP_CONFIG="$HOME/.config/starship.toml"

eval "$(starship init zsh)"

if [[ -o interactive ]] && [[ -z "${OPENCODE:-}" ]] && [[ -t 1 ]] && command -v pokemon-colorscripts >/dev/null 2>&1; then
  pokemon-colorscripts -r
fi


# ==============================
# PATHS
# ==============================

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"


# ==============================
# VARIABLES DE ENTORNO
# ==============================

export QT_QPA_PLATFORMTHEME="qt6ct"

export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"


# ==============================
# ALIASES GENERALES
# ==============================

alias ls='eza --icons'
alias ll='eza --icons -l'
alias la='eza --icons -la'
alias lt='eza --icons --tree'
alias lta='eza --icons --tree -a'

alias clone='git clone'
alias opencode='opencode-profile portable'
alias ocp='opencode-profile portable'
alias ocl='opencode-profile local'
alias ocd='opencode-profile default'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias mkdir='mkdir -pv'
alias c='clear'
alias cls='clear'

command -v bat >/dev/null 2>&1 && alias cat='bat --style=plain'
command -v rg >/dev/null 2>&1 && alias grep='rg'
command -v dust >/dev/null 2>&1 && alias du='dust'
command -v btop >/dev/null 2>&1 && alias top='btop'


# ==============================
# ALIASES DE BASE DE DATOS
# ==============================

alias mysqlon='sudo systemctl start mariadb && echo "MariaDB iniciado :)"'
alias mysqloff='sudo systemctl stop mariadb && echo "MariaDB detenido :("'
alias mysqlstatus='systemctl status mariadb'

alias pgon='sudo systemctl start postgresql && echo "PostgreSQL iniciado :)"'
alias pgoff='sudo systemctl stop postgresql && echo "PostgreSQL detenido :("'
alias pgstatus='systemctl status postgresql'


# ==============================
# ALIASES DE SISTEMA
# ==============================

alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'


# ==============================
# SSH
# ==============================

alias tinkpad='ssh kiwi@100.93.157.4'


# ==============================
# GIT / COMMIT
# ==============================

alias gci="$HOME/scripts/vsc/copilot/commit-individual.sh"


# ==============================
# KITTY TERMINAL TITLES
# ==============================

alias ntab='kitten @ set-tab-title'
alias ntabi='kitten @ set-tab-title " "'
alias rtab='kitten @ set-tab-title ""'

ptab() {
  local title="${1:-${PWD:t}}"
  kitten @ set-tab-title "$title"
}

wtab() {
  local title="${1:-${PWD:t}}"
  kitten @ set-tab-title "$title"
  kitten @ set-window-title "$title"
}

_kitty_set_title() {
  [[ -n "${KITTY_WINDOW_ID:-}" ]] || return 0
  local title="$1"
  printf '\e]2;%s\a' "$title"
  kitten @ set-window-title "$title" >/dev/null 2>&1 || true
  kitten @ set-tab-title "$title" >/dev/null 2>&1 || true
}

_kitty_command_icon() {
  local command_name="$1"
  case "$command_name" in
    nvim|vim|vi) printf '' ;;
    yazi|ranger|lf) printf '' ;;
    btop|htop|top) printf '󰄪' ;;
    lazygit|git|gitui|tig|gh) printf '󰊢' ;;
    ssh|scp|sftp|sshfs) printf '󰣀' ;;
    docker|docker-compose|podman) printf '󰡨' ;;
    python|python3|pip|pytest) printf '󰌠' ;;
    node|npm|pnpm|yarn|bun|npx) printf '󰎙' ;;
    java|javac|gradle|mvn) printf '' ;;
    go) printf '' ;;
    cargo|rustc) printf '' ;;
    kubectl|helm|k9s) printf '󱃾' ;;
    *) printf '󰣇' ;;
  esac
}

_kitty_extract_command_name() {
  local raw_command="$1"
  local -a words
  words=( ${(z)raw_command} )
  for word in "${words[@]}"; do
    case "$word" in
      sudo|env|command|builtin|nohup|time) continue ;;
      *=*) continue ;;
      *) printf '%s' "$word"; return 0 ;;
    esac
  done
  printf 'shell'
}

_kitty_title_precmd() {
  local current_dir="${PWD:t}"
  [[ -n "$current_dir" ]] || current_dir="~"
  _kitty_set_title "󰣇 $current_dir"
}

_kitty_title_preexec() {
  local command_name icon
  command_name="$(_kitty_extract_command_name "$1")"
  icon="$(_kitty_command_icon "$command_name")"
  _kitty_set_title "$icon $command_name"
}

add-zsh-hook precmd _kitty_title_precmd
add-zsh-hook preexec _kitty_title_preexec
_kitty_title_precmd


# ==============================
# COLORES LS / EZA
# ==============================

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

export EZA_COLORS="di=1;36:ex=1;32:ln=1;35:or=1;31"
