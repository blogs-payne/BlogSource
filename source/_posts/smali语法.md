---
title: smali语法
author: Payne
tags:
  - smail
categories:
  - - smali
    - Android
date: 2022-06-25 08:54:51
---
    

## Smali

**Smali是Android虚拟机的反汇编语言**

Android代码一般是用JVM语言编写，执行Androdi程序一般需要用到JVM，在Android平台上也不例外，但是出于性能上的考虑，并没有使用标准的JVM，而是使用专门的Android虚拟机（5.0以下为Dalvik，5.0以上为ART）。Android虚拟机的可执行文件并不是普通的class文件，而是再重新整合打包后生成的dex文件。smali是dex格式的文件的汇编器
反汇编器\ 其语法是一种宽松的jasmin/dedexer 语法,实现了.dex格式的所有功能(注解/调试信息/线路信息等)

## 为什么需要学习smali

1. 动态调试与修改APK, 当静态分析已经无法满足时,此时便需要对Android进行动态调试, 而动态调试便是调试smail
2. 修改APK运行逻辑, 通过修改smali代码,在重新打包.便可对app进行持久化的修改.(常用的注入均在外部而不是app内部)

## Smali基本语法

### 关键字

**语法关键字**

| 关键字          | 说明                                 |
| --------------- | ------------------------------------ |
| .class          | 定义类名                             |
| .super          | 定义父类名                           |
| .source         | 定义源文件名                         |
| .filed          | 定义字段                             |
| .method         | 定义方法开始                         |
| .end method     | 定义方法结束                         |
| .annotation     | 定义注解开始                         |
| .end annotation | 定义注解结束                         |
| .implements     | 定义接口指令                         |
| .local          | 指定了方法内局部变量的个数           |
| .registers      | 指定方法内使用寄存器的总数           |
| .prologue       | 表示方法中代码的开始处               |
| .line           | 表示java源文件中指定行               |
| .paramter       | 指定方法的参数                       |
| .param          | 和.paramter含义一致,但是表达格式不同 |

### 数据类型

| Smali          | Java     | 备注                                                         |
| -------------- | -------- | ------------------------------------------------------------ |
| v              | void     | 只能用于返回值类型                                           |
| Z              | boolean  |                                                              |
| B              | byte     |                                                              |
| S              | short    |                                                              |
| C              | char     |                                                              |
| I              | int      |                                                              |
| J              | long     |                                                              |
| F              | float    |                                                              |
| D              | double   |                                                              |
| Lpackage/name; | 对象类型 | L表示这是一个对象类型，package表示该对象所在的包，；表示对象名称的结束 |
| [类型          | 数组     | [I表示一个int型数据，[Ljava/lang/String 表示一个String的对象数组 |

**成员变量定义格式**

```bash
.field public/private [static][final] varName:<类型>
```

**获取指令**

```bash
iget, sget, iget-boolean, sget-boolean, iget-object, sget-object
```

**操作指令**

```bash 
iput, sput, iput-boolean, sput-boolean, iput-object, sput-object
array的操作是aget和aput
```

**指令解析**

```bash
sget-object v0,Lcom/aaa;->ID:Ljava/lang/String;
获取ID这个String类型的成员变量并放到v0这个寄存器中
iget-object v0,p0,Lcom/aaa;->view:Lcom/aaa/view;
iget-object比sget-object多一个参数p0，这个参数代表变量所在类的实例。这里p0就是this
```

example

```bash
// example 1 相当于java代码：this.timer = null;
const/4 v3, 0x0
sput-object v3, Lcom/aaa;->timer:Lcom/aaa/timer;

// example 2
.local v0, args:Landroid/os/Message;
const/4 v1, 0x12
iput v1,v0,Landroid/os/Message;->what:I
// 相当于java代码：args.what = 18; 其中args为Message的实例
```

**调用指令**
invoke-direct invoke-virtual invoke-static invoke-super invoke-interface

调用格式： invoke-指令类型 {参数1, 参数2,...}, L类名;->方法名 如果不是是静态方法，参数1代表调用该方法的实例。

## 寄存器

Java中变量都是存放在内存中的，Android为了提高性能，变量都是存放在寄存器中的，寄存器为32位，可以支持任何类型。64位类型(Long/ Double) 用2个格式的寄存器表示; Dalvik字节码有两种类型: 原始类型和引用类型(
包括对象和数组)

寄存器分为如下两类： 1、本地寄存器: 用v开头数字结尾的符号来表示，v0, v1, v2,... 2、参数寄存器: 用p开头数字结尾的符号来表示，p0,p1,p2,...
*注意：*
**在非static方法中，p0代指this，p1为方法的第一个参数。**
**在static方法中，p0为方法的第一个参数。**

```smali
const/4 v0, 0x1 //把值0x1存到v0本地寄存器
iput-boolean v0,p0,Lcom/aaa;->IsRegisterd:Z //把v0中的值赋给com.aaa.IsRegistered，p0代表this，相当于this.Isregistered=true
```

## tip:

查看smali代码时可以和java代码结合来看

## referer

https://www.jianshu.com/p/9931a1e77066

