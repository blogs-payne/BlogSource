---
title: MySQL的SQL使用之上
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 3376299280
date: 2021-08-23 22:37:55
---
## SQL介绍

结构化查询语言,5.7 以后符合SQL92严格模式,通过sql_mode参数来控制

DDL（Data Definition Language，数据定义语言）：用于定义数据库、数据表和列，可以用来创建、删除、修改数据库和数据表的结构，包含CREATE、DROP和ALTER等语句。

DML（Data Manipulation Language，数据操作语言）：用于操作数据记录，可以对数据库中数据表的数据记录进行增加、删除和修改等操作，包含INSERT、DELETE和UPDATE等语句。

DCL（Data Control Language，数据控制语言）：用于定义数据库的访问权限和安全级别，主要包含GRANT、REVOKE、COMMIT和ROLLBACK等语句。

DQL（Data Query Language，数据查询语言）：用于查询数据表中的数据记录，主要包含SELECT语句。

## DDL的应用

### 库

#### 增

建库规范：

1. 库名要和业务相关
2. 库名不能有**大写字母**、**数字**开头
3. 建库要加字符集

```dart
create database [if not exists] 数据库名 [charset 字符编码名称] [collate 排序规则];
```

#### 删

> 生产中禁止使用

```dart
drop database 数据库名
```

#### 改

> 先查在改

```dart
SHOW CREATE DATABASE 数据库名;
ALTER DATABASE 数据库名 [charset 字符编码名称] [collate 排序规则];
```

> 注意：修改字符集，修改后的字符集一定是原字符集的严格超集

#### 查（DQL）

显示所有数据库 形式:show databases;

显示一个数据库的创建语句: show create database 数据库名;

其他:show charset; show collation;

当前选择的数据库:\s、select database();

### 表

**创建表规范**

1. 库名需与业务相关，且小写与非数字开头，表、列均需有注释
2. 注意字符集和存储引擎
3. 选择**合适**的**数据类型**
4. 每个列设置为非空，若无法保证非空，用0来填充。

#### 增

```sql
create table [if not exists] 表名(
 字段1 数据类型 [约束条件] [默认值],
 字段2 数据类型 [约束条件] [默认值],
  [表约束条件]
) [表选项1,表选项2]

# example
CREATE TABLE IF NOT EXISTS `ch_people_msg` ( 
  `p_id`  SERIAL NOT NULL AUTO_INCREMENT COMMENT '用户id' , 
  `p_uic` CHAR(18) NOT NULL UNIQUE  COMMENT '用户身份证',
  `p_nickname` VARCHAR(50) NOT NULL COMMENT '用户昵称', 
  `p_gender` ENUM('m','f', 'n') NOT NULL DEFAULT 'n' COMMENT '用户性别', 
  `p_age` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户年龄', 
  `p_pnum` CHAR(11) NOT NULL COMMENT '用户电话', 
  `p_address` VARCHAR(100) NOT NULL COMMENT '用户地址', 
  `p_email` VARCHAR(50) NOT NULL COMMENT '用户邮箱', 
  `p_add_time` TIMESTAMP NOT NULL DEFAULT NOW() COMMENT '统计用户时间',
   PRIMARY KEY (`p_id`)
) ENGINE = InnoDB CHARSET=utf8mb4 COLLATE utf8mb4_generalci_ci COMMENT = '中国成员信息表';
```

> 注意：字段结束为`,`分隔， 整体结束为`)`分隔

####  删除(生产中禁用命令)

DROP TABLE table_name

### 改

```sql
ALTER TABLE table_name [ADD、DROP、MODIFY]
# 增加字段'

## 在表首列加入p_num列

ALTER TABLE `ch_people_msg` ADD p_num INT NOT NULL COMMENT '数字' FIRST;

## 在列p_nickname 后增加 p_wechat列

ALTER TABLE `ch_people_msg` ADD p_wechat VARCHAR(64) NOT NULL UNIQUE  COMMENT '微信号' AFTER `p_nickname`;

## 在表中(最后)增加p_qq列

ALTER TABLE `ch_people_msg` ADD p_qq VARCHAR(20) NOT NULL UNIQUE COMMENT '用户qq号';

# 删除字段

ALTER TABLE table_name DROP 字段名

# 修改
ALTER TABLE `table_name` MODIFY 字段名 约束条件 默认值
```

#### 表属性查询（DQL）

```sql
# 罗列所有表
show tables；

# 查看表状态
show table status [from db_name] [like table_name];

# 查看表结构
desc `table_name`;

# 查看创建表语句
show create table `table_name`;

# 创建相同类型的表
CREATE TABLE `db_name_2` LIKE `db_name_1`;
```