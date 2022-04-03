---
title: 新mac使用技巧入门指北
author: Payne
tags:
  - Mac
categories:
  - - Mac
    - HomeBrew
    - zsh
    - terminal
abbrlink: 34489
date: 2021-04-26 19:59:17
---
## HomeBrew

[HomeBrew官方地址](https://brew.sh/)

[brew.idayer](https://brew.idayer.com/)

简单来说他是类似于`yum、apt`,mac的包管理工具，使用它我们可以非常简单、丝滑的下载大部分的包、或者软件

第一次可以尝试使用如下命令进行安装

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

由于种种原因，如果安装不上，可以使用华科大的源进行安装

```shell
/bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install.sh)"
```

安装完成后，检查一下

```bash
brew update && brew upgrade && brew doctor
```

设置

```bash
git -C "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core" remote set-url origin https://github.com/Homebrew/homebrew-core
```



## 定制zsh编辑器

原生的mac，zsh是没有命令提示的，以及显示也并没有那么好看。自定制一下,终端建议使用`iterm2`

下载`iterm2`

```bash
brew install --cask iterm2
```



#### 下载oh-my-zsh

```sh
# curl 安装方式
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# wget 安装方式
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

#### 复制 .zshrc

```shell
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

#### 修改默认 shell(可选)

```sh
chsh -s /bin/zsh
```

在终端中新建一个窗口(快捷键：command + n），你就发现不一样的shell，如下图所示

![image-20210426191816929](https://tva1.sinaimg.cn/large/008i3skNly1gpxd433qdsj317o0e0wes.jpg)



#### 安装插件

```shell
# zsh-autosuggestions 提供自动补全功能
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# zsh-syntax-highlighting 语法高亮
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# git-open 插件 提供 快捷打开远程地址 git open
git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open

# zsh-z z -h
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
```

`.zshrc` 文件如下

```bash
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="random"

HISTSIZE=999999
HISTFILESIZE=999999
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# gitopen: git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open
# zsh-z: git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
# zsh-autosuggestions: git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
# zsh-syntax-highlighting: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
plugins=(
    rails
    git
    adb
    textmate
    lighthouse
    bundler
    dotenv
    macos
    rake
    rbenv
    git-open
    zsh-z
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR='nvim'

# Compilation flags
export ARCHFLAGS="-arch arm64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"
alias cp='cp -i'
alias mv='mv -i'
alias vim="nvim"
alias brewski='brew update; brew upgrade; brew cleanup; brew doctor'
alias pyfmt='fd . -e py | xargs black'
alias gofmtl='fd . -e go | xargs gofmt -w'
alias cls='clear'

# util
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export GUILE_TLS_CERTIFICATE_DIRECTORY=/opt/homebrew/etc/gnutls/
. /opt/homebrew/etc/profile.d/z.sh
export PATH="/opt/homebrew/opt/bc/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
source /opt/homebrew/opt/git-extras/share/git-extras/git-extras-completion.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/payne/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/payne/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/payne/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/payne/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# kubectl completion
source <(kubectl completion zsh)
source <(helm completion zsh)

# program env 
## php
export PATH="/opt/homebrew/opt/php@8.1/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.1/sbin:$PATH"

## node
export PATH="/opt/homebrew/opt/node@14/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@14/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@14/include"

## go
# export PATH="/opt/homebrew/opt/go@1.17/bin:$PATH"
export GOROOT="/opt/homebrew/opt/go@1.17/bin"
export GOPATH="/Users/payne/Workspace/go"
export GOBIN="${GOPATH}/bin"
export PATH="${GOROOT}:${GOBIN}:${GOPATH}:$PATH"

## HOMEBREW
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
```



### 自动补全

```shell
# zsh
source <(kubectl completion zsh)
# bash (需要下载bash-completion)
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
```

