---
title: conda增加镜像源
author: Payne
tags:
  - conda
categories:
  - - conda
    - 镜像
abbrlink: 3280426682
date: 2021-12-06 14:02:44
---



不得不说`Anconda`是个非常不错的科学计算包管理工具（当然不限与Python，而笔者主要用conda来管理虚拟环境等），使用conda来管理的时候难免会遇到国外网络的各种意外。对于此最简单的方法就是使用咱们国内的镜像源。使用方式如下

> 个人配置

```bash
# 增加 镜像地址
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/

# 查看
conda config --show-sources
```

![image-20211206140953931](https://tva1.sinaimg.cn/large/008i3skNgy1gx43066thhj30i503qwes.jpg)

当然也可以通过配置文件` .condarc`来修改，但笔者并不建议。在此遍不再过多赘述。





瑞思拜～
