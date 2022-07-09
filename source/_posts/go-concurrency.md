---
title: go-concurrency
author: Payne
tags:
  - go
categories:
  - - go
    - concurrency
abbrlink: 3870895095
date: 2022-07-03 11:25:25
---

## Process And Thread

​	操作系统会为应用程序创建一个进程, 作为应用程序. 它是一个为应用程序所有资源而运行的容器, 这些资源包含内存地址, 文件句柄, 设备和线程. 每个进程中都包含了一个主进程

线程是操作系统调度的一种执行路径, 用于在处理器中执行我们编写的代码.

一个进程从一个线程开始, 即主线程, 当该线程终止时，进程终止。这是因为主线程是应用程序的原点。然后，主线程可以依次启动更多的线程，而这些线程可以启动更多的线程。

> 无论线程属于哪个进程，操作系统都会安排线程在可用处理器上运行。每个操作系统都有自己的算法来做出这些决定。

## Goroutines and Parallelism

Go 语言层面支持的 go 关键字，可以快速的让一个函数创建为 goroutine，我们可以认为 main 函数就是作为 goroutine 执行的。操作系统调度线程在可用处理器上运行，Go运行时调度 goroutine 在绑定到单个操作系统线程的逻辑处理器中运行（P）。即使使用这个单一的逻辑处理器和操作系统线程，也可以调度数十万 goroutine 以惊人的效率和性能并发运行。

>  Concurrency is not Parallelism.

​		并发不是并行。并行是指两个或多个线程同时在不同的处理器执行代码。如果将运行时配置为使用多个逻辑处理器，则调度程序将在这些逻辑处理器之间分配 goroutine，这将导致 goroutine 在不同的操作系统线程上运行。但是，要获得真正的并行性，您需要在具有多个物理处理器的计算机上运行程序。否则，goroutine 将针对单个物理处理器并发运行，即使 Go 运行时使用多个逻辑处理器。

**Keep yourself busy or do the work yourself**

**Leave concurrency to the caller**

**Never start a goroutine without knowning when it will stop**

Any time you start a Goroutine you must ask yourself:

- When will it terminate?

- What could prevent it from terminating?

小结: 由开发者管理goroutine的生命周期, 将并发性交给调用方

