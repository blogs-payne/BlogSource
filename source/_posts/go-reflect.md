---
title: go-reflect
author: Payne
tags:
  - go
categories:
  - - go
    - reflect
    - 反射
abbrlink: 586178490
date: 2022-05-02 21:46:53
---

## 反射简介

Go在标准库中提供的reflect包让Go程序具备运行时的反射能力（reflection）。反射是程序在运行时访问、检测和修改它本身状态或行为的一种能力，各种编程语言所实现的反射机制各有不同。

Go语言的`interface{}`类型变量具有析出任意类型变量的类型信息（type）和值信息（value）的能力，Go的反射本质上就是利用`interface{}`
的这种能力在运行时对任意变量的类型和值信息进行检视甚至是对值进行修改的机制。

反射让静态类型语言Go在运行时具备了某种基于类型信息的动态特性。利用这种特性，fmt.Println在无法提前获知传入参数的真正类型的情况下依旧可以对其进行正确的格式化输出

## 反射三大法则

Rob Pike还为Go反射的规范使用定义了三大法则，如果经过评估，你必须使用反射才能实现你要的功能特性，那么你在使用反射时需要牢记这三条法则。

* 反射世界的入口：经由接口（interface{}）类型变量值进入反射的世界并获得对应的反射对象（reflect.Value或reflect.Type）。
* 反射世界的出口：反射对象（reflect.Value）通过化身为一个接口（interface{}）类型变量值的形式走出反射世界。
* 修改反射对象的前提：反射对象对应的reflect.Value必须是可设置的（Settable）。

reflect.TypeOf和reflect.ValueOf是进入反射世界仅有的两扇“大门”。通过reflect.TypeOf这扇“门”进入反射世界，你将得到一个reflect.Type对象，该对象中包含了被反射的Go变量实例的所有类型信息；

而通过reflect.ValueOf这扇“门”进入反射世界，你将得到一个reflect.Value对象。Value对象是反射世界的核心，不仅该对象中包含了被反射的Go变量实例的值信息，而且通过调用该对象的Type方法，我们还可以得到Go变量实例的类型信息，这与通过reflect.TypeOf获得类型信息是等价的：

reflect.Value.Interface()是reflect.ValueOf()
的逆过程，通过Interface方法我们可以将reflect.Value对象恢复成一个interface{}类型的变量值。这个离开反射世界的过程实质是将reflect.Value中的类型信息和值信息重新打包成一个interface{}的内部表示。

## 小结

reflect包所提供的Go反射能力是一把“双刃剑”，它既可以被用于优雅地解决一类特定的问题，但也会带来逻辑不清晰、性能问题以及难于发现问题和调试等困惑。
因此，我们应谨慎使用这种能力，在做出使用的决定之前，认真评估反射是不是问题的唯一解决方案；在确定要使用反射能力后，也要遵循上述三个反射法则的要求。









