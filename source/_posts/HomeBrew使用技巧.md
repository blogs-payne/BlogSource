---
title: HomeBrew使用技巧
author: Payne
tags:
  - HomeBrew
categories:
  - - HomeBrew
abbrlink: 1872139441
date: 2022-04-04 01:13:22
---

[GitHub](https://github.com/Homebrew/brew)

[HomeBrew官方地址](https://brew.sh/)

[docs](https://docs.brew.sh/)

[docs-Formula-Cookbook](https://docs.brew.sh/Formula-Cookbook#homebrew-terminology)

[brew.idayer](https://brew.idayer.com/)

## Homebrew是什么

Homebrew简单来说他是类似于`yum、apt`,mac的包管理工具，使用它我们可以非常简单、丝滑的下载大部分的包、或者软件

### 安装

```bash
# 官方
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# cdn
/bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install.sh)"
```

完成安装后使用

```bash
brew update && brew upgrade && brew doctor && brew -v
```



## 使用技巧

### 配置阿里云镜像

配置阿里云mirror：https://developer.aliyun.com/mirror/homebrew

完成后记得使用如下命令进行更新

```bash
brew update; brew upgrade; brew cleanup; brew doctor
```



### 防止更新特定的自制配方

如果要避免更新某些公式，可以使用以下brew命令将当前版本保持不变：

```
brew pin [name]
```

当然，您可以取消固定公式以再次对其进行更新：

```
brew unpin [formula]
```



### 基于软连接实现多版本控制

当hombrew中有多个版本时，可以基于`link` or `unlink` 实现包版本的控制

> * 当并不需要配置环境变量时

```bash
brew link [name]
```





## Linux 下Homebrew安装

```bash
# Debian or Ubuntu
sudo apt-get install -y build-essential procps curl file git
# Fedora, CentOS, or Red Hat
sudo yum groupinstall -y 'Development Tools'
sudo yum install -y procps-ng curl file git libxcrypt-compat
```



https://docs.brew.sh/Homebrew-on-Linux#requirements





## TAP

```
homebrew/cask
homebrew/core
homebrew/services
isacikgoz/taps
mongodb/brew
petere/postgresql
shivammathur/php
```

