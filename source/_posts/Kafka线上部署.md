---
title: Kafka线上部署
author: Payne
tags:
  - Apache Kafka
categories:
  - - Apache Kafka
    - MQ
    - Kafka
date: 2022-03-30 13:12:50
---

工欲善其事，必先利其器。先把Kafka跑起来！为了资源更有效的利用，需要考虑磁盘、网络带宽



## 资源规划

### 磁盘容量

需要考虑几个因素：

- 新增消息数 
- 消息留存时间
- 平均消息大小
- 备份数
- 是否启用压缩

计算公式为：新增消息数 * 消息留存时间 * 平均消息大小 * 备份数 * 压缩率 *  （1 + 10 %）(索引以及其他数据)  

假设有个业务每天需要向 Kafka 集群发送 1 亿条消息，每条消息保存两份以防止数据丢失，另外消息默认保存两周时间。现在假设消息的平均大小是 1KB，那么你能说出你的 Kafka 集群需要为这个业务预留多少磁盘空间吗？



每天 1 亿条 1KB 大小的消息，保存两份且留存两周的时间，那么总的空间大小就等于

$10 ^ 8 * 1 * 2 = 2 * 10^8 KB = 0.2 TB$ 

加上索引以及其他类型数据 在原有基础上增加 *10%*,那就是0.22TB

保留两周：0.22TB * 14 = 3.08 TB

压缩率为80%： 3.08 * 0.8  = 2.464 TB ≈ 2.5 TB

保险起见建议预留3 TB的存储空间



### 网络带宽

对于 Kafka 这种通过网络大量进行数据传输的框架而言，带宽特别容易成为瓶颈。事实上，在接触的真实案例当中，带宽资源不足导致 Kafka 出现性能问题的比例**至少占 60% 以上**。



当规划带宽时到不如说是部署kafka**服务器数量**

通常情况下只能假设 Kafka 会用到 70% 的带宽资源，因为总要为其他应用或进程留一些资源。根据实际使用经验，超过 70% 的阈值就有网络丢包的可能性了，故 70% 的设定是一个比较合理的值，也就是说单台 Kafka 服务器最多也就能使用大约 700Mb 的带宽资源。

稍等，这只是它能使用的最大带宽资源，你不能让 Kafka 服务器常规性使用这么多资源，故通常要再额外预留出 2/3 的资源，即单台服务器使用带宽 700Mb  / 3 ≈ 240Mbps。需要提示的是，这里的 2/3 其实是相当保守的，你可以结合你自己机器的使用情况酌情减少此值。

好了，有了 240Mbps，我们就可以计算 1 小时内处理 1TB 数据所需的服务器数量了。根据这个目标，我们每秒需要处理 2336Mb 的数据，除以 240，约等于 10 台服务器。如果消息还需要额外复制两份，那么总的服务器台数还要乘以 3，即 30 台。

## 参数配置

```dart
config
├── connect-console-sink.properties 
├── connect-console-source.properties
├── connect-distributed.properties
├── connect-file-sink.properties
├── connect-file-source.properties
├── connect-log4j.properties
├── connect-mirror-maker.properties
├── connect-standalone.properties
├── consumer.properties
├── kraft
│   ├── README.md
│   ├── broker.properties
│   ├── controller.properties
│   └── server.properties
├── log4j.properties 
├── producer.properties
├── server.properties 
├── tools-log4j.properties
├── trogdor.conf
└── zookeeper.properties
```

### JVM 参数与垃圾回收算法

Kafka 服务器端代码是用 Scala 语言编写的，但终归还是会编译成 `.Class`  文件在 JVM 上运行，因此 JVM 参数设置对于 Kafka 集群的重要性不言而喻。

JVM 端设置，堆大小这个参数至关重要，无脑通用的建议：将 JVM 堆大小设置成 6GB



垃圾回收器的设置，也就是平时常说的 GC 设置。

手动设置使用 G1 收集器。在没有任何调优的情况下，G1 表现得要比 CMS 出色，主要体现在更少的 Full GC，需要调整的参数更少等，所以使用 G1 就好了。



KAFKA_HEAP_OPTS：指定堆大小。

KAFKA_JVM_PERFORMANCE_OPTS：指定 GC 参数。



```bash
export KAFKA_HEAP_OPTS=--Xms6g  --Xmx6g
export KAFKA_JVM_PERFORMANCE_OPTS= -server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -Djava.awt.headless=true
kafka-server-start.sh ${KAFKA_HOME}/config/server.properties
```

### 操作系统参数

通常情况下，Kafka 并不需要设置太多的 系统参数

下面这几个在此较为重要：

- 文件描述符限制：比如ulimit -n 1000000
- 文件系统类型： 根据官网的测试报告，XFS 的性能要强于 ext4，所以生产环境最好还是使用 XFS甚至是ZFS。
- swap：建议将 swappniess 配置成一个接近 0 但不为 0 的值，比如 1。
- 提交时间：适当的增加提交间隔来降低物理磁盘的写操作



## 部署



```bash
# 安装jdk
sudo yum group install -y "development tools"
sudo yum install -y java-1.8.0-openjdk.x86_64
# 下载kafka
wget -c https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/3.1.0/kafka_2.13-3.1.0.tgz
# 解压缩
tar -zxf kafka_2.13-3.1.0.tgz -C /usr/local

# 配置环境变量
# kafka env config 
export KAFKA_HOME=/usr/local/kafka_2.13-3.1.0
export KAFKA_BIN=${KAFKA_HOME}/bin
export PATH=${KAFKA_BIN}:PATH

source /etc/profile

# 初始化
kafka-storage.sh format -c ${KAFKA_HOME}/config/kraft/server.properties -t `kafka-storage.sh random-uuid`
# 启动服务
kafka-server-start.sh ${KAFKA_HOME}/config/kraft/server.properties
```

### 验证

```bash
# 创建quickstart-events主题
kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092

kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092

kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```



## Kafka监控工具

- JMXTool: 可以实时查看kafka JMX 指标，但仅限于简单的监控场景
- [Logi-KM](https://github.com/didi/LogiKM): didi开源的**一站式`Apache Kafka`集群指标监控与运维管控平台**
- [JMXTrans](https://github.com/jmxtrans/jmxtrans) + InfluxDB + Grafana
- [EFAK](https://github.com/smartloli/EFAK)： 
- [Kafka tool](https://www.kafkatool.com/)：
- [CMAK](https://github.com/yahoo/CMAK)：雅虎源的kafka监控器，阿里在用



