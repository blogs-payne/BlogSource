---
title: Kafka发行版本与版本号
author: Payne
tags:
  - Apache Kafka
categories:
  - - Apache Kafka
    - MQ
    - Kafka
abbrlink: 2037230795
date: 2022-03-29 18:57:28
---

## Kafka 发行版本

### Apache Kafka

Apache Kafka 是最“正宗”的 Kafka，也应该最熟悉的发行版。

自 Kafka 开源伊始，它便在 Apache 基金会孵化并最终毕业成为顶级项目，它也被称为社区版 Kafka。咱们专栏就是以这个版本的 Kafka 作为模板来学习的。更重要的是，它是后面其他所有发行版的基础。也就是说，后面提到的发行版要么是原封不动地继承了 Apache Kafka，要么是在此之上扩展了新功能，总之 Apache Kafka 是我们学习和使用 Kafka 的基础



#### 优

对 Apache Kafka 而言，它现在依然是开发人数最多、版本迭代速度最快的 Kafka。在 2018 年度 Apache 基金会邮件列表开发者数量最多的 Top 5 排行榜中，Kafka 社区邮件组排名第二位。如果你使用 Apache Kafka 碰到任何问题并提交问题到社区，社区都会比较及时地响应你。这对于我们 Kafka 普通使用者来说无疑是非常友好的。



#### **劣**

*Apache Kafka* 的劣势在于它仅仅提供最最基础的组件，特别是对于前面提到的 *Kafka Connect* 而言，社区版 *Kafka* 只提供一种连接器，即读写磁盘文件的连接器，而没有与其他外部系统交互的连接器，在实际使用过程中需要自行编写代码实现，这是它的一个劣势。

另外 *Apache Kafka* 没有提供任何监控框架或工具。显然在线上环境不加监控肯定是不可行的，你必然需要借助第三方的监控框架实现对 *Kafka* 的监控。好消息是目前有一些开源的监控框架可以帮助用于监控 *Kafka*（比如 *Kafka manager*）。



> 总而言之，如果仅仅需要一个消息引擎系统亦或是简单的流处理应用场景，同时需要对系统有较大把控度，那么推荐你使用 Apache Kafka。



### Confluent Kafka

它主要从事商业化 Kafka 工具开发，并在此基础上发布了 Confluent Kafka。Confluent Kafka 提供了一些 Apache Kafka 没有的高级特性，

比如跨数据中心备份、Schema 注册中心以及集群监控工具等。



#### 优

Confluent Kafka 目前分为免费版和企业版两种。

前者和 Apache Kafka 非常相像，除了常规的组件之外，免费版还包含 Schema 注册中心和 REST proxy 两大功能。

前者是帮助你集中管理 Kafka 消息格式以实现数据前向 / 后向兼容；

后者用开放 HTTP 接口的方式允许你通过网络访问 Kafka 的各种功能，这两个都是 Apache Kafka 所没有的。



除此之外，免费版包含了更多的连接器，它们都是 Confluent 公司开发并认证过的，可以免费使用它们。

至于企业版，它提供的功能就更多了。最有用的当属跨数据中心备份和集群监控两大功能了。

多个数据中心之间数据的同步以及对集群的监控历来是 Kafka 的痛点，Confluent Kafka 企业版提供了强大的解决方案帮助你“干掉”它们



#### 劣

Confluent 公司暂时没有发展国内业务的计划，相关的资料以及技术支持都很欠缺，很多国内 Confluent Kafka 使用者甚至无法找到对应的中文文档，因此目前 Confluent Kafka 在国内的普及率是比较低的。



> 如果需要用到 Kafka 的一些高级特性，那么推荐使用 Confluent Kafka。



### Cloudera/Hortonworks Kafka

Cloudera 提供的 CDH 和 Hortonworks 提供的 HDP 是非常著名的大数据平台，里面集成了目前主流的大数据框架，能够帮助用户实现从分布式存储、集群调度、流处理到机器学习、实时数据库等全方位的数据处理。

很多创业公司在搭建数据平台时首选就是这两个产品。不管是 CDH 还是 HDP 里面都集成了 Apache Kafka，因此把这两款产品中的 Kafka 称为 CDH Kafka 和 HDP Kafka。



#### 优

大数据平台天然集成了 Apache Kafka，通过便捷化的界面操作将 Kafka 的安装、运维、管理、监控全部统一在控制台中。所有的操作都可以在前端 UI 界面上完成，而不必去执行复杂的 Kafka 命令。



#### 劣

这样做的结果是直接降低了你对 Kafka 集群的掌控程度。

另一个弊端在于它的滞后性。

由于它有自己的发布周期，因此是否能及时地包含最新版本的 Kafka 就成为了一个问题。比如 CDH 6.1.0 版本发布时 Apache Kafka 已经演进到了 2.1.0 版本，但 CDH 中的 Kafka 依然是 2.0.0 版本，显然那些在 Kafka 2.1.0 中修复的 Bug 只能等到 CDH 下次版本更新时才有可能被真正修复。



### 小结

- Apache Kafka，也称社区版 Kafka。
  - 优势在于迭代速度快，社区响应度高，使用它可以让你有更高的把控度
  - 缺陷在于仅提供基础核心组件，缺失一些高级的特性。

- Confluent Kafka，Confluent 公司提供的 Kafka。
  - 优势在于集成了很多高级特性且由 Kafka 原班人马打造，质量上有保证
  - 缺陷在于相关文档资料不全，普及率较低，没有太多可供参考的范例。
- CDH/HDP Kafka，大数据云公司提供的 Kafka，内嵌 Apache Kafka。
  - 优势在于操作简单，节省运维成本
  - 缺陷在于把控度低，演进速度较慢。



## kafka 版本号



### Kafka 版本命名

![image-20220329191711226](https://tva1.sinaimg.cn/large/e6c9d24egy1h0qywsepyjj21660eignb.jpg)

其中前半部分为 Scala语言版本，后才为kafka版本，如上图所示

>  他们均符合x.y.z 命名规范

### Kafka 版本演进

Kafka 目前总共演进了 7 个大版本，分别是 0.7.x、0.8.x、0.9.x、0.10.x、0.11.x、1.x 、 2.x，3.x 其中的小版本和 Patch 版本很

多。

> 本文书写 时最新版本为 3.10（2022-03-29）

#### 0.7.x版本

很老的Kafka版本，它只有基本的**消息队列**功能，连消息副本机制都没有，不建议使用。



#### 0.8.x版本

两个重要特性，

一个是Kafka 0.8.0增加了副本机制，

另一个是Kafka 0.8.2.0引入了新版本Producer API。

新旧版本Producer API如下：

```dart
//旧版本Producer
kafka.javaapi.producer.Producer<K,V> 

//新版本Producer
org.apache.kafka.clients.producer.KafkaProducer<K,V>
```

与旧版本相比，新版本Producer API有点不同，一是连接Kafka方式上，旧版本的生产者及消费者API连接的是Zookeeper，而新版本则连接的是Broker；二是新版Producer采用异步方式发送消息，比之前同步发送消息的性能有所提升。但此时的新版Producer API尚不稳定，不建议生产使用。



#### 0.9.x版本

Kafka 0.9 是一个重大的版本迭代，增加了非常多的新特性，主要体现在三个方面：

- **安全方面**：在0.9.0之前，Kafka安全方面的考虑几乎为0。Kafka 0.9.0 在安全认证、授权管理、数据加密等方面都得到了支持，包括支持Kerberos等。
- **新版本Consumer API**：Kafka 0.9.0 重写并提供了新版消费端API，使用方式也是从连接Zookeeper切到了连接Broker，但是此时新版Consumer API也不太稳定、存在不少Bug，生产使用可能会比较痛苦；而0.9.0版本的Producer API已经比较稳定了，生产使用问题不大。
- **Kafka Connect**：Kafka 0.9.0 引入了新的组件 Kafka Connect ，用于实现Kafka与其他外部系统之间的数据抽取。



#### 0.10.x版本

Kafka 0.10 是一个重要的大版本，因为Kafka 0.10.0.0 引入了 Kafka Streams，使得Kafka不再仅是一个消息引擎，而是往一个分布式流处理平台方向发展。0.10 大版本包含两个小版本：0.10.1 和 0.10.2，它们的主要功能变更都是在 Kafka Streams 组件上。

值得一提的是，自 0.10.2.2 版本起，新版本 Consumer API 已经比较稳定了，而且 Producer API 的性能也得到了提升，因此对于使用 0.10.x 大版本的用户，建议使用或升级到 Kafka 0.10.2.2 版本。



#### 0.11.x版本

Kafka 0.11 是一个里程碑式的大版本，主要有两个大的变更，一是Kafka从这个版本开始支持 **Exactly-Once 语义**即精准一次语义，主要是实现了Producer端的消息幂等性，以及事务特性，这对于Kafka流式处理具有非常大的意义。

另一个重大变更是**Kafka消息格式的重构**，Kafka 0.11主要为了实现Producer幂等性与事务特性，重构了投递消息的数据结构。这一点非常值得关注，因为Kafka 0.11之后的消息格式发生了变化，所以我们要特别注意Kafka不同版本间消息格式不兼容的问题。



#### 1.x版本

Kafka 1.x 更多的是Kafka Streams方面的改进，以及Kafka Connect的改进与功能完善等。但仍有两个重要特性，一是Kafka 1.0.0实现了**磁盘的故障转移**，当Broker的某一块磁盘损坏时数据会自动转移到其他正常的磁盘上，Broker还会正常工作，这在之前版本中则会直接导致Broker宕机，因此Kafka的可用性与可靠性得到了提升；

二是Kafka 1.1.0开始支持**副本跨路径迁移**，分区副本可以在同一Broker不同磁盘目录间进行移动，这对于磁盘的[负载均衡](https://cloud.tencent.com/product/clb?from=10680)非常有意义。



#### 2.x版本

Kafka 2.x 更多的也是Kafka Streams、Connect方面的性能提升与功能完善，以及安全方面的增强等。一个使用特性，Kafka 2.1.0开始支持ZStandard的压缩方式，提升了消息的压缩比，显著减少了磁盘空间与网络io消耗。



#### 3.x版本

- 不再支持 Java 8 和 Scala 2.12
- Kafka Raft 支持元数据主题的快照以及自我管理的仲裁中的其他改进
- 为默认启用的 Kafka 生产者提供更强的交付保证
- 弃用消息格式 v0 和 v1
- OffsetFetch 和 FindCoordinator 请求的优化
- 更灵活的 Mirror Maker 2 配置和 Mirror Maker 1 的弃用
- 能够在 Kafka Connect 中的一次调用中重新启动连接器的任务
- 现在默认启用连接器日志上下文和连接器客户端覆盖
- Kafka Streams 中时间戳同步的增强语义
- 改进了 Stream 的 TaskId 的公共 API
- Kafka 中的默认 serde 变为 null





### Kafka版本建议

1. 遵循一个基本原则，Kafka客户端版本和服务端版本应该保持一致，否则可能会遇到一些问题。
2. 根据是否用到了Kafka的一些新特性来选择，假如要用到Kafka生产端的消息幂等性，那么建议选择Kafka 0.11 或之后的版本。
3. 选择一个自己熟悉且稳定的版本，如果说没有比较熟悉的版本，建议选择一个较新且稳定、使用比较广泛的版本。



## referer

[Apache Kafka 版本演进及特性介绍](https://cloud.tencent.com/developer/article/1596747)

[RELEASE_NOTES](https://archive.apache.org/dist/kafka/3.0.0/RELEASE_NOTES.html)
