# ========================
# OH-MY-ZSH CONFIGURACIÓN
# ========================

# Ruta donde está instalado Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema aleatorio (si ZSH_THEME=random)
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
ZSH_THEME="powerlevel10k/powerlevel10k"

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
# PROMPT (Powerlevel10k)
# ========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

# ========================
# PATHS
# ========================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=$PATH:/home/sandia/.spicetify


#=========================
#variables de entorno
#=========================
export GITHUB_TOKEN="${GITHUB_TOKEN}"

# ========================
# ALIASES
# ========================

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

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/sandia/.dotnet/tools"


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


