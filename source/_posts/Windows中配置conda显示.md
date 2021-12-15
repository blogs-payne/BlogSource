---
title: Windows中配置conda显示
author: Payne
tags:
  - powershell
  - conda
categories:
  - - powershell
    - windows
    - conda
abbrlink: 2192683752
date: 2021-11-06 04:41:32
---

> 由于我更加习惯使用Powershell，所以在这里均在powershell中配置。
> 
> 毕竟如果使用cmd来进行操作，体验并不是那么好。
> 尤其是当你习惯了Linux Shell 之后。 

在 Windows中对于conda的显示并不友好，为此需要对

powershell 进行一些设置使conda在Windows平台上也有个非常不错的
体验。相关设置如下

首先使用 管理员身份打开powershell，执行以下代码

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
conda init --all
conda config --set changeps1 false
conda config --set auto_activate_base false
```
