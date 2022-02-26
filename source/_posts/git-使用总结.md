---
title: git 使用总结
author: Payne
tags:
  - git
categories:
  - - git
abbrlink: 71891257
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



## git配置初始化

```bash
git config --global user.name "paynewu"
git config --global user.email "wuzhipeng1289690157@gmail.com"
git config --global credential.helper store
git config --global core.longpaths true
git config --global core.quotepath off
git lfs install --skip-repo
```



## 实践

### 初始化repo

```bash
# 创建空的git仓库或重新初始化一个现有的仓库
git init
```

### 添加文件到本地仓库暂存区

```bash
# 将文件添加到暂存区
git add demofile
# 将所有文件添加到暂存区
git add --all
# 保存所有改动的文件和删除的文件，不包括新的文件
git add -u
```

### 添加到本地仓库

```bash
# 此命令代表确认提交到本地仓库。
git commit -m 'v1'

# 将所有暂存区提交到本地仓库。
git commit -am 'v1'
```

> 可以使用 `git status` 查看状态



### 查看提交日志

```bash
# 查看日志
git log

# 一行展示
git log --pretty=oneline

# 参考日志（Reference logs），记录每一次操作
git relog
```

### 版本回退

```bash
# 回退到上一版
git reset --hard HEAD^

# 回退到上上个版本
git reset --hard HEAD^^

# 如果回退的版本过多则不用加那么多的 ^ 号 
# 比如回退到上 10 版本，则可以用
git reset --hard HEAD~10

# 回退到指定hash的分支
git reset --hard hash

```



### 撤销修改

总结： 

- 场景 1：当改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令 git checkout — file。 

- 场景 2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令 git reset HEAD file，就回到了场景 1，第二步按场景 1 操作。 

- 场景 3：已经提交了不合适的修改到版本库时，想要撤销本次提交，进行版本回退，不过前提是没有推送到远程库。 8. 删除文件 假如现在你新建了一个 hello.txt 文件，你已经 add 并 commit 到了本地分支之中。 现在你想删除，如果直接执行





### 分支

```bash
# 查看本地分支
git branch

# 新建本地分支
git branch dev

# 切换到 dev 分支
git checkout dev

# 创建并切换到该分支
git checkout -b dev

# 合并分支
git merge
```



### push

```
git push -u origin branch-name
```



### tag

```bash
# 增加一个标签
git tag -a "v1.0.0" -m "Version 1.0.0"

# 删除一个标签
git tag -d v1.0.0

# 删除远程标签
git push --delete origin v1.0.0

# 推送所有标签
git push origin --tags
```

### 删除未监视文件

```bash
git clean -f
 
# 连 untracked 的目录也一起删掉
git clean -fd
 
# 连 gitignore 的untrack 文件/目录也一起删掉 （慎用，一般这个是用来删掉编译出来的 .o之类的文件用的）
git clean -xfd
 
# 在用上述 git clean 前，墙裂建议加上 -n 参数来先看看会删掉哪些文件，防止重要文件被误删
git clean -nxfd
git clean -nf
git clean -nfd
```



### 子模块

```bash
git clone <repository> --recursive 递归的方式克隆整个项目
git submodule add <repository> <path> 添加子模块
git submodule init 初始化子模块
git submodule update 更新子模块
git submodule foreach git pull 拉取所有子模块
```
