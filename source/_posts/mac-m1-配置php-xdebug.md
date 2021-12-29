---
title: mac(m1)配置php xdebug
author: Payne
tags:
  - xdebug
  - php
categories:
  - - xdebug
    - php
abbrlink: 4294103192
date: 2021-12-01 17:53:58
---

```shell
# 使用 `homebrew` 安装 php@7.4
brew install php@7.4
# 下载debug
pecl install xdebug
```

```bash
cat >> /opt/homebrew/etc/php/7.4/conf.d/ext-xdebug.ini << EOF
zend_extension = "/opt/homebrew/Cellar/php@7.4/7.4.27/pecl/20190902/xdebug.so"
xdebug.mode = debug
xdebug.remote_handler = dbgp
xdebug.xdebug.client_port = 9000
xdebug.idekey = PHPSTROM
EOF
```