---
title: js调试小笔记
author: Payne
tags:
  - 爬虫
  - Crawler
  - Web Spider
  - 数据采集
  - JS
  - Chrome
  - JavaScript
  - 技巧
categories:
  - - 爬虫
    - Crawler
    - JavaScript
    - 技巧
    - JS
date: 2021-09-20 18:40:06
---

## 操作键

![image-20210920184244435](https://tva1.sinaimg.cn/large/008i3skNgy1guna6e3v4wj60bm01imwy02.jpg)



**resume/pause script execution**: 恢复/暂停脚本执行

**step over next function call**: 跨过，实际表现是不遇到函数时，执行下一步。遇到函数时，不进入函数直接执行下一步。

**step into next function call**: 跨入，实际表现是不遇到函数时，执行下一步。遇到到函数时，进入函数执行上下文。

**step out of current function**:跳出当前函数

**deactivate breakpoints**:停用断点

**don‘t pause on exceptions**:不暂停异常捕获



## Watch

![image-20210920184426027](https://tva1.sinaimg.cn/large/008i3skNgy1guna86ju6bj6042016gld02.jpg)

变量监听

定位到关键值时加入Watch中实现实时监听，可根据监听内容变化预估此变化。

## BreakPoints

所有断点列表，且自动按照执行顺序排序

![image-20210920184528622](https://tva1.sinaimg.cn/large/008i3skNgy1guna98mrchj60jm082mxp02.jpg)



## Scope

该范围内所有变量的值

![image-20210920185155365](https://tva1.sinaimg.cn/large/008i3skNgy1gunafyd9hhj60kc0mc40502.jpg)

## 调用栈

**一个 procedure（通常译作“过程”）吃进来一些参数，干一些事情，再吐出去一个返回值（或者什么也不吐）**

![image-20210920185959949](https://tva1.sinaimg.cn/large/008i3skNgy1gunaocua19j60co02m3ye02.jpg)



## XHR/fetch Breakpints

XHR/fetch Breakpints：请求断点（拦截），当发生符合要求的将触发定位到请求发送前一步

![image-20210920190017589](https://tva1.sinaimg.cn/large/008i3skNgy1gunaonikx8j60kw03kaa902.jpg)

## DOM Break points

当符合条件时触发定位到BOM

![image-20210920190528135](https://tva1.sinaimg.cn/large/008i3skNgy1gunau1dh9bj60ay038q2y02.jpg)

## Global Listeners

全局时间监听，包含所有时间，如点击、滑动等

![image-20210920190640937](https://tva1.sinaimg.cn/large/008i3skNgy1gunavas820j60g80ect9a02.jpg)

## Event Listener Break points

事件侦听器断点，监听所有事件与断点实现。

![image-20210920190803044](https://tva1.sinaimg.cn/large/008i3skNgy1gunawqe43pj60gw0nyjsk02.jpg)



### 预览几种不同的breakpoint类型

众人皆知的breakpoint类型是line-of-code。但是line-of-code型breakpoint有的时候没法设置（**其实就是没法在代码左边点出一个绿点来**），或者如果你正在使用一个大型的代码库。通过学习如何和何时使用这些不同类型的breakpoint debug，会大大节约你的时间。

| 断点类型                 | 当你想Pause的时候使用                                      |
| ------------------------ | ---------------------------------------------------------- |
| Line-of-code             | 代码具体某一行（**其实就是没法在代码左边点出一个绿点来**） |
| Conditional line-of-code | 代码具体某一行，但是只有在一些条件为true时                 |
| DOM                      | 在改变或者移除一个DOM节点或者它的DOM子节点时               |
| XHR                      | 当一个XHR URL包含一个string pattern                        |
| Event Listener           | 在运行了某个特定事件后的代码上，例如click事件触发          |
| Exception                | 在抛出了一个caught或者uncaught的exception时                |
| Function                 | 当一个函数被调用时                                         |

## this指向

全局作用域 this = window 

局部作用域 this = 调用者 

类的方法里面 this = 类自己



https://blog.csdn.net/xc_zhou/article/details/106269239

https://blog.csdn.net/qq_27324983/article/details/102467199
