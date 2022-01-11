---
title: miniconda安装与配置
author: Payne
tags:
  - conda
categories:
  - - miniconda
    - conda
    - python
date: 2022-01-10 13:29:40
---


在科学计算、深度学习、机器学习等领域 Python 语言拥有举足轻重的地位,Python 开发环境,相关链接如下： 
- PyPi(第三方库)地址： https://pypi.org/

- Anconda 官方地址： https://www.anaconda.com/

- Anconda 官方文档： https://docs.conda.io/projects/conda/en/latest/userguide/install/index.html

- Anconda 下载地址： https://www.anaconda.com/products/individual#Downloads

- Anconda Installer repo: https://repo.anaconda.com/archive/

- Miniconda 下载地址：https://docs.conda.io/en/latest/miniconda.html

- Miniconda Installer repo: https://repo.anaconda.com/miniconda/

安装 Python 的方式有很多种，但根据所需，Anconda 无疑是最好的选择。在这里以 Miniconda 为例，在 Windows、macOS 平台下的安装。

## 安装

```sh
# Mac x86
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh && sh Miniconda3-latest-MacOSX-x86_64.sh 
# Mac m1
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh && sh Miniconda3-latest-MacOSX-arm64.sh 
# Linux
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && sh Miniconda3-latest-Linux-x86_64.sh
```

> 点击此[Windows](https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe) 下载安装程序

## 配置终端显示

### Linux or Mac

```sh
conda config --set auto_activate_base false
```

### Windows

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
conda init --all
conda config --set changeps1 false
conda config --set auto_activate_base false
```

> 注意: 需要在管理员权限下

## 设置镜像源

不得不说`Anconda`是个非常不错的科学计算包管理工具（当然不限与Python，而笔者主要用conda来管理虚拟环境等），使用conda来管理的时 候难免会遇到国外网络的各种意外。对于此最简单的方法就是使用咱们国内的镜像源。使用方式如下

```bash
# 增加 镜像地址
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
```

**查看配置**

```
conda config --show-sources
```

![image-20211206140953931](https://tva1.sinaimg.cn/large/008i3skNgy1gx43066thhj30i503qwes.jpg)

当然也可以通过配置文件` .condarc`来修改，但笔者并不建议。在此遍不再过多赘述。