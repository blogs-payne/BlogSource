---
title: GC垃圾回收原理
author: Payne
tags:
  - GC
categories:
  - - GC
    - 垃圾回收原理
abbrlink: 2352241434
date: 2022-04-30 19:05:41
---

## 如何判断对象是垃圾

### 经典判断方法 1：引用计数法

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxyvrbqaj20ev07ymxp.jpg)

思路很简单，但是如果出现循环引用，即 A 引用 B，B 又引用 A，这种情况下就不好办了。所以一般还使用了另一种称为“可达性分析”的判断方法。

### 经典判断方法 2：可达性分析

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxyyymz2j20hj084mxt.jpg)

如果 A 引用 B，B 又引用 A（发生了循环引用问题），这 2 个对象是否能被 GC回收？

关键不是在于 A、B 之间是否有引用，而是 A、B 是否可以一直向上追溯到 GC Roots。如果与 GC Roots 没有关联，则会被回收；否则，将继续存活。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxz0rom5j20g405sjrs.jpg)

上图是一个用“可达性分析”标记垃圾对象的示例图，灰色的对象表示不可达对象，将等待回收

## 哪些内存区域需要 GC

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxz5gnwtj20m80ccab1.jpg)

## 常用的 4 种 GC 算法

### mark-sweep 标记清除法

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxz88d9ej20iu0adjrm.jpg)

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry2t0q3mj20iu0adjrm.jpg)

黑色区域表示待清理的垃圾对象，标记出来后直接清空。

优：简单快速；

缺：产生很多内存碎片。

### mark-copy 标记复制法

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxzb2sivj20j90aoq37.jpg)

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxzdg4ivj20j90aoq37.jpg)

思路也很简单，将内存对半分，总是保留一块空着（上图中的右侧），将左侧存活的对象（浅灰色区域）复制到右侧，然后左侧全部清空。

优：避免了内存碎片问题；

缺：内存浪费很严重，相当于只能使用 50% 的内存。

### mark-compact 标记-整理（也称标记-压缩）法

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxzfpp7mj20j30akweq.jpg)

将垃圾对象清理掉后，同时将剩下的存活对象进行整理挪动（类似于 windows 的磁盘碎片整理），保证它们占用的空间连续。

优：节约了内存，并避免了内存碎片问题。

缺：整理过程会降低 GC 的效率。

上述三种算法，每种都有各自的优缺点，都不完美；在现代 JVM 中，往往是综合使用的。经过大量实际分析，发现内存中的对象，大致可以分为两类：

有些生命周期很短，比如一些局部变量/临时对象；

而另一些则会存活很久，典型的比如 websocket 长连接中的 connection 对象。如下图，纵向 y 轴可以理解分配内存的字节数，横向 x 轴理解为随着时间流逝（伴随着 GC）。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1rxzjx0woj20km0e9dge.jpg)

可以发现大部分对象其实相当短命，很少有对象能在 GC 后活下来，因此诞生了分代的思想。

### generation-collect 分代收集算法

如下图所示，可以将内存分成了三大块：年青代（Young Genaration）、老年代（Old Generation）、永久代（Permanent Generation）。其中 Young Genaration 更是又细为分
eden、S0、S1 三个区。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry01acb0j20ns0723z4.jpg)

结合我们经常使用的一些 jvm 调优参数后，一些参数能影响的各区域内存大小值，示意图如下：

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry02qg80j20u00jnjsq.jpg)

## GC 的主要过程

刚开始时，对象分配在 eden 区，s0（即：from）及 s1（即：to）区几乎是空着。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry0lve2fj20ky0cw74z.jpg)

随着应用的运行，越来越多的对象被分配到 eden 区。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry3fxogzj20jm0cqgmc.jpg)

当 eden 区放不下时，就会发生 minor GC（也被称为 young GC）。

首先当然是要先标识出不可达垃圾对象（即下图中的黄色块）；

然后将可达对象，移动到 s0 区（即：4个淡蓝色的方块挪到s0区）；

然后将黄色的垃圾块清理掉，这一轮后 eden 区就成空的了。

注：这里其实已经综合运用了“【标记-清理eden】+【标记-复制 eden->s0】”算法。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry0nc0w7j20m60bq3zi.jpg)

随着时间推移，eden 如果又满了，再次触发 minor GC，同样还是先做标记，这时 eden 和 s0 区可能都有垃圾对象了（下图中的黄色块）。

这时 s1（即：to）区是空的，s0 区和 eden 区的存活对象，将直接搬到 s1 区。

然后将 eden 和 s0 区的垃圾清理掉，这一轮 minor GC 后，eden 和 s0 区就变成了空的了。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry0rz9rhj20ly0dcdgv.jpg)

继续随着对象的不断分配，eden 空可能又满了，这时会重复刚才的 minor GC 过程。不过要注意的是：

这时候 s0 是空的，所以 s0 与 s1 的角色其实会互换。即存活的对象，会从 eden 和 s1 区，向 s0 区移动。

然后再把 eden 和 s1 区中的垃圾清除，这一轮完成后，eden 与 s1 区变成空的，如下图。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry0woahuj20li0dg3zk.jpg)

### 代龄与晋升

对于那些比较“长寿”的对象一直在 s0 与 s1 中挪来挪去，一来很占地方，而且也会造成一定开销，降低 gc 效率，于是有了“代龄(age)”及“晋升”。

对象在年青代的 3 个区（edge,s0,s1）之间，每次从一个区移到另一区，年龄 +1，在 young 区达到一定的年龄阈值后，将晋升到老年代。

下图中是 8，即挪动 8 次后，如果还活着，下次 minor GC 时，将移动到 Tenured 区。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry0xlvk2j20ke0eujsh.jpg)

### 晋升的主要过程

下图是晋升的主要过程：对象先分配在年青代，经过多次 Young GC 后，如果对象还活着，晋升到老年代。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry0zgme5j20de0ew74o.jpg)

如果老年代，最终也放满了，就会发生 major GC（即 Full GC）。由于老年代的的对象通常会比较多，标记-清理-整理（压缩）的耗时通常也会比较长，会让应用出现卡顿的现象。这也就是为什么很多应用要优化，尽量避免或减少 Full GC
的原因。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry11sat4j20jm0g8gmj.jpg)

注：上面的过程主要来自 oracle 官网的资料，但是有一个细节官网没有提到：如果分配的新对象比较大，eden 区放不下，但是 old 区可以放下时，会直接分配到 old 区。

即没有晋升这一过程，直接到老年代了。

### GC 流程图

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry13l204j20j90hg0ty.jpg)

## 8 种垃圾回收器

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry16k2irj219a0mijt1.jpg)

这些回收器都是基于分代的，把 G1 除外，按回收的分代划分如下。

横线以上的 3 种：Serial、ParNew、Parellel Scavenge 都是回收年青代的；

横线以下的 3 种：CMS、Serial Old、Parallel Old 都是回收老年代的。

接下来，我们将以上提到的 8 种垃圾回收器逐一讲解，其中 CMS、G1、ZGC 这三种收集器是面试考试重点，我也会着重讲解。

### Serial 收集器

&#x20;单线程用标记-复制算法，快刀斩乱麻，单线程的好处避免上下文切换，早期的机器，大多是单核，也比较实用。但执行期间会发生 STW（Stop The World）。

### ParNew 收集器

Serial 的多线程版本，也同样会 STW，在多核机器上会更适用。

### Parallel Scavenge 收集器

ParNew 的升级版本，主要区别在于提供了两个参数：

\-XX:MaxGCPauseMillis 最大垃圾回收停顿时间；

\-XX:GCTimeRatio 垃圾回收时间与总时间占比。

通过这 2 个参数，可以适当控制回收的节奏，更关注于吞吐率，即总时间与垃圾回收时间的比例。

### Serial Old 收集器

因为老年代的对象通常比较多，占用的空间通常也会更大。如果采用复制算法，得留 50% 的空间用于复制，相当不划算；而且因为对象多，从一个区，复制到另一个区，耗时也会比较长。

所以老年代的收集，通常会采用“标记-整理”法。从名字就可以看出来，这是单线程（串行）的， 依然会有 STW。

### Parallel Old 收集器

一句话：Serial Old 的多线程版本。

### CMS 收集器

Concurrent Mark Sweep，从名字上看，就能猜出它是并发多线程的。这是 JDK 7 中广泛使用的收集器，有必要多说一下。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1b60glj20u00jbjsz.jpg)

### G1 收集器

鉴于 CMS 的一些不足之外，比如：老年代内存碎片化，STW 时间虽然已经改善了很多，但是仍然有提升空间。G1 就横空出世了，它对于 heap 区的内存划思路很新颖，有点算法中分治法“分而治之”的味道。

> G1 的全称是 Garbage-First

#### G1 垃圾收集器的原理

如下图，G1 将 heap 内存区，划分为一个个大小相等（1-32M，2的 n 次方）、内存连续的 Region 区域，每个 region 都对应 Eden、Survivor 、Old、Humongous 四种角色之一，但是 region
与 region 之间不要求连续。

> 注：Humongous，简称 H 区是专用于存放超大对象的区域，通常 >= 1/2 Region Size，且只有 Full GC 阶段，才会回收 H 区，避免了频繁扫描、复制/移动大对象。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1bnt2nj20u00afq3t.jpg)

所有的垃圾回收，都是基于 1 个个 region 的。JVM 内部知道，哪些 region 的对象最少（即该区域最空），总是会优先收集这些 region（因为对象少，内存相对较空，肯定快）。这就是 Garbage-First 得名的由来，G
即是 Garbage 的缩写，1 即 First。

1. G1 Young GC young GC 前：

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry3j8ripj20k007oaan.jpg)

young GC 后：

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1efxdfj20k007eaak.jpg)

理论上讲，只要有一个 Empty Region（空区域），就可以进行垃圾回收。

由于 region 与 region 之间并不要求连续，而使用 G1 的场景通常是大内存，比如 64G 甚至更大，为了提高扫描根对象和标记的效率，G1 使用了二个新的辅助存储结构：

* Remembered Sets：简称 RSets，用于根据每个 region 里的对象，是从哪指向过来的（即谁引用了我），每个 Region 都有独立的 RSets（Other Region -> Self Region）。

* Collection Sets ：简称 CSets，记录了等待回收的 Region 集合，GC 时这些 Region 中的对象会被回收（copied or moved）。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1gs145j20gf0a1aae.jpg)

RSets 的引入，在 YGC 时，将年青代 Region 的 RSets 做为根对象，可以避免扫描老年代的 region，能大大减轻 GC 的负担。

> 注：在老年代收集 Mixed GC 时，RSets 记录了 Old->Old 的引用，也可以避免扫描所有 Old 区。

Old Generation Collection（也称为 Mixed GC）

按 oracle 官网文档描述，分为 5 个阶段：Initial Mark(STW) -> Root Region Scan -> Cocurrent Marking -> Remark(STW) -> Copying/Cleanup(
STW && Concurrent)

> 注：也有很多文章会把 Root Region Scan 省略掉，合并到 Initial Mark 里，变成 4 个阶段。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1iktitj20dh09aaa9.jpg)

阶段 1：存活对象的“初始标记”依赖于 Young GC，GC 日志中会记录成 young 字样。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1mixvuj20dm0983yt.jpg)

阶段 2：并发标记过程中，如果发现某些 region 全是空的，会被直接清除。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1nh65sj20dc09574h.jpg)

阶段 3：进入重新标记阶段。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1o63q3j20di097jrs.jpg)

阶段 4：并发复制/清查阶段。这个阶段，Young 区和 Old 区的对象有可能会被同时清理。GC 日志中，会记录为 mixed 字段，这也是 G1 的老年代收集，也称为 Mixed GC 的原因。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry3mdckmj20dc097aa8.jpg)

上图是，老年代收集完后的示意图。

通过这几个阶段的分析，虽然看上去很多阶段仍然会发生 STW，但是 G1 提供了一个预测模型，通过统计方法，根据历史数据来预测本次收集，需要选择多少个 Region 来回收，尽量满足用户的预期停顿值（-XX:MaxGCPauseMillis
参数可指定预期停顿值）。

> 注：如果 Mixed GC 仍然效果不理想，跟不上新对象分配内存的需求，会使用 Serial Old GC（Full GC）强制收集整个 Heap。

小结：与 CMS 相比，G1 有内存整理过程（标记-压缩），避免了内存碎片；STW 时间可控（能预测 GC 停顿时间）。

### ZGC（截止目前史上最好的 GC 收集器）

在 G1 的基础上，它做了如下 7 点改进

**动态调整大小的 Region**
G1 中每个 Region 的大小是固定的，创建和销毁 Region，可以动态调整大小，内存使用更高效。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1poir8j208w07caa0.jpg)

**不分代，干掉了 RSets**
G1 中每个 Region 需要借助额外的 RSets 来记录“谁引用了我”，占用了额外的内存空间，每次对象移动时，RSets 也需要更新，会产生开销。

**带颜色的指针 Colored Pointer**

这里的指针类似 Java 中的引用，意为对某块虚拟内存的引用。ZGC 采用了64位指针（注：目前只支持 linux 64 位系统），将 42-45 这 4 个 bit 位置赋予了不同含义，即所谓的颜色标志位，也换为指针的 metadata。

* finalizable 位：仅 finalizer（类比 C++ 中的析构函数）可访问；

* remap 位：指向对象当前（最新）的内存地址，参考下面提到的relocation；

* marked0 && marked1 位：用于标志可达对象。

这 4 个标志位，同一时刻只会有 1 个位置是 1。每当指针对应的内存数据发生变化，比如内存被移动，颜色会发生变化。

**读屏障 Load Barrier**

传统 GC 做标记时，为了防止其他线程在标记期间修改对象，通常会简单的 STW。而 ZGC 有了 Colored Pointer 后，引入了所谓的“读屏障”。

当指针引用的内存正被移动时，指针上的颜色就会变化，ZGC 会先把指针更新成最新状态，然后再返回（你可以回想下 Java 中的 volatile 关键字，有异曲同工之妙）。这样仅读取该指针时，可能会略有开销，而不用将整个 heap STW。

**重定位 Relocation**

如下图，在标记过程中，先从 Roots 对象找到了直接关联的下级对象 1，2，4。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1rjw8kj20u0080gm0.jpg)

然后继续向下层标记，找到了 5，8 对象， 此时已经可以判定 3，6，7 为垃圾对象。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry1y8q9zj20u0080aai.jpg)

如果按常规思路，一般会将 8 从最右侧的 Region，移动或复制到中间的 Region，然后再将中间 Region 的 3 干掉，最后再对中间 Region 做压缩 compact 整理。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry20tepej20u00aj74t.jpg)

但 ZGC 做得更高明，它直接将 4，5 复制到了一个空的新 Region 就完事了，然后中间的 2 个 Region 直接废弃，或理解为“释放”，作为下次回收的“新” Region。这样的好处是避免了中间 Region 的 compact
整理过程。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry22szyaj20u00ajq3l.jpg)

最后，指针重新调整为正确的指向（即：remap），而且上一阶段的 remap 与下一阶段的mark是混在一起处理的，相对更高效。

**多重映射 Multi-Mapping**

这个优化，说实话没完全看懂，只能谈下自己的理解（如果有误，欢迎指正)。虚拟内存与实际物理内存，OS 会维护一个映射关系，才能正常使用，如下图：

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry24pjryj20gp07ujrr.jpg)

zgc 的 64 位颜色指针，在解除映射关系时，代价较高（需要屏蔽额外的 42-45 的颜色标志位）。考虑到这 4 个标志位，同 1 时刻，只会有 1 位置成 1（如下图），另外 finalizable
标志位，永远不希望被解除映射绑定（可不用考虑映射问题）。

所以剩下 3 种颜色的虚拟内存，可以都映射到同1段物理内存。即映射复用，或者更通俗点讲，本来 3 种不同颜色的指针，哪怕 0-41 位完全相同，也需要映射到 3 段不同的物理内存，现在只需要映射到同 1 段物理内存即可。

支持 [NUMA 架构](https://baike.baidu.com/item/NUMA/6906025?fr=aladdin "NUMA 架构")

NUMA 是一种多核服务器的架构，简单来讲，一个多核服务器（比如 2core），每个 cpu 都有属于自己的存储器，会比访问另一个核的存储器会慢很多（类似于就近访问更快）。

相对之前的 GC 算法，ZGC 首次支持了 NUMA 架构，申请堆内存时，判断当前线程属是哪个CPU在执行，然后就近申请该 CPU 能使用的内存。

小结：革命性的 ZGC 经过上述一堆优化后，每次 GC 总体卡顿时间按官方说法<10ms。

> 注：启用 zgc，需要设置 -XX:+UnlockExperimentalVMOptions -XX:+UseZGC。

#### Remap 的流程图

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h1ry28bcsjj20ii0b5jry.jpg)
