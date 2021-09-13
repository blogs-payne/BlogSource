---
title: MySQL存储引擎
author: Payne
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 1336292242
date: 2021-09-10 02:21:20
---

> Server version:  8.0.20 Source distribution

`SHOW ENGINES`

| Engine             | Support | Comment                                               | Transactions | XA     | Savepoints |      |
| :----------------- | :------ | :---------------------------------------------------- | :----------- | :----- | :--------- | ---- |
| FEDERATED          | NO      | Federated MySQL storage engine                        | *NULL*       | *NULL* | *NULL*     |      |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary... | NO           | NO     | NO         |      |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and fore... | YES          | YES    | YES        |      |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                    | NO           | NO     | NO         |      |
| MyISAM             | YES     | MyISAM storage engine                                 | NO           | NO     | NO         |      |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                 | NO           | NO     | NO         |      |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it... | NO           | NO     | NO         |      |
| CSV                | YES     | CSV storage engine                                    | NO           | NO     | NO         |      |
| ARCHIVE            | YES     | Archive storage engine                                | NO           | NO     | NO         |      |

MySQL中常用的存储引擎有InnoDB、MyISAM、MEMORY、ARCHIVE和CSV

## 存储引擎

### InnoDB存储引擎

支持事务
锁级别为行锁，比MyISAM存储引擎支持更高的并发
能够通过二进制日志恢复数据
支持外键操作
在索引存储上，索引和数据存储在同一个文件中，默认按照B+Tree组织索引的结构。同时，主键索引的叶子节点存储完整的数据记录，非主键索引的叶子节点存储主键的值。

**在MySQL 5.6版本之后，默认使用InnoDB存储引擎。**

**在MySQL 5.6版本之后，InnoDB存储引擎支持全文索引。**



### MyISAM存储引擎

不支持事务。

锁级别为表锁，在要求高并发的场景下不太适用。

如果数据文件损坏，难以恢复数据。

不支持外键。

在索引存储上，索引文件与数据文件分离。

支持全文索引。



### MEMORY存储引擎

不支持TEXT和BLOB数据类型，只支持固定长度的字符串类型。例如，在MEMORY存储引擎中，会将VARCHAR类型自动转化成CHAR类型。

锁级别为表锁，在高并发场景下会成为瓶颈。

通常会被作为临时表使用，存储查询数据时产生中间结果。

数据存储在内存中，重启服务器后数据会丢失。如果是需要持久化的数据，不适合存储在MEMORY存储引擎的数据表中。



### ARCHIVE存储引擎

支持数据压缩，在存储数据前会对数据进行压缩处理，适合存储归档的数据。

只支持数据的插入和查询，插入数据后，不能对数据进行更改和删除，而只能查询。

只支持在整数自增类型的字段上添加索引。



### CSV存储引擎

主要存储的是csv格式的文本数据，可以直接打开存储的文件进行编辑。

可以将MySQL中某个数据表中的数据直接导出为csv文件，也可以将.csv文件导入数据表中。



https://dev.mysql.com/doc/refman/8.0/en/storage-engines.html


https://dev.mysql.com/doc/refman/8.0/en/innodb-storage-engine.html
