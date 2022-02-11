---
title: MySQL的安装与配置
author: Payne
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 1439700985
date: 2021-09-04 23:29:41
---

## Linux平台下MySQL的安装

LSB Version:    :core-4.1-amd64:core-4.1-noarch

Distributor ID:    CentOS

Description:    CentOS Linux release 7.9.2009 (Core)

Release:    7.9.2009

Codename:    Core

ldd (GNU libc) :2.17

### 前置工作

#### 删除mariadb

```
yum remove -y mariadb-libs.x86_64
```

### yum

#### 安装rpm

进入MySQL的[yum仓库](https://dev.mysql.com/downloads/repo/yum/)，如下图所示

![image-20210904233814767](https://tva1.sinaimg.cn/large/008i3skNgy1gu50sz34orj616r0u079a02.jpg)

官方rpm包:    https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

清华镜像rpm包:    https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql80-community-el7/mysql80-community-release-el7-3.noarch.rpm

```
wget -c rpm地址
```

#### 安装yum仓库文件

> 可使用rpm -ivh或是yum localinstall 去安装，两者实质是一样的

```
rpm -ivh mysql80-community-release-el7-3.noarch.rpm
```

#### 安装

```bash
yum install -y  mysql-community-server
```

### 二进制

https://downloads.mysql.com/archives/community/

![image-20210905113818649](https://tva1.sinaimg.cn/large/008i3skNgy1gu5lm5v8toj61aq06wdik02.jpg)

```bash
# 下
wget -c https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
tar zf mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
```

#### 建立用户与授权

```
useradd mysql && usermod -s /sbin/nologin mysql
mkdir -p /opt/databases/mysql && chown -R mysql. /opt/databases/mysql
```

## 配置

```bash
# vim /etc/my.cnf

# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

default-storage-engine=INNODB
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
skip-character-set-client-handshake
secure_file_priv=''
user = mysql
port=8916

[client]
default-character-set=utf8mb4


[mysql]
default-character-set=utf8mb4
```

### 获取初始root密码

```
grep 'temporary password' /var/log/mysqld.log
```

### 创建用户与授权

根据业务、公司情况创建管理员，若公司成员较少，管理员管全局。反之管单库

> 1. root不允许远程连接
> 2. 修改root密码

### 远程连接

授权

```bash
远程登录还需要授权远程登录Mysql默认不允许远程登录，我们需要设置关闭selinux或者防火墙，不关防火墙就开放3306端口；
#放开3306端口
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
```

