---
title: MySQL的SQL使用之中
author: Payne
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 1815382139
date: 2021-08-26 14:53:02
---

## DML的使用

对表中的数据行进行增、删、改

### 增

> 向数据表内插入数据

```mysql
# INSERT语法
INSERT [INTO] table_name[(field_name_1, field_name_2...)] VALUES(value1, value2...),[(value1, value2...)...]
# 常见示例
## 插入
INSERT INTO ch_people_msg(`p_uic`, `p_nickname`, `p_gender`, `p_age`, `p_pnum`, `p_address`, `p_email`) VALUES
("431122200008868162", "payne", "m", 22, 17672655132, "湖南省xx市xx区雨花a世界", "127xxxx261"),
("431122200002148162", "tom", "m", 25, 17672655132, "湖南省xx市xx区雨花a世界", "127xxxx221"),
("431122200002168163", "tom", "m", 25, 17672655132, "湖南省xx市xx区雨花a世界", "127xxxx221")
```

> ```mysql
> CREATE TABLE IF NOT EXISTS `ch_people_msg` ( 
>   `p_id`  SERIAL NOT NULL AUTO_INCREMENT COMMENT '用户id' , 
>   `p_uic` CHAR(18) NOT NULL COMMENT '用户身份证',
>   `p_nickname` VARCHAR(50) NOT NULL COMMENT '用户昵称', 
>   `p_gender` ENUM('m','f', 'n') NOT NULL DEFAULT 'n' COMMENT '用户性别', 
>   `p_age` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户年龄', 
>   `p_pnum` CHAR(11) NOT NULL COMMENT '用户电话', 
>   `p_address` VARCHAR(100) NOT NULL COMMENT '用户地址', 
>   `p_email` VARCHAR(50) NOT NULL COMMENT '用户邮箱', 
>   `p_add_time` TIMESTAMP NOT NULL DEFAULT NOW() COMMENT '统计用户时间',
>    PRIMARY KEY (`p_id`),
>    UNIQUE KEY `p_uic`(`p_uic`)
> ) ENGINE = InnoDB CHARSET=utf8mb4 COLLATE utf8mb4_general_ci COMMENT = '中国成员信息表';
> ```

### 删

```
DELETE FROM table_name
truncate table table_name;
DROP table table_name

delete: DML操作, 是逻辑性质删除,逐行进行删除,速度慢.
truncate: DDL操作,对与表段中的数据页进行清空,速度快.

```

>  当表被TRUNCATE 后，这个表和索引所占用的空间会恢复到初始大小，
>
>  DELETE操作不会减少表或索引所占用的空间。
>
>  drop语句将表所占用的空间全释放掉。
>
> 释放空间与速度：drop > truncate > delete

**delete**

- delete是DML，执行delete操作时，每次从表中删除一行，并且同时将该行的的删除操作记录在redo和undo表空间中以便进行回滚（rollback）和重做操作，但要注意表空间要足够大，需要手动提交（commit）操作才能生效，可以通过rollback撤消操作。
- delete可根据条件删除表中满足条件的数据，如果不指定where子句，那么删除表中所有记录。

- delete语句不影响表所占用的extent，高水线(high watermark)保持原位置不变。

**truncate**

- truncate是DDL，会隐式提交，所以，不能回滚，不会触发触发器。
- truncate会删除表中所有记录，并且将重新设置高水线和所有的索引，缺省情况下将空间释放到minextents个extent，除非使用reuse storage，。不会记录日志，所以执行速度很快，但不能通过rollback撤消操作（如果一不小心把一个表truncate掉，也是可以恢复的，只是不能通过rollback来恢复）。

- 对于外键（foreignkey ）约束引用的表，不能使用 truncate table，而应使用不带 where 子句的 delete 语句。

- truncatetable不能用于参与了索引视图的表。

**drop**

- drop是DDL，会隐式提交，所以，不能回滚，不会触发触发器。
- drop语句删除表结构及所有数据，并将表所占用的空间全部释放。

- drop语句将删除表的结构所依赖的约束，触发器，索引，依赖于该表的存储过程/函数将保留,但是变为invalid状态。

> - 如果想删除表，当然用drop； 
>
> - 如果想保留表而将所有数据删除，如果和事务无关，用truncate即可；
>
> -  如果和事务有关，或者想触发trigger，还是用delete；
>
> - 如果是整理表内部的碎片，可以用truncate跟上reuse stroage，再重新导入/插入数据。

伪删除：用update来替代delete，最终保证业务中查不到（select）即可

```sql
1.添加状态列
ALTER TABLE ch_people_msg ADD state TINYINT NOT NULL DEFAULT 1 ;
SELECT * FROM ch_people_msg;
2. UPDATE 替代 DELETE
UPDATE ch_people_msg SET state=0 WHERE id=6;
3. 业务语句查询
SELECT * FROM ch_people_msg WHERE state=1;
```

### 改

```
UPDATE ch_people_msg SET p_nickname='zero' WHERE id=2;
```

### 查

```dart
# 基本语法
select--from--[where]--[group by]--[having]--[order by]
```

> FROM：对FROM子句中的前两个表执行笛卡尔积（Cartesian product)(交叉联接），生成虚拟表VT1                                            ON：对VT1应用ON筛选器。只有那些使<join_condition>为真的行才被插入VT2
> OUTER(JOIN)：如果指定了OUTER JOIN（相对于CROSS JOIN 或(INNER JOIN),保留表（preserved table：左外部联接把左表标记为保留表，右外部联接把右表标记为保留表，完全外部联接把两个表都标记为保留表）中未找到匹配的行将作为外部行添加到 VT2,生成VT3.如果FROM子句包含两个以上的表，则对上一个联接生成的结果表和下一个表重复执行步骤1到步骤3，直到处理完所有的表为止。
> WHERE：对VT3应用WHERE筛选器。只有使<where_condition>为true的行才被插入VT4.
> GROUP BY：按GROUP BY子句中的列列表对VT4中的行分组，生成VT5.
> CUBE|ROLLUP：把超组(Suppergroups)插入VT5,生成VT6.
> HAVING：对VT6应用HAVING筛选器。只有使<having_condition>为true的组才会被插入VT7.               
> SELECT：处理SELECT列表，产生VT8.       
> DISTINCT：将重复的行从VT8中移除，产生VT9.
> ORDER BY：将VT9中的行按ORDER BY 子句中的列列表排序，生成游标（VC10).
> TOP：从VC10的开始处选择指定数量或比例的行，生成表VT11,并返回调用者。

```dart
# 单表子句-from
SELECT 列1,列2 FROM 表
SELECT  *  FROM 表
```

#### where

```dart
# 等值查询
	SELECT  *  FROM 表 where 列 = 值
	SELECT 列1,列2 FROM 表 where 列 = 值
  
# 比较运算符
>、<、>=、<=、!=、=
	SELECT * FROM 表 where 列 >= 值
	SELECT 列,... FROM 表 where 列 <= 值
  
# 模糊查询
	%代表任何个数的任何字符 _:它代表一个任何字符
	注意：%不能放在前面,因为不走索引,要找%或_,转义就行了\%和\_
  
# or、and
  	SELECT * FROM 表 where 列 >= 值 or 列 < 值
  
# where配合in语句
  SELECT * FROM 表 WHERE 列 IN (VALUES, VALUES);

# where配合between and
  SELECT * FROM city  WHERE population >1000000 AND population <2000000;
	SELECT * FROM city  WHERE population BETWEEN 1000000 AND 2000000;
```

#### group by

根据 by后面的条件进行**分组**，方便统计，by后面跟一个列或多个列

> **max()**      			：最大值
> **min()**			       ：最小值
> **avg()**     			   ：平均值
> **sum()**     			  ：总和
> **count()**    			：个数
> **group_concat()** : 列转行

**having**

​		having语句是分组后过滤的条件，在group by之后使用，也就是如果要用having语句，必须要先有group by语句。

#### order by

实现先排序，by后添加条件列



```
# distinct：去重复查询
SELECT 列 FROM ;
SELECT DISTINCT(列) FROM city  ;



# 联合查询- union all
  SELECT * FROM city 
WHERE countrycode IN ('CHN' ,'USA');

SELECT * FROM city WHERE countrycode='CHN'
UNION ALL
SELECT * FROM city WHERE countrycode='USA'

说明:一般情况下,我们会将 IN 或者 OR 语句 改写成 UNION ALL,来提高性能
UNION     去重复
UNION ALL 不去重复
```

