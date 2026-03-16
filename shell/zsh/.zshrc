# ========================
# OH-MY-ZSH CONFIGURACIÓN
# ========================

# Ruta donde está instalado Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema aleatorio (si ZSH_THEME=random)
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# HYPHEN_INSENSITIVE="true"

# Actualizaciones automáticas
# zstyle ':omz:update' mode auto
# zstyle ':omz:update' frequency 13

# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# HIST_STAMPS="yyyy-mm-dd"

# ========================
# PLUGINS
# ========================
plugins=(
  zsh-history-substring-search
  zsh-syntax-highlighting
  zsh-autosuggestions
  git
)

autoload -Uz add-zsh-hook

source $ZSH/oh-my-zsh.sh

# ========================
# USER CONFIG
# ========================

# export LANG=en_US.UTF-8

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# ========================
# PROMPT (Starship)
# ========================
unset RPROMPT RPS1
unset POWERLEVEL9K_CONFIG_FILE POWERLEVEL9K_INSTANT_PROMPT
unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
eval "$(starship init zsh)"
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

# ========================
# PATHS
# ========================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=$PATH:/home/sandia/.spicetify


# ========================
# ALIASES
# ========================

alias ls='eza --icons'
alias ll='eza --icons -l'
alias la='eza --icons -la'
alias lt='eza --icons --tree'
alias lta='eza --icons --tree -a'
alias clone='git clone'
alias opencode='npm --prefix "$HOME/tools/MIS-DOTFILES/tools/opencode" run -s portable --'
alias ocp='npm --prefix "$HOME/tools/MIS-DOTFILES/tools/opencode" run -s portable --'
alias ocl='npm --prefix "$HOME/tools/MIS-DOTFILES/tools/opencode" run -s local --'

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

if command -v dust >/dev/null 2>&1; then
  alias du='dust'
fi

if command -v btop >/dev/null 2>&1; then
  alias top='btop'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias c='clear'

#=========================
# APAGADO O ENSENDIDO
#========================
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'


#======================
#modo oscuro 
#=====================
export QT_QPA_PLATFORMTHEME=qt6ct

# ========================
# MySQL
# ========================
alias mysqlon='sudo systemctl start mariadb && echo "MariaDB iniciado :)"'
alias mysqloff='sudo systemctl stop mariadb && echo "MariaDB detenido :("'
alias mysqlstatus='systemctl status mariadb'

# ========================
# PostgreSQL
# ========================
alias pgon='sudo systemctl start postgresql && echo "PostgreSQL iniciado :)"'
alias pgoff='sudo systemctl stop postgresql && echo "PostgreSQL detenido :("'
alias pgstatus='systemctl status postgresql'




#=============================
#server
#=============================
alias tinkpad='ssh kiwi@100.93.157.4'


#=============================
#comit individual
#=============================

alias gci="~/scripts/vsc/copilot/commit-individual.sh"
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
  [[ -n ${KITTY_WINDOW_ID:-} ]] || return 0
  local title="$1"
  printf '\e]2;%s\a' "$title"
  kitten @ set-window-title "$title" >/dev/null 2>&1 || true
  kitten @ set-tab-title "$title" >/dev/null 2>&1 || true
}

_kitty_command_icon() {
  local command_name="$1"

  case "$command_name" in
    nvim|vim|vi)
      printf ''
      ;;
    yazi|ranger|lf)
      printf ''
      ;;
    btop|htop|top)
      printf '󰄪'
      ;;
    lazygit|git|gitui|tig|gh)
      printf '󰊢'
      ;;
    ssh|scp|sftp|sshfs)
      printf '󰣀'
      ;;
    docker|docker-compose|lazydocker|podman)
      printf '󰡨'
      ;;
    python|python3|uv|pytest|pip|pip3|poetry)
      printf '󰌠'
      ;;
    node|nodejs|npm|pnpm|yarn|bun|npx|tsx|ts-node|vite|vitest|next|astro|nuxt)
      printf '󰎙'
      ;;
    java|javac|gradle|mvn)
      printf ''
      ;;
    go)
      printf ''
      ;;
    cargo|rustc)
      printf ''
      ;;
    code|code-insiders)
      printf '󰨞'
      ;;
    mysql|mariadb|mysqldump|psql|pg_dump|sqlite3|mongosh|redis-cli)
      printf '󰆼'
      ;;
    kubectl|k9s|kubens|kubectx|helm)
      printf '󱃾'
      ;;
    terraform|tofu|terragrunt)
      printf '󱁢'
      ;;
    ansible)
      printf '󱂚'
      ;;
    opencode|ocp|ocl)
      printf '󰚩'
      ;;
    *)
      printf '󰣇'
      ;;
  esac
}

_kitty_extract_command_name() {
  local raw_command="$1"
  local -a words
  words=( ${(z)raw_command} )

  local word
  for word in "${words[@]}"; do
    case "$word" in
      sudo|env|command|builtin|nohup|time)
        continue
        ;;
      *=*)
        continue
        ;;
      *)
        printf '%s' "$word"
        return 0
        ;;
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

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/sandia/.dotnet/tools"

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

export EZA_COLORS="di=1;36:ex=1;32:ln=1;35:or=1;31"


#===================================
# EMULADOR
# ==================================
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias cls="clear"


pokemon-colorscripts -r
eval $(thefuck --alias)
