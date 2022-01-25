---
title: 新一代vim-neovim
author: Payne
tags:
  - neovim
categories:
  - - neovim
    - vim
    - Linux
date: 2022-01-25 10:46:27
---

## 安装

```bash
# 普通安装
brew install neovim
# 开发版本安装
brew install --HEAD luajit
brew install --HEAD neovim
# 包安装
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
tar xzf nvim-macos.tar.gz
./nvim-osx64/bin/nvim
# 验证安装
nvim --version
```

熟悉的所有Vim命令都可以在Neovim中使用，Neovim的配置文件格式也与Vim相同。不过，.vimrc在Neovim中不会自动加载。Neovim的配置文件遵守XDG基本目录结构，即所有的配置文件都放在`~/.config`目录中。Neovim的配置文件被保存在`~/.config/nvim`中

- `~/.config/nvim/init.vim`对应于`~/.vimrc`。

- `~/.config/nvim/`对应于`~/.vim/`。

## 基本配置

当然可以将Neovim的配置文件链接到Vim的配置文件

```bash
# 创建配置文件夹
mkdir -p $HOME/.config
# 创建文件夹软连接
ln -s $HOME/.vim $HOME/.config/nvim
# 创建配置文件软连接
ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim
```

## 初次使用neovim

当在终端输入`nvim `时，将展示如下界面

![image-20220125112813654](https://tva1.sinaimg.cn/large/008i3skNgy1gyprbge7raj30m50930te.jpg)

使用`shfit + :` 并输入`checkhealth`进行依赖检查

```bash
python3 -m pip install neovim
npm install -g neovim
cpan Neovim::ext
```

Neovim的默认选项与Vim有很大的不同。在现代的计算机世界里，文本编辑器的默认值需要对用户比较友好。默认情况下Vim的.vimrc文件并不包含任何默认设置，而Neovim默认已经设置好语法高亮、合理的缩进设置、wildmenu、高亮显示搜索结果和增量搜索（incsearch）等。可通过查看`:help nvim-defaults`了解Neovim的默认选项。

我的配置：https://github.com/Payne-Wu/Bracket/blob/master/SystemInitialization/Vim/vimrc
