---
title: MySQL的SQL使用之下
author: Payne
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 3191410054
date: 2021-09-02 21:46:39
---

## mysql用户管理

> DCL（Data Control Language，数据控制语言）：用于定义数据库的访问权限和安全级别，主要包含GRANT、REVOKE、COMMIT和ROLLBACK等语句。

**mysql用户管理主要涉及到用户的增删改查与权限管理**

mysql中存在4个控制权限的表，分别为user表，db表，tables_priv表，columns_priv表

**权限表的验证过程**

1. 先从user表中的Host,User,Password这3个字段中判断连接的ip、用户名、密码是否存在，存在则通过验证。
2. 通过身份认证后，进行权限分配，按照user，db，tables_priv，columns_priv的顺序进行验证。即先检查全局权限表user，如果user中对应的权限为Y，则此用户对所有数据库的权限都为Y，将不再检查db,
   tables_priv,columns_priv；如果为N，则到db表中检查此用户对应的具体数据库，并得到db中为Y的权限；如果db中为N，则检查tables_priv中此数据库对应的具体表，取得表中的权限Y，以此类推。

**MySQL 权限级别**
全局性的管理权限： 作用于整个MySQL实例级别 数据库级别的权限： 作用于某个指定的数据库上或者所有的数据库上 数据库对象级别的权限：作用于指定的数据库对象上（表、视图等）或者所有的数据库对象上

### 用户操作

```mysql
# 创建用户
create user user_name@'host' identified by 'password';
# example: 
# create user acs@'10.0.0.%' identified by '123123';
```

```mysql
# 删除用户
drop user user_name@'host';
# example:
# drop user acs@'10.0.0.%'
# DELETE FROM `user` WHERE `user`.`Host` = '10.0.0.%' AND `user`.`User` = 'acs'
```

```mysql
# 修改用户
alter user user_name@'host' identified by 'password';
# example
## 修改密码
alter user acs@'10.0.0.%' identified by '321312312123';
## 修改 host
UPDATE `user`
SET `Host` = '%'
WHERE `user`.`Host` = '10.0.0.%'
  AND `user`.`User` = 'acs'
## 修改权限
UPDATE `user`
SET `Select_priv` = 'Y'
WHERE `user`.`Host` = '%'
  AND `user`.`User` = 'acs'
UPDATE `user`
SET `Select_priv` = 'Y',
    `Delete_priv` = 'Y'
WHERE `user`.`Host` = '%'
  AND `user`.`User` = 'acs'
```

```mysql
# 删除用户
drop user user_name@'host';
# example
drop user acs@'%'
DELETE
FROM `user`
WHERE `user`.`Host` = '10.0.0.%'
  AND `user`.`User` = 'acs'
```

> user_name：用户名
>
> host ：可允许连接ip(Localhost代表本机， 127.0.0.1代表ipv4本机地址， ::1代表ipv6的本机地址,)
>
> password：用户密码

## 权限管理

权限可细分为操作权限与操作范围

常用权限介绍

```dart
ALL:	SELECT,INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER, CREATE TABLESPACE
ALL : 所有权限，一般是普通管理员拥有的
with grant option：给别的用户授权的功能
```

权限作用范围

```dart
*.*               ---->所有：管理员用户
dbname.*          ---->指定库下所有：开发和应用用户
dbname.t1			---->指定表
```

**开发人员用户授权流程**

1. 你从哪来
2. 对谁操作
3. 权限
4. 密码要求

### 权限

可以使用GRANT给用户添加权限，权限会自动叠加，不会覆盖之前授予的权限，比如你先给用户添加一个SELECT权限，后来又给用户添加了一个INSERT权限，那么该用户就同时拥有了SELECT和INSERT权限

```mysql
# 查看MYSQL有哪些用户
select user, host
from mysql.user;
# 查看权限
show grants for user_name@'host';
```

```mysql
# 授权
grant 权限 on 权限范围 to 用户 identified by 密码 with grant option;
```

**all privileges：**表示将所有权限授予给用户。也可指定具体的权限，如：SELECT、CREATE、DROP等。
**on：**表示这些权限对哪些数据库和表生效，格式：数据库名.表名，这里写“*”表示所有数据库，所有表。如果我要指定将权限应用到test库的user表中，可以这么写：test.user
**to：**将权限授予哪个用户。格式：”用户名”@”登录IP或域名”。%表示没有限制，在任何主机都可以登录。比如：”payne”@”192.168.0%”，表示yangxin这个用户只能在192.168.0IP段登录
**•identified by：**指定用户的登录密码
**•with grant option：**表示允许用户将自己的权限授权给其它用户

```mysql
# 收回权限
revoke delete on 权限范围 from 用户@‘host’
revoke delete on app.* from app@'10.0.0.%'；
```

### 如何授权

用户的权限一定是与业务分离不开的，但通常普通用户会

- 禁用删除权限
- 规定范围

## 如何做好用户管理

- 密码系数足够高
- root禁用远程登录
- 分级别，类似于公司管理。

## 注意

```undefined
8.0在grant命令添加新特性
建用户和授权分开了
grant 不再支持自动创建用户了，不支持改密码
授权之前，必须要提前创建用户。
```

- 执行Grant,revoke,set password,rename user命令修改权限之后， MySQL会自动将修改后的权限信息同步加载到系统内存中
- 如果执行insert/update/delete操作上述的系统权限表之后，则必须再执行刷新权限命令才能同步到系统内存中，刷新权限命令包括： `flush privileges`/mysqladmin flush-privileges /
  mysqladmin reload
- 如果是修改tables和columns级别的权限，则客户端的下次操作新权限就会生效
- 如果是修改database级别的权限，则新权限在客户端执行use database命令后生效
- 如果是修改global级别的权限，则需要重新创建连接新权限才能生效
- 如果是修改global级别的权限，则需要重新创建连接新权限才能生效 (例如修改密码)

mysql user表

| **名字**                 | **类型**                          | Null | 主键 | 默认                  |      |      |
| :----------------------- | :-------------------------------- | :--- | :--- | :-------------------- | :--- | ---- |
| Host                     | char(255)                         | NO   | PRI  |                       |      |      |
| User                     | char(32)                          | NO   | PRI  |                       |      |      |
| Select_priv              | enum('N','Y')                     | NO   |      | N                     |      |      |
| Insert_priv              | enum('N','Y')                     | NO   |      | N                     |      |      |
| Update_priv              | enum('N','Y')                     | NO   |      | N                     |      |      |
| Delete_priv              | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_priv              | enum('N','Y')                     | NO   |      | N                     |      |      |
| Drop_priv                | enum('N','Y')                     | NO   |      | N                     |      |      |
| Reload_priv              | enum('N','Y')                     | NO   |      | N                     |      |      |
| Shutdown_priv            | enum('N','Y')                     | NO   |      | N                     |      |      |
| Process_priv             | enum('N','Y')                     | NO   |      | N                     |      |      |
| File_priv                | enum('N','Y')                     | NO   |      | N                     |      |      |
| Grant_priv               | enum('N','Y')                     | NO   |      | N                     |      |      |
| References_priv          | enum('N','Y')                     | NO   |      | N                     |      |      |
| Index_priv               | enum('N','Y')                     | NO   |      | N                     |      |      |
| Alter_priv               | enum('N','Y')                     | NO   |      | N                     |      |      |
| Show_db_priv             | enum('N','Y')                     | NO   |      | N                     |      |      |
| Super_priv               | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_tmp_table_priv    | enum('N','Y')                     | NO   |      | N                     |      |      |
| Lock_tables_priv         | enum('N','Y')                     | NO   |      | N                     |      |      |
| Execute_priv             | enum('N','Y')                     | NO   |      | N                     |      |      |
| Repl_slave_priv          | enum('N','Y')                     | NO   |      | N                     |      |      |
| Repl_client_priv         | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_view_priv         | enum('N','Y')                     | NO   |      | N                     |      |      |
| Show_view_priv           | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_routine_priv      | enum('N','Y')                     | NO   |      | N                     |      |      |
| Alter_routine_priv       | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_user_priv         | enum('N','Y')                     | NO   |      | N                     |      |      |
| Event_priv               | enum('N','Y')                     | NO   |      | N                     |      |      |
| Trigger_priv             | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_tablespace_priv   | enum('N','Y')                     | NO   |      | N                     |      |      |
| ssl_type                 | enum('','ANY','X509','SPECIFIED') | NO   |      |                       |      |      |
| ssl_cipher               | blob                              | NO   |      | *NULL*                |      |      |
| x509_issuer              | blob                              | NO   |      | *NULL*                |      |      |
| x509_subject             | blob                              | NO   |      | *NULL*                |      |      |
| max_questions            | int unsigned                      | NO   |      | 0                     |      |      |
| max_updates              | int unsigned                      | NO   |      | 0                     |      |      |
| max_connections          | int unsigned                      | NO   |      | 0                     |      |      |
| max_user_connections     | int unsigned                      | NO   |      | 0                     |      |      |
| plugin                   | char(64)                          | NO   |      | caching_sha2_password |      |      |
| authentication_string    | text                              | YES  |      | *NULL*                |      |      |
| password_expired         | enum('N','Y')                     | NO   |      | N                     |      |      |
| password_last_changed    | timestamp                         | YES  |      | *NULL*                |      |      |
| password_lifetime        | smallint unsigned                 | YES  |      | *NULL*                |      |      |
| account_locked           | enum('N','Y')                     | NO   |      | N                     |      |      |
| Create_role_priv         | enum('N','Y')                     | NO   |      | N                     |      |      |
| Drop_role_priv           | enum('N','Y')                     | NO   |      | N                     |      |      |
| Password_reuse_history   | smallint unsigned                 | YES  |      | *NULL*                |      |      |
| Password_reuse_time      | smallint unsigned                 | YES  |      | *NULL*                |      |      |
| Password_require_current | enum('N','Y')                     | YES  |      | *NULL*                |      |      |
| User_attributes          | json                              | YES  |      | *NULL*                |      |      |

