export ZPLUG_HOME=/usr/local/opt/zplug
export ZSH=~/.oh-my-zsh

#====================
#  ZSH PLUGIN
#====================
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-history-substring-search"
zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme
zplug "zsh-users/zsh-autosuggestions"
zplug "b4b4r07/emoji-cli"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

#====================
#  LOAD LOCAL CONFIG
#====================

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

#====================
# FUNCTION
#====================

frepo() {
  local dir
  dir=$(ghq list > /dev/null | fzf-tmux --reverse +m) &&
    cd $(ghq root)/$dir
}

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#====================
# HISTORY
#====================

export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks  
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt inc_append_history

#====================
#  RUN TMUX
#====================

function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
            cat <<EOF
${fg_bold[red]} _____     _ _           _ _ _         _   ${reset_color}
${fg_bold[red]}|     |___|_| |_ ___ ___| | | |___ ___| |_ ${reset_color}
${fg_bold[red]}| | | | -_| |  _| -_|   | | | | . |  _| '_|${reset_color}
${fg_bold[red]}|_|_|_|___|_|_| |___|_|_|_____|___|_| |_,_|${reset_color}
EOF
        elif is_screen_running; then
            echo "This is on screen."
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}

tmux_automatically_attach_session
