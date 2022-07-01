---
title: 初探nginx
author: Payne
tags:
  - nginx
categories:
  - - nginx
abbrlink: 1492784679
date: 2022-03-02 02:19:16
---

[开源官方网站](https://nginx.org/)

[下载界面](https://nginx.org/en/download.html)

[官方文档](https://nginx.org/en/docs/)

[openresty](http://openresty.org/en/)

[商业nginx](https://nginx.com/)

[商业openresty](http://openresty.com)

## 什么是Nginx

**Nginx** **(engine x)** 是一款轻量级的Web 服务器 、反向代理服务器及电子邮件（IMAP/POP3）代理服务器。

**反向代理：**

反向代理（Reverse
Proxy）方式是指以代理服务器来接受internet上的连接请求，然后将请求转发给内部网络上的服务器，并将从服务器上得到的结果返回给internet上请求连接的客户端，此时代理服务器对外就表现为一个反向代理服务器。

**正向代理:**

是一个位于客户端和原始服务器(origin server)之间的服务器，为了从原始服务器取得内容，客户端向代理发送一个请求并指定目标(原始服务器)，然后代理向原始服务器转交请求并将获得的内容返回给客户端。客户端才能使用正向代理。

### 正向代理和反向代理区别？

**正向代理**，**是在客户端的。**比如需要访问某些国外网站，我们可能需要购买vpn。并且**vpn是在我们的用户浏览器端设置的**(并不是在远端的服务器设置)。浏览器先访问vpn地址，vpn地址转发请求，并最后将请求结果原路返回来。

**反向代理是作用在服务器端的，是一个虚拟ip(VIP)**。对于用户的一个请求，会转发到多个后端处理器中的一台来处理该具体请求。

## 为什么是Nginx？

互联网数据量快速增长，高并发

摩尔定律：性能提升

比Apache(一个连接对应一个进程)更快

### Nginx优点

- 高并发、高性能
- 可拓展性好（插件）
- 高可靠
- 热部署
- BSD认证

## Nginx 主要使用场景

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1gzuy18sw32j20j50hrdh4.jpg" alt="image-20220302040819009" style="zoom:50%;" />



<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1gzuy0uhn4zj20lz0l3dgt.jpg" alt="image-20220302040819009" style="zoom:50%;" />

## Nginx组成

- Nginx，二进制可执行文件
- Nginx config 配置文件： 控制nginx行为
- access log : 记录每一条请求
- error log：错误日志

## Nginx 版本

Mainline version：主线版本，最新功能等

Stable version：稳定版，

Legacy versions：历史版本

[tenginx](http://tengine.taobao.org/)

[nginx各版本更新日志](https://nginx.org/en/CHANGES)

- Bugfix： 修复bug
- Change： 修改
- Feature： 新特性

## 编译安装Nginx

安装Nginx 通常有两张方式，其一，那便是使用包管理工具如`yum`、`apt-get`、`homebrew`、`winget`等直接安装，而另外一种便是编译安装。

个人推荐使用编译安装，其主要原因为可以将各组件一起编译生成，兼容其强大的生态。

```bash
# Download
curl -OC - https://nginx.org/download/nginx-1.20.2.tar.gz
# unzip
tar -xzf nginx-1.20.2.tar.gz && cd nginx-1.20.2
# 编译(默认参数)
# yum -y install gcc gcc-c++ make libtool zlib zlib-devel openssl openssl-devel pcre pcre-devel
./configure --prefix=/opt
# 编译
make 
# 安装
make install
```

```bash
./configure --prefix=/usr/local/nginx 
  --pid-path=/var/run/nginx/nginx.pid 
  --lock-path=/var/lock/nginx.lock 
  --error-log-path=/var/log/nginx/error.log 
  --http-log-path=/var/log/nginx/access.log 
  --with-http_gzip_static_module 
  --http-client-body-temp-path=/var/temp/nginx/client 
  --http-proxy-temp-path=/var/temp/nginx/proxy 
  --http-fastcgi-temp-path=/var/temp/nginx/fastcgi 
  --http-uwsgi-temp-path=/var/temp/nginx/uwsgi 
  --http-scgi-temp-path=/var/temp/nginx/scgi
```

相关参数

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1gzv31s7hj2j20qq0d0js5.jpg" alt="1051646169511_.pic"/>

## nginx源码目录结构

```bash
drwxr-xr-x 6 1001 1001   4096 Mar  2 03:09 auto: 编译时所用
-rw-r--r-- 1 1001 1001 312251 Nov 16 22:44 CHANGES：版本变更
-rw-r--r-- 1 1001 1001 476577 Nov 16 22:44 CHANGES.ru：版本变更（俄语）
drwxr-xr-x 2 1001 1001   4096 Mar  2 03:09 conf nginx配置示例文件
-rwxr-xr-x 1 1001 1001   2590 Nov 16 22:44 configure：用来生产中间文件，执行编译前的必备动作
drwxr-xr-x 4 1001 1001   4096 Mar  2 03:09 contrib：vim工具，
drwxr-xr-x 2 1001 1001   4096 Mar  2 03:09 html: 500错误，index.html
-rw-r--r-- 1 1001 1001   1397 Nov 16 22:44 LICENSE
drwxr-xr-x 2 1001 1001   4096 Mar  2 03:09 man: nginx 帮助文件
-rw-r--r-- 1 1001 1001     49 Nov 16 22:44 README：
drwxr-xr-x 9 1001 1001   4096 Nov 16 22:44 src： nginx源代码

---
# tree . -d 1

├── auto
│   ├── cc：用于编译
│   ├── lib：外部目录
│   │   ├── geoip
│   │   ├── google-perftools
│   │   ├── libatomic
│   │   ├── libgd
│   │   ├── libxslt
│   │   ├── openssl
│   │   ├── pcre
│   │   ├── perl
│   │   └── zlib
│   ├── os: 操作系统判断
│   └── types
├── conf: 配置文件示意
├── contrib
│   ├── unicode2nginx
│   └── vim
│       ├── ftdetect
│       ├── ftplugin
│       ├── indent
│       └── syntax
├── html
├── man
└── src
    ├── core
    ├── event
    │   └── modules
    ├── http
    │   ├── modules
    │   │   └── perl
    │   └── v2
    ├── mail
    ├── misc
    ├── os
    │   └── unix
    └── stream
```

tips

将 contrib 中的文件夹copy 到vim目录下，以便于使用vim对配置文件等进行便捷的编辑，如下command

```bash
DIR="ftdetect ftplugin indent syntax"
for dir in $DIR; do
	mkdir -p ~/.vim/${dir}
  cp -r contrib/vim/${dir}/nginx.vim ~/.vim/${dir}/nginx.vim
done
```

## Nginx 配置

### 语法

- 配置文件由指令与指令块构成
- 每条指令以`;` 结尾，指令与参数之间以空格符号分割
- 指令块以`{}` 将多条指令组织在一起
- include语句允许组合多个配置文件，提升可维护性
- `#`: 实现注释
- `$`:使用变量
- 部分指令支持regexp， 如路径匹配等

### 参数

**时间**

- ms: MilliSeconds
- s: Seconds
- m: minutes
- h: hours
- d: days
- w: weeks
- m: months
- years

**存储空间**

bytes (default)

k/K: kilobytes

m/M: megabytes

g/G: gigabytes

### 配置指令块

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1gzv0wsgmh8j20va0kzwfu.jpg" alt="image-20220302040819009" style="zoom:50%;" />

http: 表示所有的指令都是http解析的

```nginx
http {
	include mine.types
  # 上游服务
	upstream thwp {
		server 127.0.0.1:8080
	}
  # (一组)域名
  server {
    listen 80 
    location ～*.(gif|jpg|jpeg)$ {
      
  }
  }
}
```

### 配置实践

**配置upstream**

```nginx
http {
  // proxycluster: 服务组名字
  upstream proxycluster {
    server 10.21.200.101:8081;
    server 10.21.200.121:8081;
    server 10.21.200.111:8081;
    server 10.21.200.191:8081;
  }
  
  server {
		listen 8081;
    location / {
    proxy_pass http://proxycluster;
    auth_basic "Restricted";
  }
}

```

weight=number: 服务器的权重值，默认是1；

max_conns=number: 设置允许的最大活动连接数。默认是0，表示不限制。（设置`keepalive`时，如果有多个worker共享内存，则连接数可能会超过设置的值）

max_fails=number: 设置在`fail_timeout`参数设置的时间段内允许的失败最大尝试次数，默认是1，设置0表示失败不会尝试。

fail_timeout=time: `fail_timeout`的值包含两层意思：

1. 在这个时间段内服务器通信失败次数决定服务状态是否为不可用；

2. 服务器被视为不可用状态的时间段。默认是10秒。

backup: 标记服务器是备用服务器，只有在其他服务器都不可用的情况下，才会请求该服务器。（在哈希、IP哈希、随机三种负载均衡模式下不可用）

down: 标记服务器永久不可用状态。

[正则表达式匹配路由](https://developer.aliyun.com/article/753379)
