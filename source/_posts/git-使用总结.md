---
title: git 使用总结
author: Payne
tags:
  - git
categories:
  - - git
date: 2022-02-17 13:52:22
---

## git安装

### mac

```bash
brew install git git-lfs
```

### Linux(centos)

```bash
yum install -y git git-lfs
```



## 初始化配置

```bash
git config --global user.name "paynewu"
git config --global user.email "wuzhipeng1289690157@gmail.com"
git config --global credential.helper store
git config --global core.longpaths true
git config --global core.quotepath off
git lfs install --skip-repo
```



