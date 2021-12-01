---
title: mac(m1)配置php xdebug
author: Payne
tags:
  - xdebug
  - php
categories:
  - - xdebug
    - php
date: 2021-12-01 17:53:58
---

> 使用 `homebrew` 安装 php@7.4

```shell
# 下载debug
pecl install xdebug
```


```bash
cat >> /opt/homebrew/etc/php/7.4/conf.d/ext-xdebug.ini << EOF
zend_extension="/opt/homebrew/Cellar/php@7.4/7.4.26/pecl/20190902/xdebug.so"
xdebug.remote_enable = On　　//是否运行远程终端，必须开启
xdebug.remote_handler = "dbgp"
xdebug.remote_host = "localhost"
xdebug.remote_port = 9000  //这个端口号要和phpstorm中的保持一致，示例的端口是9001
xdebug.idekey = PHPSTROM　　//调试器关键字
EOF
```