#!/bin/sh -e
# SPDX-License-Identifier: CC0

### Detect prefix for bash-completion
# shellcheck disable=SC2016
prefix=$(dirname "$(dirname "$(command -v bash)")")
if [ "$prefix" = "/" ]; then
  prefix="/usr"
fi

### Use vim if available, vi otherwise
if command -v vim >/dev/null 2>&1; then
  editor="vim"
else
  editor="vi"
fi

### Write .bash_logout
cat <<E0F >"$HOME/.bash_logout"
if [ -f "\$HOME/.bash_logout.local" ]; then
  . "\$HOME/.bash_logout.local"
fi
clear
E0F

### Remove .profile if it exists
rm -f "$HOME/.profile"

### Write .bash_profile
cat <<E0F >"$HOME/.bash_profile"
if [ ! "\$TMUX" ]; then
  export TERM="xterm-256color"
fi
. "\$HOME/.bashrc"
if [ -f "\$HOME/.bash_profile.local" ]; then
  . "\$HOME/.bash_profile.local"
fi
E0F

### Write .inputrc
echo "set completion-ignore-case On" >"$HOME/.inputrc"

### Write .bashrc
cat <<E0F >"$HOME/.bashrc"
if [ -f "\$HOME/.git-prompt.sh" ]; then
  . "\$HOME/.git-prompt.sh"
  PS1='\u@\h:\w\$(__git_ps1 " (%s)")\\$ '
else
  PS1="\u@\h:\w\$ "
fi
E0F
##### Use color ls on Linux, standard ls elsewhere
if [ "$(uname)" = "Linux" ]; then
  echo 'alias ls="ls --color=auto"' >>"$HOME/.bashrc"
else
  echo 'alias ls="ls -F"' >>"$HOME/.bashrc"
fi
##### If using vim, alias vi
if [ "$editor" = "vim" ]; then
  echo 'alias vi="vim"' >>"$HOME/.bashrc"
fi
cat <<E0F >>"$HOME/.bashrc"
export EDITOR="$editor"
export LANG="en_US.UTF-8"
export LESS="FXMRc"
export PAGER="less"
export PATH="\$HOME/.local/bin:\$PATH"
export VISUAL="$editor"
if [ -f "$prefix/share/bash-completion/bash_completion" ]; then
  . "$prefix/share/bash-completion/bash_completion"
fi
case "\$TERM" in
xterm*)
  PROMPT_COMMAND='echo -ne "\033]0;\${USER}@\${HOSTNAME}:\${PWD}\007"'
  ;;
*)
  ;;
esac
if [ -f "\$HOME/.bashrc.local" ]; then
  . "\$HOME/.bashrc.local"
fi
E0F

### If vim is installed, write .vimrc
if command -v vim >/dev/null; then
  cat <<E0F >"$HOME/.vimrc"
if &compatible
  set nocompatible
endif
filetype plugin indent on
nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
set autoindent
set autoread
set background=dark
set backspace=indent,eol,start
set complete-=i
set display+=lastline
set encoding=utf-8
set expandtab
set formatoptions+=j
set hidden
set history=50
set ignorecase
if has("reltime")
  set incsearch
endif
set laststatus=2
set modeline
set nrformats-=octal
set ruler
set scrolloff=1
set sessionoptions-=options
set sidescrolloff=5
set smartcase
set smarttab
set statusline=%f\ %m\ %r\ %=\ %y\ %l,%c
set tabpagemax=50
set ttimeout
set ttimeoutlen=100
set viewoptions-=options
set wildmenu
autocmd BufRead,BufNewFile *.md set filetype=markdown textwidth=72
autocmd BufRead,BufNewFile *.mdoc set filetype=nroff
autocmd FileType python setlocal completeopt-=preview textwidth=79 tabstop=4
if has("syntax")
  syntax on
endif
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
E0F
fi

### If tmux is installed, write .tmux.conf
if command -v tmux >/dev/null; then
  cat <<E0F >"$HOME/.tmux.conf"
unbind C-b
set-option -g prefix C-a
bind C-a send-prefix
set -s escape-time 0
set -g history-limit 50000
set -g display-time 4000
set -g status-interval 5
set -g default-terminal "tmux-256color"
set -g focus-events on
setw -g aggressive-resize on
setw -g mode-keys vi
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind-key -T copy-mode-vi "v" send -X begin-selection
bind-key -T copy-mode-vi "y" send -X copy-selection
set-option -g status-right "#(whoami)@#(hostname -s) %R %F"
set-option -g status-style bg=dimgray
set-option -ag status-style fg=black
set-option -g pane-border-style fg=dimgray
set-option -g pane-active-border-style fg=white
set-option -g message-style bg=black
set-option -ag message-style fg=white
set -g status-right-length 50
set -g status-left-length 20
if '[ -f ~/.tmux.conf.local ]' {
  source-file ~/.tmux.conf.local
}
E0F
fi

### If git is installed, write .gitconfig
if command -v git >/dev/null; then
  git config --global branch.autosetupmerge 'true'
  git config --global color.ui 'auto'
  git config --global core.autocrlf 'input'
  # shellcheck disable=SC2088
  git config --global core.excludesfile '~/.gitignore_global'
  git config --global diff.mnemonicprefix 'true'
  git config --global init.defaultBranch 'main'
  git config --global pull.rebase 'true'
  git config --global push.default 'current'
  git config --global push.followTags 'true'
  git config --global rerere.enabled 'true'
  git config --global user.name 'Mark Cornick'
fi
touch "$HOME/.gitignore_global"

### If zsh is installed, write .zshrc and .zlogout
if command -v zsh >/dev/null; then
  cat <<E0F >"$HOME/.zshrc"
setopt PROMPT_SUBST
if [ -f "\$HOME/.git-prompt.sh" ]; then
  . "\$HOME/.git-prompt.sh"
  PS1='%n@%m:%~\$(__git_ps1 " (%s)")%% '
else
  PS1="%n@%m:%~%% "
fi
HISTFILE="\$HOME/.zsh_history"
HISTSIZE=2000
SAVEHIST=1000
setopt completealiases
setopt HIST_IGNORE_DUPS
zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
autoload -Uz compinit && compinit
E0F
  if [ "$(uname)" = "Linux" ]; then
    echo 'alias ls="ls --color=auto"' >>"$HOME/.zshrc"
  else
    echo 'alias ls="ls -F"' >>"$HOME/.zshrc"
  fi
  if [ "$editor" = "vim" ]; then
    echo 'alias vi="vim"' >>"$HOME/.zshrc"
  fi
  cat <<E0F >>"$HOME/.zshrc"
export EDITOR="$editor"
export LANG="en_US.UTF-8"
export LESS="FXMRc"
export PAGER="less"
export PATH="\$HOME/.local/bin:\$PATH"
export VISUAL="$editor"
case "\$TERM" in
xterm*)
  precmd() {print -Pn "\e]0;%n@%m:%~\a"}
  ;;
*)
  ;;
esac
if [ -f "\$HOME/.zshrc.local" ]; then
  . "\$HOME/.zshrc.local"
fi
E0F
  cat <<E0F >"$HOME/.zlogout"
if [ -f "\$HOME/.zlogout.local" ]; then
  . "\$HOME/.zlogout.local"
fi
clear
E0F
fi

### Source bootstrap.sh.local if it exists
if [ -f "$HOME/bootstrap.sh.local" ]; then
  # shellcheck disable=SC1091
  . "$HOME/bootstrap.sh.local"
fi
