---
title: MySQL数据库体系结构
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 1647551827
date: 2021-08-21 10:42:42
---

## MySQL体系结构

### C/S(Client/Server)模型

​		C/S结构是一种软件系统体系结构，

​		C是英文单词“Client”的首字母，即客户端的意思，C/S就是“Client/Server”的缩写，即“客户端/服务器”模式。MySQL C/S 可如下图所示

![](https://tva1.sinaimg.cn/large/008i3skNgy1gto7tgqgp1j60js0a8jrl02.jpg)

#### MySQL 连接

实现MySQL连接的方式主要有两种，

- 基于TCP/IP的连接，适用于远程、本地
- 基于Socket方式连接，仅限于本地连接

```sh
# TCP/IP方式（远程、本地）
mysql -h 192.168.0.51 -P 3306 -u root -p paynepasswd

# Socket方式(仅本地)
mysql -S /tmp/mysql.sock -u root -p paynepasswd
```

在Linux中`/etc/my.cnf`文件中显示（已完成MySQL的安装）

```sh
socket=/tmp/mysql.sock

# /etc/my.cnf    示例如下                                                                                    
[client]
#password       = your_password
port            = 3306
socket          = /tmp/mysql.sock

[mysqld]
port            = 3306
socket          = /tmp/mysql.sock
datadir = /www/server/data
default_storage_engine = InnoDB
performance_schema_max_table_instances = 400
table_definition_cache = 400
skip-external-locking
key_buffer_size = 1024M

---略
```

## 服务器端(实例):

实例：My sqld + 工作线程 + 预分配内存 

功能：管理数据(增删改查等)

### mysqld逻辑结构

mysqld的工作模型可分为两块，`server`层，`引擎层`，server层可细分为`连接层`、`SQL层`

![](https://tva1.sinaimg.cn/large/008i3skNgy1gtoa5gogpej60fv0dhjs202.jpg)

#### 连接层

- 提供连接协议（socket、TCP/IP）
- 验证用户（账号名、密码、权限）
- 提供用户专用线程

#### SQL层

- 接收上层传送的SQL语句
- 语法验证模块：验证语句语法,是否满足SQL_MODE
- 语义检查：判断SQL语句的类型(DDL、DCL、DML、DQL)
- 执行权限检查：对语句执行前,进行预处理，生成解析树(执行计划)
- 优化器：根据解析器得出的多种执行计划，进行判断，选择最优的执行计划
          代价模型：资源（CPU IO MEM）的耗损评估性能好坏
- 执行器：根据最优执行计划，执行SQL语句，产生执行结果
- 提供查询缓存（默认是没开启的）常使用redis、tair替代查询缓存功能
- 提供日志记录（日志管理章节）：binlog，默认是没开启的。

#### 存储引擎层

> 类似于Linux中的文件系统

- 负责根据SQL层执行的结果，从磁盘上拿数据
- 将16进制的磁盘数据，交由SQL结构化化成表
- 连接层的专用线程返回给用户

## 数据库逻辑结构

![](https://upload-images.jianshu.io/upload_images/16956686-127fff46fdb7fea9.png)

- 库：库名，库属性
- 表：表名、属性、
  - 列:列名(字段),列属性(数据类型,约束等)
  - 数据行(记录)

![物理结构](https://upload-images.jianshu.io/upload_images/16956686-bfd40838aef7971b.png)

库的物理存储结构

- 用文件系统的目录来存储

表的物理存储结构

```
MyISAM（一种引擎）的表：
-rw-r----- 1 mysql mysql   10816 Apr 18 8:37 user.frm
-rw-r----- 1 mysql mysql     396 Apr 18 11:20  user.MYD
-rw-r----- 1 mysql mysql    4096 Apr 18 17:48 user.MYI

InnoDB(默认的存储引擎)的表：
-rw-r----- 1 mysql mysql    8636 Apr 18 9:37 time_zone.frm
-rw-r----- 1 mysql mysql   98304 Apr 18 1:37 time_zone.ibd
time_zone.frm：存储列相关信息
time_zone.ibd：数据行+索引
```

表的段、区、页（16k）

```undefined
页：最小的存储单元，默认16k
区：64个连续的页，共1M
段：一个表就是一个段，包含一个或多个区
```



## 执行SQL流程

> 假设忽略权限验证、表操作验证

1. 客户端发送一条SQL语句给MySQL服务器。

2. MySQL服务器先检查查询缓存，如果查询缓存中存在待查询的结果数据，则会立刻返回查询缓存中的结果数据，否则执行下一阶段的处理。

3. MySQL服务器通过解析器和预处理器对SQL语句进行解析和预处理，并将生成的SQL语句解析树传递给查询优化器。

4. 查询优化器将SQL解析树进行进一步处理，生成对应的执行计划。

5. MySQL服务器根据查询优化器生成的执行计划，通过查询执行引擎调用存储引擎的API来执行查询操作。

6. 存储引擎查询数据库中的数据，并将结果返回给查询执行引擎。

7. 查询执行引擎将结果保存在查询缓存中，并通过数据库连接/线程处理返回给客户端。

![](https://tva1.sinaimg.cn/large/008i3skNgy1gtoc99udhyj60bw0ma0tu02.jpg)

