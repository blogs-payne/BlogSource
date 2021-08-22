---
title: 执行一条SQL，这之间到底发生了啥？
author: Payne
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 11430
date: 2021-01-03 21:26:58
---
### MySQL模型初探

MySQL基础结构是采用典型的C/S工作模型(即是server/client)
<!--more-->
以sshd与xshell为例,如下图所示

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gm9saa2hxxj30s60f0wfd.jpg)

## MySQL客户端实例：

MySQL客户端主要有以下功能

- 连接数据库
- 发送指令

### 连接数据库

socket连接方式与远程TCP/IP连接

在Linux中`/etc/my.cnf`文件中显示（已完成MySQL的安装）

```sh
socket= /tmp/MySQL.sock

# 示例如下
root@ecs-dc8a-0003:~# cat /etc/my.cnf                                                                                        
[client]
#password       = your_password
port            = 3306
socket          = /tmp/MySQL.sock

[MySQLd]
port            = 3306
socket          = /tmp/MySQL.sock
datadir = /www/server/data
default_storage_engine = InnoDB
performance_schema_max_table_instances = 400
table_definition_cache = 400
skip-external-locking
key_buffer_size = 1024M

---略
```

### 连接MySQL的两种方式实现

```sh
way1: # 只能在本地使用，不依靠ip地址与端口号
在本地可直接使用如下命令进行scoket连接	
MySQL -S /tmp/MySQL.sock

way2: # “远程”连接(基于TCP/IP)
MySQL -h ip -P 3306 -u username -p passwd
```

> 常用参数示例:
>
> `-S`:	指定socker文件
>
> `-h`:   指定连接ip地址
>
> `-P`：指定连接端口号，默认为3306
>
> `-u`:  指定连接用户名
>
> `-p	指定连接密码

### 发送指令

即发送操作数据库指令(SQL语句)

> **SQL种类**
>
> DDL 数据定义语言
>
> DCL 数据控制语言
>
> DML 数据操作语言
>
> DQL 数据查询语言



## 服务器端(实例):

实例：My sqld + 工作线程 + 预分配内存 

功能：管理数据(增删改查等)

### MySQLd工作模型

MySQLd的工作模型可分为两块，`server`层，`引擎层`，server层可细分为`连接层`、`SQL层`

![MySQLd工作模型](https://tva1.sinaimg.cn/large/0081Kckwgy1gmace22omuj30em0jit8k.jpg)

### 连接层：提供连接

1. 提供可连接协议，例如（TCP/IP， socket）
2. 验证用户名密码等连接
3. 提供专用的连接线程

在MySQL命令行中使用`show processlist;`查看连接线程,如下所示

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmacry3p4cj31p608wab1.jpg)

### SQL层：执行SQL

1. 验证SQL语句(语法检查)
2. 语意(SQL语句种类，DDL，DCL，DML，DQL)
3. 权限验证
4. 解析器：解析预处理，列举所有可行的方案
5. 优化器：MySQL会采用自己的估价函数去预估选择"最优执行"方法
6. 执行器：执行其按照优化器选择执行SQL语句
7. 日志记录(bingo二进制日志\glog，默认不开启。需人工开启)

MySQL中有查询缓存这么一说(query_cache,默认不开启)，当业务量有大量相同的查询等操作，我们一般采用Redis进行一个缓存.

### 存储引擎层

相当于Linux中文件系统，与磁盘交互的模块

## SQL语句执行流程

那么各层之间有什么作用呢？请听我细细说来，在这样我们使用一条SQL语句执行流程来理解一下此流程。

当需要执行SQL语句的时候，必然需要服务端（MySQLd）存在，那么我们无论如何是需要首先开启MySQLd的服务

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmahqqq935j31000sgwj9.jpg)

### 服务端开启

首先开启MySQL服务即(MySQLd),成功开启此服务后，主要体现为`MySQLd实例`，开启工作线程，向系统申请内存(此内存为预分配内存，一旦分配无论使用与否，其他应用均不可使用)

MySQLd开启后，打开server层 存储引擎层，其中server层中连接层提供连接，sql层准备接受客户端指令，存储引擎层与系统磁盘交互。至此MySQLd服务开启成功

### 客户端连接

假设MySQL服务端启动完成之后，我们可以采用`TCP/IP`或者`socket`协议连接MySQL数据库。那么我们此时便发起连接请求。输入以下连接命令

```sh
MySQL -h ip -P 3306 -u username -p passwd
```

服务端接受到连接请求，将会进行以下几步操作。(发生在服务端，肉眼无法直接看见)

首先会验证连接请求的账号与密码。去MySQL.user表中去寻找账号名，账号名不存在断开连接，账号存在下一步寻找对应加密了的密码。与之对应验证。验证成功后，分配此连接专用的连接线程。并提供服务。

连接成功之后如下所示

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmai4ejkq8j31920gs0us.jpg)

接下来我们，在MySQL的终端上执行如下sql查询语句,它的意思是从MySQL库中的user表查询字段名(表头)为`host,name`的所有内容

```
select host,name from MySQL.user;
```

当MySQLd接收到此指令之后，会进行以下几步操作。

1. 语法检查，如果语法不属于sql语句系列，直接抛出错误，终止执行此语句。若通过之后执行下一步

2. 语义，进一步释意sql语句。若表不存在，字段名不存在。直接抛出错误，终止执行此语句。若通过之后执行下一步

3. 验证`用户权限`，顾名思义，这个没什么好说的

4. 解析预处理，经过层层验证到了此步骤之后，说明此语句是可以被执行的。那么此时MySQLd会采用"演练"枚举列出所有的可执行方案。我们或多或少的知道，需要达到相同的效果，达成的方法有各种各样。此时MySQL会列举出所有的方案。例如，以"select host,name from MySQL.user;"这条SQL语句为例，它可达到目的的方式至少有两种，

   - 方案1.对MySQL下的user表进行全表查询，后截断塞选出user表查询字段名(表头)为`host,name`的所有内容。
   - 方案2.对MySQL下user表字段`host,name`进行查询，后直接输出

   虽然二者执行的结果是一致的但资源消耗却并不是一致的

5. 优化器，经过上一步的解析预处理之后，这一步MySQL会采用直接的估计函数，进行资源损耗的预估，从而选择“最优”

6. 得到优化器的方案选举结果，执行

7. 到存储引擎层申请数据，存储引擎层向磁盘获取数据

8. 查询

9. 查询成功，释放内存

10. 输出

执行成功后，如下所示

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gmaifmwzqfj30mu0ca74v.jpg)

那么到这里你可能会有以下两个疑问

疑问一：

既然MySQL有‘优化器’来帮助我们进行最优的执行方案，那么是否我们的SQL语句只要能正常运行就好了呢？反正它都是“最优的”执行方案。

理论上确实如此，但是实际上却并不一定是这样的。MySQL的优化器仅仅帮我们达到了局部最优，而不是全局最优。类似于“贪心算法”思路，我们得到的最终结果就并不一定是全局最优的。

