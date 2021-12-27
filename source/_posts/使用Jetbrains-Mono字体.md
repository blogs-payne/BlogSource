---
title: 使用Jetbrains Mono字体
author: Payne
tags:
  - 编程笔记
categories:
  - - Jetbrains Mono
    - Jetbrains
    - Mono
date: 2021-12-27 14:50:19
---

Jetbrains Mono 字体据说是Jetbrains 公司对于开发人员而开发的字体，当然个人觉得也不错，所以在此安装以及使用一波。分别在Jetbrains和VSCode中,Mono 相关链接如下

[Mono](https://www.jetbrains.com/lp/mono/#how-to-install)

[Mono zh-cn](https://www.jetbrains.com/zh-cn/lp/mono/#how-to-install)



## 在Jetbrains编辑器中使用

### 设置

**step 1**

Preferences/Settings -> Editor -> Font，右边字体中选择 `Jetbrains Mono`, 

> 我的设置
>
> Size：13 Line hight：1.2 Enable Ligature

![image-20211227145717002](https://tva1.sinaimg.cn/large/008i3skNgy1gxsee1orkhj30ra0jojtc.jpg)

> Tip: 从 v2019.3 开始，JetBrains IDE 随附了最新版本的 JetBrains Mono。

**step 2**

> 进行了以上的设置之后可能还无法使用，此时我们需要在进一步的设置，如下

Preferences/Settings -> Editor -> Color Scheme -> Color Scheme Font

![image-20211227150734888](https://tva1.sinaimg.cn/large/008i3skNgy1gxseoq1e4nj30ra0jo3zx.jpg)



效果如下

![image-20211227151240648](https://tva1.sinaimg.cn/large/008i3skNgy1gxseu12227j30ol0llabw.jpg)



## 在Vscode中使用

### 下载

![image-20211227152516091](https://tva1.sinaimg.cn/large/008i3skNgy1gxsf74l0goj318q0l7gnh.jpg)

### 安装

![image-20211227152554293](https://tva1.sinaimg.cn/large/008i3skNgy1gxsf7sit6nj30io08474w.jpg)

> 为了兼容性考虑，我建议是全部安装。当然也可仅安装`Regular.tff`也可

## 配置

在配置文件中修改为如下

> 存在即修改，不存在就新增。重启VS code即可

```
  "editor.fontFamily": "JetBrains Mono, Menlo, Monaco, 'Courier New', monospace",
  "editor.fontLigatures": true
```



显示如下所示

![image-20211227153428863](https://tva1.sinaimg.cn/large/008i3skNgy1gxsfgpmnjhj30u50bl0tz.jpg)
