#!/bin/bash

# Utility path
UPATH=$HOME/.myutils

# Fish
function fish_conf() {
    mkdir -p ~/.config/fish
    ln -s $UPATH/config/fish/config.fish ~/.config/fish/config.fish
    ln -s $UPATH/config/fish/functions ~/.config/fish/functions
    ln -s $UPATH/config/starship.toml ~/.config/starship.toml
    # Install omf
    curl -L https://get.oh-my.fish | fish
    omf install autojump fzf fzf-autojump
    omf install https://github.com/jhillyerd/plugin-git
    # Install fzf if needed
    # git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    # ~/.fzf/install
}

# Neovim
function nvim_conf() {
    mkdir -p ~/.config/nvim
    ln -s $UPATH/config/nvim/init.vim ~/.config/nvim/init.vim
    # I also want it to be shared with fallback vim
    ln -s $UPATH/config/nvim/init.vim ~/.vimrc
    # Install vim-plugged, need to run `nvim +PlugInstall` manually
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

# Tmux
function tmux_conf() {
    ln -s $UPATH/config/tmux/tmux.conf ~/.tmux.conf
}

# Alacritty
function alacritty_conf() {
    local name
    if [[ $(uname -s) == "Darwin" ]]; then
        name=macos
    else
        name=linux
    fi

    mkdir -p ~/.config/alacritty
    ln -s $UPATH/config/alacritty/${name}.yml ~/.config/alacritty/alacritty.yml
}

# Git
function git_conf() {
    git config --global core.editor nvim
    git config --global merge.conflictstyle diff3
    git config --global mergetool.vimdiff.path $(which nvim)
    git config --global merge.tool 'vimdiff'
    git config --global commit.gpgsign true
    git config --global user.signingkey 3DBB35F87E3E0A51
    # git config --global https.proxy socks5h://127.0.0.1:1080
    git config --global user.email yangyiwei2000@gmail.com
    git config --global user.name victoryang00
    git config --global core.excludesfile ~/.gitignore_global
    echo ".DS_Store" >> ~/.gitignore_global

    # Useful commands:
    # git rebase --exec
}

function main() {
    fish_conf
    nvim_conf
    tmux_conf
    git_conf
    alacritty_conf
}

main
