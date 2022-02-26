---
title: 模块化的VimIDE-spacevim
author: Payne
tags:
  - VimIDE-spacevim
categories:
  - - VimIDE-spacevim
    - spacevim
    - vim
abbrlink: 3120335305
date: 2022-02-16 20:36:52
---

SpaceVim 是一个社区驱动的模块化的 Vim IDE，以模块的方式组织管理插件以及相关配置， 为不同的语言开发量身定制了相关的开发模块，该模块提供代码自动补全， 语法检查、格式化、调试、REPL 等特性。用户仅需载入相关语言的模块即可得到一个开箱即用的 Vim IDE。

相关链接如下：

[官方网站](https://spacevim.org/)

[中文官方网站](https://spacevim.org/cn/)

[github](https://github.com/SpaceVim/SpaceVim)

[gitee](https://gitee.com/spacevim/SpaceVim)

[入门指南](https://spacevim.org/cn/quick-start-guide/)

## 安装

>  **前置条件**: 需要安装完成`vim`或`neovim`

```
# 前置安装
## centos
python3 -m pip install -U pip && python3 -m pip install pynvim && pip3 install neovim && yum -y install neovim
## Mac
python3 -m pip install -U pip && python3 -m pip install pynvim && pip3 install neovim && brew install neovim
```



### Windows

Windows 下最快捷的安装方法是下载安装脚本 [install.cmd](https://spacevim.org/cn/install.cmd) 并运行。

### Linux 或 macOS

```bash
# 配置
cat >> /etc/profile << EOF
export EDITOR=nvim
alias vim="nvim"
EOF
source /etc/profile/

# 创建配置文件夹
mkdir -p $HOME/.config
# 创建文件夹软连接
ln -s $HOME/.vim $HOME/.config/nvim
# 创建配置文件软连接
ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim
```



```bash
# 安装
curl -sLf https://spacevim.org/cn/install.sh | bash
# 如果需要获取安装脚本的帮助信息，可以执行如下命令，包括定制安装、更新和卸载等。
curl -sLf https://spacevim.org/cn/install.sh | bash -s -- -h
```

安装结束后，初次打开 vim 或者 neovim 时，SpaceVim 会自动下载并安装插件。

[SpaceVim离线安装 (github.com)](https://github.com/marmotedu/marmotVim)



环境搭建请参考：

[在线教程](https://spacevim.org/cn/quick-start-guide/#在线教程)





更多sao操作情参考官方文档，瑞思拜～
