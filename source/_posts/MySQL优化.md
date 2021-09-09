---
title: MySQL优化
author: Payne
tags:
  - MySQL
  - 数据库
categories:
  - - 数据库
    - MySQL
abbrlink: 507251385
date: 2021-09-04 00:27:43

---

mysql优化老生常谈了，但却也离不开业务。脱离业务来讲mysql可以从两个方面进行优化

- 安全优化（业务持续性）

- 性能优化（业务高效性）

所谓优化，个人认为有两大需要提前知道的**稳定性和业务可持续性通常比性能更重要**，**优化是由业务需要驱使的**

通常优化也与操作系统、运行环境等息息相关，结合业务适合自己才是最好的。

## 安全优化

足够强度的安全是保证业务正常运行的基石，安全优化通常可以以系统安全，应用程序安全，与sql安全。

### 系统安全

> 具体详情请参考Linux系统安全

**物理安全**

物理环境安全，小微企业一般使用云服务器，大型企业一般有多个机房，实现异地多活

**防火墙策略、关闭或切换不必要的端口**

> 1. 修改常见应用默认端口，22、3306、27017、6379等

**账户安全**

用户连接权限、用户权限

> 1. 禁止root远程
> 2. 账号管理（密码强度、用户权限）

**源代码文件目录权限管理**

**备份**等

### MySQL安全

> https://www.cnblogs.com/doublexi/p/9732274.html

MySQL版本的选择

MySQL的命名机制使用由3个数字和一个后缀组成的版本号。例如，像mysql-5.0.9-beta的版本号这样解释：

数字(5)是主版本号，描述了文件格式。所有版本5的发行都有相同的文件格式。

数字(0)是发行级别。主版本号和发行级别组合到一起便构成了发行序列号。

数字(9)是在此发行系列的版本号，随每个新分发版递增。通常你需要已经选择的发行(release)的最新版本(版本)。

每次更新后，版本字符串的最后一个数字递增。如果相对于前一个版本增加了新功能或有微小的不兼容性，字符串的第二个数字递增。如果文件格式改变，第一个数字递增。

后缀显示发行的稳定性级别。通过一系列后缀显示如何改进稳定性。可能的后缀有：

**·alpha表明发行包含大量未被彻底测试的新代码**。已知的缺陷应该在新闻小节被记录。请参见附录D：MySQL变更史。在大多数alpha版本中也有新的命令和扩展。alpha版本也可能有主要代码更改等开发。但我们在发布前一定对其进行测试。

**·beta意味着该版本功能是完整的**，并且所有的新代码被测试了，没有增加重要的新特征，应该没有已知的缺陷。当alpha版本至少一个月没有出现报导的致命漏洞，并且没有计划增加导致已经实施的功能不稳定的新功能时，版本则从alpha版变为beta版。

在以后的beta版、发布版或产品发布中，所有API、外部可视结构和SQL命令列均不再更改。

**·rc是发布代表**；是一个发行了一段时间的beta版本，看起来应该运行正常。只增加了很小的修复。(发布代表即以前所称的gamma版)

·如果没有后缀，这意味着该版本已经在很多地方运行一段时间了，而且没有非平台特定的缺陷报告。只增加了关键漏洞修复修复。这就是我们称为一个产品(稳定)或“通用”版本的东西。

MySQL的命名机制于其它产品稍有不同。一般情况，我们可以很放心地使用已经投放市场两周而没有被相同发布系列的新版本所代替的版本。

- 稳定不要最新：最新GA版超过10个月或比最新GA版晚3、4个版本的GA版。
- 前后无大BUG：要选择前后几个月没有**大的BUG修复的版本**，而不是大量**修复BUG的集中版本**。
- 向后少更新：最好向后较长时间没有更新发布的版本，**若目标版本修复的BUG巨多，向前推进一个版本号。**
- 兼容开发：验证功能瓶颈、性能瓶颈，要考虑开发人员开发程序使用的版本是否兼容你选的版本
- 测试先行：作为内部开发测试数据库环境，跑大概3-6个月的时间。
- 非核心先行：优先企业非核心业务采用新版本的数据库GA版本软件。

#### 用户安全

**禁止root账户远程访问**

root权限太高，拥有安全隐患，root只允许本地登陆

**mysql用户登录shell为nologin**

```bash
usermod -s /sbin/nologin mysql
```

**对MySQL运行用户降权，以普通用户身份运行MySQL**

```bash
# /etc/my.cnf
[mysqld]
user=mysql
```

**删除匿名账号和空口令账号**

```bash
# 删除空密码用户
delete from mysql.user where user is NULL or Password IS NULL;
```

**用户与权限管理**

遵循权限最小化原则。

#### 连接安全

修改默认端口

```bash
# /etc/my.cnf
[mysqld]
port=8912
```

#### 容灾

在误删除数据的情况下，可以通过二进制日志恢复到某个时间点

#### 二进制日志

```mysql
# 查看bin log（sql）
show variables like '%log_bin%'
```

![image-20210905193857001](https://tva1.sinaimg.cn/large/008i3skNgy1gu5zib6numj60p40ag75902.jpg)

修改MySQL配置文件my.cnf，加入如下两行

```bash
server-id = 1
log_bin = /data/mysql/mysql-bin
```

重启服务



## 性能优化

```bash
效果 sql与索引优化>Schema设计>数据库实例优化>文件系统>操作系统>硬件优化
成本 硬件优化>操作系统>文件系统>数据库实例优化>Schema设计>sql与索引优化
```

### 硬件优化

#### 主机

```undefined
真实的硬件（PC Server）: DELL  R系列 ，华为，浪潮，HP，联想
云产品：ECS、数据库RDS、DRDS
IBM 小型机 P6  570  595   P7 720  750 780     P8 
```

#### CPU

> 根据业务场景选择

OLTP \ OLAP
IO密集型：线上系统，OLTP主要是IO密集型的业务，高并发
CPU密集型：数据分析数据处理，OLAP，cpu密集型的，需要CPU高计算能力（i系列，IBM power系列）
CPU密集型： I 系列的，主频很高，核心少 
IO密集型：  E系列（至强），主频相对低，核心数量多

#### 内存

建议2-3倍cpu核心数量 （ECC）

#### 磁盘选择

SATA-III   SAS    Fc    SSD（sata） pci-e  ssd  Flash
主机 RAID卡的BBU(Battery Backup Unit)关闭

#### 存储

根据存储数据种类的不同，选择不同的存储设备
配置合理的RAID级别(raid5、raid10、热备盘)   
r0 :条带化 ,性能高
r1 :镜像，安全
r5 :校验+条带化，安全较高+性能较高（读），写性能较低 （适合于读多写少）
r10：安全+性能都很高，最少四块盘，浪费一半的空间（高IO要求）

#### 网络

1、硬件买好的（单卡单口）
2、网卡绑定（bonding），交换机堆叠
以上问题，提前规避掉。

### 操作系统优化

#### Swap调整

```
echo 0 >/proc/sys/vm/swappiness的内容改成0（临时），
/etc/sysctl.conf
上添加vm.swappiness=0（永久）
sysctl -p
```

此参数决定了Linux是倾向于使用swap，还是倾向于释放文件系统cache。在内存紧张的情况下，数值越低越倾向于释放文件系统cache。
当然，这个参数只能减少使用swap的概率，并不能避免Linux使用swap。

修改MySQL的配置参数innodb_flush_method，开启O_DIRECT模式
这种情况下，InnoDB的buffer pool会直接绕过文件系统cache来访问磁盘，但是redo log依旧会使用文件系统cache。值得注意的是，Redo log是覆写模式的，即使使用了文件系统的cache，也不会占用太多

#### IO调度策略

raid、no lvm、ext4或xfs、ssd、IO调度策略

### 数据库实例优化

查看系统配置

```mysql
show variables like “xxx”
```

查看状态

```
show status like
```

#### 连接

##### **max_connect_errors**

 max_connect_errors是一个mysql中与安全有关的计数器值，它负责阻止过多尝试失败的客户端以防止暴力破解密码等情况，当超过指定次数，mysql服务器将禁连接请求，

直到mysql服务器重启或通过flush hosts命令清空此host的相关信息 max_connect_errors的值与性能并无太大关系。

```
修改/etc/my.cnf文件，在[mysqld]下面添加如下内容
max_connect_errors=1000
```

##### **Max_connections**

> Mysql的最大连接数，如果服务器的并发请求量比较大，可以调高这个值，当然这是要建立在机器能够支撑的情况下，因为如果连接数越来越多，mysql会为每个连接提供缓冲区，就会开销的越多的内存，所以需要适当的调整该值，不能随便去提高设值

开启数据库时,临时设置一个比较大的测试值, 观察show status like 'Max_used_connections';变化
如果max_used_connections跟max_connections相同,那么就是max_connections设置过低或者超过服务器的负载上限了，低于10%则设置过大. 

##### **back_log**

>  mysql能暂存的连接数量，当主要mysql线程在一个很短时间内得到非常多的连接请求时候它就会起作用，如果mysql的连接数据达到max_connections时候，新来的请求将会被存在堆栈中，等待某一连接释放资源，该推栈的数量及back_log,如果等待连接的数量超过back_log，将不被授予连接资源。
> back_log值指出在mysql暂时停止回答新请求之前的短时间内有多少个请求可以被存在推栈中，只有如果期望在一个短时间内有很多连接的时候需要增加它

<u>*判断依据*</u>

```mysql
show full processlist
```

发现大量的待连接进程时，就需要加大back_log或者加大max_connections的值

```bash
# vim /etc/my.cnf 
back_log=xxx
```

##### **wait_timeout**

> wait_timeout：指的是mysql在关闭一个非交互的连接之前所要等待的秒数，如果设置太小，那么连接关闭的就很快，从而使一些持久的连接不起作用。长连接的应用，为了不去反复的回收和分配资源，降低额外的开销。

如果设置太大，容易造成连接打开时间过长，在show processlist时候，能看到很多的连接 ，一般希望wait_timeout尽可能低

**interactive_timeout**

>  如果设置太大，容易造成连接打开时间过长造成资源损耗，在show processlist时候，能看到很多的连接 ，一般希望wait_timeout尽可能低

关闭一个交互的连接之前所需要等待的秒数，比如我们在终端上进行mysql管理，使用的即使交互的连接，这时候，如果没有操作的时间超过了interactive_time设置的时间就会自动的断开，默认的是28800，可调优为7200



#####  key_buffer_size

key_buffer_size指定索引缓冲区的大小，它决定索引处理的速度，尤其是索引读的速度

```dart
临时表的创建有关（多表链接、子查询中、union）
     在有以上查询语句出现的时候，需要创建临时表，用完之后会被丢弃
     临时表有两种创建方式：
                        内存中------->key_buffer_size
                        磁盘上------->ibdata1(5.6)
                                      ibtmp1 (5.7）
```

#### 处理

##### sort_buffer_size

> 每个需要进行排序的线程分配该大小的一个缓冲区。增加这值加速

```
ORDER BY 
GROUP BY
distinct
union 
```

Sort_Buffer_Size并不是越大越好，由于是connection级的参数，过大的设置+高并发可能会耗尽系统内存资源。
列如：500个连接将会消耗500*sort_buffer_size（2M）=1G内存

**配置方法**
修改/etc/my.cnf文件，在[mysqld]下面添加如下：
sort_buffer_size=1M

##### max_allowed_packet 

> mysql根据配置文件会限制，server接受的数据包大小

有时候大的插入和更新会受max_allowed_packet参数限制，导致写入或者更新失败，更大值是1GB，必须设置1024的倍数

```
max_allowed_packet=32M
```

##### join_buffer_size

用于表间关联缓存的大小，和sort_buffer_size一样，该参数对应的分配内存也是每个连接独享。
尽量在SQL与方面进行优化，效果较为明显。
优化的方法：在on条件列加索引，至少应当是有MUL索引

##### thread_cache_size

> 服务器线程缓存，这个值表示可以重新利用保存在缓存中线程的数量,当断开连接时,那么客户端的线程将被放到缓存中以响应下一个客户而不是销毁(前提是缓存数未达上限),如果线程重新被请求，那么请求将从缓存中读取,如果缓存中是空的或者是新的请求，那么这个线程将被重新创建,如果有很多新的线程，增加这个值可以改善系统性能

通过比较 Connections 和 Threads_created 状态的变量，可以看到这个变量的作用。
设置规则如下：1GB 内存配置为8，2GB配置为16，3GB配置为32，4GB或更高内存，可配置更大。
服务器处理此客户的线程将会缓存起来以响应下一个客户而不是销毁(前提是缓存数未达上限)

| Variable_name     | Value |                                                              |
| :---------------- | :---- | ------------------------------------------------------------ |
| Threads_cached    | 178   | 当前此时此刻线程缓存中有多少空闲线程                         |
| Threads_connected | 78    | 当前已建立连接的数量，因为一个连接就需要一个线程，所以也可以看成当前被使用的线程数 |
| Threads_created   | 479   | 从最近一次服务启动，已创建线程的数量，如果发现Threads_created值过大的话，表明MySQL服务器一直在创建线程，这也是比较耗cpu SYS资源，可以适当增加配置文件中thread_cache_size值 |
| Threads_running   | 2     | 当前激活的（非睡眠状态）线程数。并不是代表正在使用的线程数，有时候连接已建立，但是连接处于sleep状态 |

Threads_created  ：一般在架构设计阶段，会设置一个测试值，做压力测试。
结合zabbix监控，看一段时间内此状态的变化。
如果在一段时间内，Threads_created趋于平稳，说明对应参数设定是OK。
如果一直陡峭的增长，或者出现大量峰值，那么继续增加此值的大小，在系统资源够用的情况下（内存）

##### innodb_buffer_pool_size

> 对于InnoDB表来说，innodb_buffer_pool_size的作用就相当于key_buffer_size对于MyISAM表的作用一样。

*<u>配置依据</u>*

InnoDB使用该参数指定大小的内存来缓冲数据和索引。

对于单独的MySQL数据库服务器，最大可以把该值设置成物理内存的80%,一般我们建议不要超过物理内存的70%。

<u>*配置方法*</u>


innodb_buffer_pool_size=2048M

##### **innodb_flush_log_at_trx_commit**

主要控制了innodb将log buffer中的数据写入日志文件并flush磁盘的时间点，取值分别为0、1、2三个。
0，表示当事务提交时，不做日志写入操作，而是每秒钟将log buffer中的数据写入日志文件并flush磁盘一次；
1，每次事务的提交都会引起redo日志文件写入、flush磁盘的操作，确保了事务的ACID；
2，每次事务提交引起写入日志文件的动作,但每秒钟完成一次flush磁盘操作。

***配置依据***
实际测试发现，该值对插入数据的速度影响非常大，设置为2时插入10000条记录只需要2秒，设置为0时只需要1秒，而设置为1时则需要229秒。因此，MySQL手册也建议尽量将插入操作合并成一个事务，这样可以大幅提高速度。
根据MySQL官方文档，在允许丢失最近部分事务的危险的前提下，可以把该值设为0或2。

<u>*配置方法*</u>

innodb_flush_log_at_trx_commit=1
双1标准中的一个1

##### **innodb_thread_concurrency**

> 此参数用来设置innodb线程的并发数量，默认值为0表示不限制。

在官方文档上，对于innodb_thread_concurrency的使用，也给出了一些建议，如下：

- 如果一个工作负载中，并发用户线程的数量小于64，建议设置innodb_thread_concurrency=0；
- 如果工作负载一直较为严重甚至偶尔达到顶峰，建议先设置innodb_thread_concurrency=128，
  并通过不断的降低这个参数，96, 80, 64等等，直到发现能够提供最佳性能的线程数，

假设系统通常有40到50个用户，但定期的数量增加至60，70，甚至200。你会发现，
性能在80个并发用户设置时表现稳定，如果高于这个数，性能反而下降。在这种情况下，
建议设置innodb_thread_concurrency参数为80，以避免影响性能。

如果你不希望InnoDB使用的虚拟CPU数量比用户线程使用的虚拟CPU更多（比如20个虚拟CPU），
建议通过设置innodb_thread_concurrency 参数为这个值（也可能更低，这取决于性能体现），

如果你的目标是将MySQL与其他应用隔离，你可以l考虑绑定mysqld进程到专有的虚拟CPU。
但是需 要注意的是，这种绑定，在myslqd进程一直不是很忙的情况下，可能会导致非最优的硬件使用率。在这种情况下，
你可能会设置mysqld进程绑定的虚拟 CPU，允许其他应用程序使用虚拟CPU的一部分或全部。
在某些情况下，最佳的innodb_thread_concurrency参数设置可以比虚拟CPU的数量小。
定期检测和分析系统，负载量、用户数或者工作环境的改变可能都需要对innodb_thread_concurrency参数的设置进行调整

128   -----> top  cpu 
<u>*设置标准*</u>
1、当前系统cpu使用情况，均不均匀
top

2、当前的连接数，有没有达到顶峰
show status like 'threads_%';
show processlist;
（3）配置方法：
innodb_thread_concurrency=8
方法:

       1. 看top ,观察每个cpu的各自的负载情况
    2. 发现不平均,先设置参数为cpu个数,然后不断增加(一倍)这个数值
    3. 一直观察top状态,直到达到比较均匀时,说明已经到位了.

##### **innodb_log_buffer_size**

```objectivec
此参数确定些日志文件所用的内存大小，以M为单位。缓冲区更大能提高性能，对于较大的事务，可以增大缓存大小。
innodb_log_buffer_size=128M
设定依据：
1、大事务： 存储过程调用 CALL
2、多事务
```

##### ***innodb_log_file_size = 100M***

```undefined
设置 ib_logfile0  ib_logfile1 
此参数确定数据日志文件的大小，以M为单位，更大的设置可以提高性能.
innodb_log_file_size = 100M
```

##### **innodb_log_files_in_group = 3** 

```undefined
为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3
```

##### **read_buffer_size = 1M**

```undefined
MySql读入缓冲区大小。对表进行顺序扫描的请求将分配一个读入缓冲区，MySql会为它分配一段内存缓冲区。如果对表的顺序扫描请求非常频繁，并且你认为频繁扫描进行得太慢，可以通过增加该变量值以及内存缓冲区大小提高其性能。和 sort_buffer_size一样，该参数对应的分配内存也是每个连接独享
```

##### **read_rnd_buffer_size = 1M**

```undefined
MySql的随机读（查询操作）缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。进行排序查询时，MySql会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。但MySql会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大。
注：顺序读是指根据索引的叶节点数据就能顺序地读取所需要的行数据。随机读是指一般需要根据辅助索引叶节点中的主键寻找实际行数据，而辅助索引和主键所在的数据段不同，因此访问方式是随机的。
```

##### **bulk_insert_buffer_size = 8M**

```undefined
批量插入数据缓存大小，可以有效提高插入效率，默认为8M
tokuDB    percona
myrocks   
RocksDB
TiDB
MongoDB
```



##### **binary log**

```kotlin
log-bin=/data/mysql-bin
binlog_cache_size = 2M //为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存, 提高记录bin-log的效率。没有什么大事务，dml也不是很频繁的情况下可以设置小一点，如果事务大而且多，dml操作也频繁，则可以适当的调大一点。前者建议是--1M，后者建议是：即 2--4M
max_binlog_cache_size = 8M //表示的是binlog 能够使用的最大cache 内存大小
max_binlog_size= 512M //指定binlog日志文件的大小，如果当前的日志大小达到max_binlog_size，还会自动创建新的二进制日志。你不能将该变量设置为大于1GB或小于4096字节。默认值是1GB。在导入大容量的sql文件时，建议关闭sql_log_bin，否则硬盘扛不住，而且建议定期做删除。
expire_logs_days = 7 //定义了mysql清除过期日志的时间。
二进制日志自动删除的天数。默认值为0,表示“没有自动删除”。
log-bin=/mysql-bin
binlog_format=row 
sync_binlog=1
双1标准(基于安全的控制)：
sync_binlog=1   // 什么时候刷新binlog到磁盘，每次事务commit
innodb_flush_log_at_trx_commit=1
set sql_log_bin=0;
show status like 'com_%';
```



```
[mysqld]
basedir=/data/mysql
datadir=/data/mysql/data
socket=/tmp/mysql.sock
log-error=/var/log/mysql.log
log_bin=/data/binlog/mysql-bin
binlog_format=row
skip-name-resolve
server-id=52
gtid-mode=on
enforce-gtid-consistency=true
log-slave-updates=1
relay_log_purge=0
max_connections=1024
back_log=128
wait_timeout=60
interactive_timeout=7200
key_buffer_size=16M
query_cache_size=64M
query_cache_type=1
query_cache_limit=50M
max_connect_errors=20
sort_buffer_size=2M
max_allowed_packet=32M
join_buffer_size=2M
thread_cache_size=200
innodb_buffer_pool_size=1024M
innodb_flush_log_at_trx_commit=1
innodb_log_buffer_size=32M
innodb_log_file_size=128M
innodb_log_files_in_group=3
binlog_cache_size=2M
max_binlog_cache_size=8M
max_binlog_size=512M
expire_logs_days=7
read_buffer_size=2M
read_rnd_buffer_size=2M
bulk_insert_buffer_size=8M
[client]
socket=/tmp/mysql.sock  
```



## sql与索引优化

### sql使用建议

1.对查询进行优化，应尽量避免全表扫描，首先应考虑在 where 及 order by 涉及的列上建立索引。

2.应尽量避免在 where 子句中对字段进行 null 值判断，否则将导致引擎放弃使用索引而进行全表扫描，如：   

```
select id from t where num is null 
可以在num上设置默认值0，确保表中num列没有null值，然后这样查询：
select id from t where num=0 
```

3.应尽量避免在 where 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描。

4.应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如：   

```
select id from t where num=10 or num=20   
可以这样查询：   
select id from t where num=10   
union all   
select id from t where num=20   
```

5.in 和 not in 也要慎用，否则会导致全表扫描，如：   

```
select id from t where num in(1,2,3)   
对于连续的数值，能用 between 就不要用 in 了：   
select id from t where num between 1 and 3  
```

6.下面的查询也将导致全表扫描：

```
select id from t where name like '%abc%'   
```

7.应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如：   

```
select id from t where num/2=100   
应改为:   
select id from t where num=100*2   
```

8.应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如：   

```
select id from t where substring(name,1,3)='abc'--name以abc开头的id   
应改为:   
select id from t where name like 'abc%'   
```

9.不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。   



10.在使用索引字段作为条件时，如果该索引是复合索引，那么必须使用到该索引中的第一个字段作为条件时才能保证系统使用该索引，否则该索引将不会被使用，并且应尽可能的让字段顺序与索引顺序相一致。   



11.不要写一些没有意义的查询，如需要生成一个空表结构



12.很多时候用 exists 代替 in 是一个好的选择：   

```
select num from a where num in(select num from b)   
用下面的语句替换：   
select num from a where exists(select 1 from b where num=a.num)   
```

13.并不是所有索引对查询都有效，SQL是根据表中数据来进行查询优化的，当索引列有大量数据重复时，SQL查询可能不会去利用索引，如一表中有字段sex，male、female几乎各一半，那么即使在sex上建了索引也对查询效率起不了作用。   



14.索引并不是越多越好，索引固然可以提高相应的 select 的效率，但同时也降低了 insert 及 update 的效率，
因为 insert 或 update 时有可能会重建索引，所以怎样建索引需要慎重考虑，视具体情况而定。
一个表的索引数最好不要超过6个，若太多则应考虑一些不常使用到的列上建的索引是否有必要。   

15.尽量使用数字型字段，若只含数值信息的字段尽量不要设计为字符型，这会降低查询和连接的性能，并会增加存储开销。 
这是因为引擎在处理查询和连接时会逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了。   



16.尽可能的使用 varchar 代替 char ，因为首先变长字段存储空间小，可以节省存储空间，   
其次对于查询来说，在一个相对较小的字段内搜索效率显然要高些。   



17.任何地方都不要使用 select * from t ，用具体的字段列表代替“*”，不要返回用不到的任何字段。   



18.避免频繁创建和删除临时表，以减少系统表资源的消耗。



19.临时表并不是不可使用，适当地使用它们可以使某些例程更有效，例如，当需要重复引用大型表或常用表中的某个数据集时。但是，对于一次性事件，最好使用导出表。



20.在新建临时表时，如果一次性插入数据量很大，那么可以使用 select into 代替 create table，避免造成大量 log ，   
以提高速度；如果数据量不大，为了缓和系统表的资源，应先create table，然后insert。



21.如果使用到了临时表，在存储过程的最后务必将所有的临时表显式删除，先 truncate table ，然后 drop table ，这样可以避免系统表的较长时间锁定。  



22.尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写。   



23.使用基于游标的方法或临时表方法之前，应先寻找基于集的解决方案来解决问题，基于集的方法通常更有效。



24.与临时表一样，游标并不是不可使用。对小型数据集使用 FAST_FORWARD 游标通常要优于其他逐行处理方法，尤其是在必须引用几个表才能获得所需的数据时。

在结果集中包括“合计”的例程通常要比使用游标执行的速度快。如果开发时间允许，基于游标的方法和基于集的方法都可以尝试一下，看哪一种方法的效果更好。



25.尽量避免大事务操作，提高系统并发能力。


26.尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理。


### sql调优思路

1. slow_query_log 收集慢日志 结合explain分析索引命中与进行索引优化
2. 减少索引扫描行数，对于慢sql进行优化
3. 建立联合索引，由于联合索引的每个叶子节点都包含检索字段信息，按最左原则匹配，按照其他条件过滤，减少回表的数据量
4. 使用虚拟列和联合索引来提升复杂查询执行效率

### 索引失效

1. 没有查询条件，或者查询条件没有建立索引
2. 查询结果集是原表中的大部分数据
3. 索引本身失效，统计数据不真实
4. 查询条件使用函数在索引列上，或者对索引列进行运算，运算包括(+，-，*，/，! 等)
5. 隐式转换导致索引失效
6. <> ，not in 不走索引（辅助索引）
7. ike "%_" 百分号在最前面不走