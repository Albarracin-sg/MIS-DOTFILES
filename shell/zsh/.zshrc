# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Habilita sustitución en el prompt
setopt prompt_subst

# =====================
# Oh My Zsh base
# =====================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# =====================
# pyenv
# =====================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# =====================
# Bun
# =====================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# =====================
# Spicetify
# =====================
export PATH="$HOME/.spicetify:$PATH"

# =====================
# Aliases
# =====================
alias firefox='GTK_USE_PORTAL=1 firefox'

# =====================
# Prompt configuration
# =====================

# Ícono de directorio
function dir_icon {
  if [[ "$PWD" == "$HOME" ]]; then
    echo "%B%F{black}%f%b"
  else
    echo "%B%F{cyan}%f%b"
  fi
}

# Rama actual de git (si aplica)
function parse_git_branch {
  local branch
  branch=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [ -n "$branch" ]; then
    echo " [$branch]"
  fi
}

# Prompt final con íconos personalizados
PROMPT='%F{cyan}󰣇 %f %F{magenta}%n%f ${$(dir_icon)} %F{red}%~%f ${vcs_info_msg_0_} %F{yellow}$(parse_git_branch)%f %(?.%B%F{green}.%F{red})%f%b '

# Desactiva advertencias innecesarias
DISABLE_UNSUPPORTED_CONFIG=true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#gemini
alias gemini='node ~/.local/lib/node_modules/@google/gemini-cli/dist/index.js'

