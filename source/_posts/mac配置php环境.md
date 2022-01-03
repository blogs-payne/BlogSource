---
title: mac配置php环境
author: Payne
tags:
  - php
categories:
  - - php
    - xdebug
    - homebrew
abbrlink: 1520202318
date: 2021-12-29 13:48:44
---

```bash
# 使用 `homebrew` 安装 php@7.4
brew install php@7.4
# 下载debug
pecl install xdebug
# set xdebug ini
cat >> /opt/homebrew/etc/php/7.4/conf.d/ext-xdebug.ini << EOF
zend_extension = "/opt/homebrew/Cellar/php@7.4/7.4.27/pecl/20190902/xdebug.so"
xdebug.mode = debug
xdebug.remote_handler = dbgp
xdebug.xdebug.client_port = 9000
xdebug.idekey = PHPSTROM
EOF
```