---
title: Linux command多版本设置
author: Payne
tags:
  - Linux command
categories:
  - - command
    - Linux
abbrlink: 2145839287
date: 2022-04-15 02:35:41
---

在Linux上有这样一个需求，需要将Python的默认版本设置为`python3.8` 但由于Linux系统自带的是3.6.那么实现他只需要完成python3.8的安装，以及python命令的指向问题。

python3.8 的安装在此便不再过多赘述，如下命令都可任选其一即可

```bash
sudo yum install -y python38 python38-pip

sudo dnf install -y python38 python38-pip
```



## 修改指向

### alternatives 修改

```bash
alternatives --config python3
```

此时直接输入1，修改即可。如下图所示

![image-20220415024725606](https://tva1.sinaimg.cn/large/e6c9d24egy1h19tu6qge1j218w0ggtak.jpg)

### alternatives --install

```bash
alternatives --install <链接> <名称> <路径> <优先度>
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2
```

### 软链接

```bash
ln -fs /usr/bin/python3.8 /usr/bin/python3
```

