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

## 安装php

```bash
# homebrew 安装composer、php
brew install composer
```

> 安装composer会自动安装php

## 配置composer

https://developer.aliyun.com/composer

```bash
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
composer self-update
composer diagnose
composer clear
```

### Checking pubkeys: FAIL

```tex
Checking pubkeys: FAIL
Missing pubkey for tags verification
Missing pubkey for dev verification
Run composer self-update --update-keys to set them up
```

打开https://composer.github.io/pubkeys.html，将图中内容放在第一次的input。

![image-20220404021653505](https://tva1.sinaimg.cn/large/e6c9d24egy1h0x352w42mj215w0j60y8.jpg)

将图中内容放在第二次的input。

![image-20220404021716092](https://tva1.sinaimg.cn/large/e6c9d24egy1h0x35f6nmaj21820o2dmo.jpg)

https://github.com/composer/composer/issues/4839



## 配置php

```
brew services restart php
```

## 配置Xdebug

```bash
# 下载xdebug
pecl install xdebug
# 配置xdebug
# set xdebug ini
cat << EOF > /opt/homebrew/etc/php/8.1/conf.d/ext-xdebug.ini
[xdebug]
zend_extension = "/opt/homebrew/Cellar/php/8.1.4/pecl/20210902/xdebug.so"
xdebug.mode = "debug"
xdebug.remote_mode = "req"
;是否开启远程调试自动启动
xdebug.remote_autostart = 1
;是否开启远程调试
xdebug.remote_enable = 1
;允许调试的客户端IP
xdebug.remote_host= "localhost"
;远程调试的端口（默认9000）
xdebug.remote_port = 9001
;调试插件dbgp
xdebug.remote_handler="dbgp"
;是否收集变量
xdebug.collect_vars = 1
;是否收集返回值
xdebug.collect_return = 1
;是否收集参数
xdebug.collect_params = 1
;是否开启调试内容
xdebug.profiler_enable= 1
;设置php显示的级别长度
xdebug.var_display_max_depth=10
xdebug.idekey = PHPSTROM
EOF
```



## 禁止更新

homebrew更新时会随之将路径打散，在非必要情况建议禁止自动更新php

```bash
brew pin php
```

