---
title: 有人爱有人恨-GIL
author: Payne
tags:
  - GIL
categories:
  - - python
    - cpython
    - GIL
date: 2022-03-07 12:52:45
---



## 什么是GIL

GIL（Global Interpreter Lock，即全局解释器锁），是最流行的 Python 解释器 CPython 中的一个技术术语。它的意思是全局解释器锁，本质上是**类似操作系统的 Mutex**，它可以帮助CPython解决其在内存管理中存在的线程不安全问题。

每一个 Python 线程，在 CPython 解释器中执行时，都会先锁住自己的线程，阻止别的线程执行。

简而言之就是**任意时刻，Python 只有一个线程在同时运行**。

## 为什么需要GIL

在CPython中，**全局解释器锁**（GIL）是一个互斥体，用于保护对Python对象的访问，防止多个线程同时执行Python bytecodes。GIL的存在可**防止竞争确保线程安全**。

所以说，CPython 引进 GIL 主要原因:

- 设计者为了规避类似于内存管理这样的复杂的竞争风险问题（race condition）；
- 因为 CPython 大量使用 C 语言库，但大部分 C 语言库都不是原生线程安全的（线程安全会降低性能和增加复杂度）。

为什么 CPython 需要 GIL 呢？这其实和 CPython 的实现有关。Python 的内存管理机制，
CPython 使用引用计数来管理内存，所有 Python 脚本中创建的实例，都会有一个引用计数，来记录有多少个指针指向它。当引用计数只有 0 时，则会自动释放内存。



## GIL工作原理

1. 某个线程拿到GIL
2. 该线程执行代码，直到达到了check_interval*
3. 解释器让当前线程释放GIL
4. 所有的线程开始竞争GIL
5. 竞争到GIL锁的线程又从第1步开始执行

> Python2中，check_interavl是当前线程遇见IO操作或者ticks计数达到100*。*
>
> 在Python3中是执行时间达到阈值（默认为15毫秒）




## GIL存在的利弊

### 利

GIL 的设计，主要是为了方便 CPython 解释器层面的编写者

- 在单线程任务中更快；
- 在多线程任务中，对于I/O密集型程序运行更快；
- 在多线程任务中，对于用C语言包来实现CPU密集型任务的程序运行更快；
- 在写C扩展的时候更加容易，因为除非你在扩展中允许，否则Python解释器不会切换线程；
- 在打包C库时更加容易。我们不用担心线程安全性。，因为如果该库不是线程安全的，则只需在调用GIL时将其锁定即可。

### 弊

这种 GIL 锁的设计对于只使用单线程运行的code来说其实没有什么影响。但是对于计算密集型的程序（CPU-bound）和基于多线程的程序来说，Python 的 GIL 设计**很有可能会**造成性能瓶颈。

例子：

因为有GIL的存在，由CPython做解释器（虚拟机）的多线程Python程序只能利用多核处理器的一个核来运行。

例如，我们将一个8线程的JAVA程序运行在4核的处理器上，那么每个核会运行1个线程，然后利用时间片轮转，轮流运行每一个线程。

但是，我们将一个8线程的Python程序（由CPython作解释器）运行在一个4核处理器上，那么总共只会有1个核在工作，8个线程都要在这一个核上面时间片轮转。



## Python 的线程安全

有了 GIL，并不意味着我们 Python 编程者就不用去考虑线程安全了。即使我们知道，GIL 仅允许一个 Python 线程执行，但前面我也讲到了，Python 还有 **check interval** 这样的抢占机制。

所以有了 GIL 并不意味着你的Python程序就可以高枕无忧了，我们仍然需要去注意线程安全。

GIL 的设计，主要是为了方便 CPython 解释器层面的编写者，而不是 Python 应用层面的程序员。作为 Python 的使用者，我们还是需要 lock 等锁，来确保线程安全。



## Python多线程

CPython 会做一些小把戏，轮流执行 Python 线程。这样一来，用户看到的就是“伪并行”——Python 线程在交错执行，来模拟真正并行的线程。

**所以说Python的多线程是伪多线程**

### GIL 到底锁的是什么？

GIL 的全称是 Global Interpreter Lock, 全局解释器锁。它锁的是解释器而不是你的 Python 代码。它防止多线程同时执行 Python 的字节码(bytecodes)，防止多线程同时访问 Python 的对象。

在 Python 官方文档Releasing the GIL from extension code中，有这样一段话：

Here is how these functions work: **the global interpreter lock is used to protect the pointer to the current thread state.** When releasing the lock and saving the thread state, the current thread state pointer must be retrieved before the lock is released (since another thread could immediately acquire the lock and store its own thread state in the global variable). Conversely, when acquiring the lock and restoring the thread state, the lock must be acquired before storing the thread state pointer.

其中加黑的这一句话是说：GIL 锁用来保护指向当前进程**状态的指针**。

再看文档Thread State and the Global Interpreter Lock中提到的这样一句话：

Without the lock, even the simplest operations could cause problems in a multi-threaded program: for example, when two threads simultaneously increment the **reference count** of the same object, the reference count could end up being incremented only once instead of twice.



当两个线程同时提高同一个对象的引用计数时，（如果没有 GIL 锁）那么引用计数只会被提高了 1 次而不是 2 次。

大家注意这两段应用中的`指针`和`引用计数`。其中指针是 C 语言的概念，Python 没有指针；引用计数是 Python 底层的概念。你平时写的 Python 代码，引用计数是在你调用变量的时候自动增加的，不需要你去手动加 1.

所以 GIL 锁住的东西，都是不需要你的代码直接交互的东西。

Python 的解释器通过切换线程来模拟多线程并发的情况，如上面举的例子，虽然同一个时间只有一个线程在活动，但仍然可以导致并发冲突。



## GIL 对 Python 多线程开发的影响

在提到开发性能瓶颈的时候，我们经常把对资源的限制分为两类，

- 一类是计算密集型（CPU-bound）
- 一类是 I/O 密集型（I/O-bound）。

计算密集型的程序是指的是把 CPU 资源耗尽的程序，也就是说想要提高性能速度，就需要提供更多更强的 CPU，比如矩阵运算，图片处理这类程序。

I/O 密集型的程序只的是那些花费大量时间在等待 I/O 运行结束的程序，比如从用户指定的文件中读取数据，从数据库或者从网络中读取数据，I/O 密集型的程序对 CPU 的资源需求不是很高。



### 如何加速？

一般来说 IO 密集型用多线程、协程来加速，CPU 密集型用多进程来加速。

结合来看IO密集型使用协程 + 多进程 不失为“最佳”方案：

aiomultiprocess：[https://pypi.org/project/aiomultiprocess/](https://pypi.org/project/aiomultiprocess/)



**如何绕过GIL？**

你并不需要过多考虑 GIL。因为如果多线程计算成为性能瓶颈，往往已经有 Python 库来解决这个问题了。

绕过 GIL 的大致思路有这么两种：


- 绕过 CPython，使用 JPython（Java 实现的 Python 解释器）等别的实现；
- 把关键性能代码，放到别的语言（一般是 C++）中实现。

# 



## referer

[也许你对 Python GIL 锁的理解是 错的。—— kingname](https://mp.weixin.qq.com/s/a37OxUjgHdps1ZsPB7pKcQ)
