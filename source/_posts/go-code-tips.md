---
title: go code tips
author: Payne
tags:
  - go
categories:
  - - go
    - tips
abbrlink: 1679977151
date: 2022-05-01 13:54:21
---

## Go code tips

### 使用 pkg/errors

> https://pkg.go.dev/github.com/pkg/errors

我们在一个项目中使用错误机制，最核心的几个需求是什么？我觉得主要是这两点：

* 附加信息：我们希望错误出现的时候能附带一些描述性的错误信息，甚至这些信息是可以嵌套的
* 附加堆栈：我们希望错误不仅仅打印出错误信息，也能打印出这个错误的堆栈信息，可以知道出错的具体代码。

在 Go 语言的演进过程中，error 传递的信息太少一直是被诟病的一点。使用官方的 error 库，只能打印一条简单的错误信息，而没有更多的信息辅助快速定位错误。所以，推荐在应用层使用 `github.com/pkg/errors`
来替换官方的 error 库。因为使用 `pkg/errors`，我们不仅能传递出标准库 error 的错误信息，还能传递出抛出 error 的堆栈信息。

官方示例代码如下

```go
package main

import (
	"fmt"

	"github.com/pkg/errors"
)

func fn() error {
	e1 := errors.New("error")
	e2 := errors.Wrap(e1, "inner")
	e3 := errors.Wrap(e2, "middle")
	return errors.Wrap(e3, "outer")
}

func main() {
	type stackTracer interface {
		StackTrace() errors.StackTrace
	}

	err, ok := errors.Cause(fn()).(stackTracer)
	if !ok {
		panic("oops, err does not implement stackTracer")
	}

	st := err.StackTrace()
	fmt.Printf("%+v", st[0:2]) // top two frames

	// Example output:
	// github.com/pkg/errors_test.fn
	//	/home/dfc/src/github.com/pkg/errors/example_test.go:47
	// github.com/pkg/errors_test.Example_stackTrace
	//	/home/dfc/src/github.com/pkg/errors/example_test.go:127
}

```

### 在初始化 slice 的时候尽量补全 cap

> 当我们要创建一个 slice 结构，并且往 slice 中 append 元素的时候，我们可能有两种写法来初始化这个 slice。

```go
// 直接使用[]int 的方式来初始化
package main

import "fmt"

func main() {
    arr := []int{}
    arr = append(arr, 1, 2, 3, 4, 5)
    fmt.Println(arr)
}

// 使用 make 关键字来初始化

package main

import "fmt"

func main() {
   arr := make([]int, 0, 5)
   arr = append(arr, 1, 2, 3, 4, 5)
   fmt.Println(arr)
}
```

方法二相较于方法一，就只有一个区别：在初始化[]int slice 的时候在 make 中设置了 cap 的长度，就是 slice 的大小。

而且，这两种方法对应的功能和输出结果是没有任何差别的，但是实际运行的时候，方法二会比方法一少运行了一个 growslice 的命令，能够提升我们程序的运行性能。具体我们可以打印汇编码查看一下。

> 这个 growslice 的作用就是扩充 slice 容量，每当我们的 slice 容量小于我们需要使用的 slice 大小，这个函数就会被触发。
>
> 它的机制就好比是原先我们没有定制容量，系统给了我们一个能装两个鞋子的盒子，但是当我们装到第三个鞋子的时候，这个盒子就不够了，我们就要换一个盒子，而换这个盒子，我们势必还需要将原先的盒子里面的鞋子也拿出来放到新的盒子里面。
>
> 而 growsslice 的操作是一个比较复杂的操作，它的表现和复杂度会高于最基本的初始化 make 方法。对追求性能的程序来说，应该能避免就尽量避免。如果你对 growsslice 函数的具体实现感兴趣，你可以参考源码 src 的 runtime/slice.go 。

当然，并不是每次都能在 slice 初始化的时候，就准确预估到最终的使用容量，所以我这里说的是“尽量补全 cap”。明白是否设置 slice 容量的区别后，我们在能预估容量的时候，请尽量使用方法二那种预估容量后的 slice 初始化方式。

### 初始化一个类的时候，如果类的构造参数较多，尽量使用 Option 写法

遇到一定要初始化一个类的时候，大部分时候都会使用类似下列的 New 方法：

```go
type Foo struct {
   name string
   id int
   age int

   db interface{}
}

func NewFoo(name string, id int, age int, db interface{}) *Foo {
   return &Foo{
      name: name,
      id:   id,
      age:  age,
      db:   db,
   }
}
```

在这段代码中，我们定义一个 NewFoo 方法，其中存放初始化 Foo 结构所需要的各种字段属性。这个写法乍看之下是没啥问题的，但是一旦 Foo 结构内部的字段发生了变化，增加或者减少了，那么这个初始化函数 NewFoo
就怎么看怎么别扭了。参数继续增加？那么所有调用了这个 NewFoo 方法的地方也都需要进行修改，且按照代码整洁的逻辑，参数多于 5 个，这个函数就很难使用了。而且，如果这 5 个参数都是可有可无的参数，就是有的参数可以不填写，有默认值，比如
age 这个字段，即使我们不填写，在后续的业务逻辑中可能也没有很多影响，那么我在实际调用 NewFoo 的时候，age 这个字段还需要传递 0 值：

```go
foo := NewFoo("payne", 1, 0, nil)
```

乍看这行代码，你可能会以为我创建了一个 Foo，它的年龄为 0，但是实际上是希望表达这里使用了一个“缺省值”，这种代码的语义逻辑就不对了。

这里其实有一种更好的写法：**使用 Option 写法来进行改造**

Option 写法，顾名思义，就是将所有可选的参数作为一个可选方式，一般我们会设计一个“函数类型”来代表这个
Option，然后配套将所有可选字段设计为一个这个函数类型的具体实现。在具体的使用的时候，使用可变字段的方式来控制有多少个函数类型会被执行。比如上述的代码，我们会改造为：

```go

type Foo struct {
    name string
    id int
    age int

    db interface{}
}

// FooOption 代表可选参数
type FooOption func(foo *Foo)

// WithName 代表Name为可选参数
func WithName(name string) FooOption {
   return func(foo *Foo) {
      foo.name = name
   }
}

// WithAge 代表age为可选参数
func WithAge(age int) FooOption {
   return func(foo *Foo) {
      foo.age = age
   }
}

// WithDB 代表db为可选参数
func WithDB(db interface{}) FooOption {
   return func(foo *Foo) {
      foo.db = db
   }
}

// NewFoo 代表初始化
func NewFoo(id int, options ...FooOption) *Foo {
   foo := &Foo{
      name: "default",
      id:   id,
      age:  10,
      db:   nil,
   }
   for _, option := range options {
      option(foo)
   }
   return foo
}
```

我们创建了一个 FooOption 的函数类型，这个函数类型代表的函数结构是 func(foo *Foo) 。

这个结构很简单，就是将 foo 指针传递进去，能让内部函数进行修改。然后我们针对三个初始化字段 name，age，db 定义了三个返回了 FooOption 的函数，负责修改它们：

* WithName
* WithAge
* WithDB

以 WithName 为例，这个函数参数为 string，返回值为 FooOption。在返回值的 FooOption 中，根据参数修改了 Foo 指针。

```go
// WithName 代表Name为可选参数
func WithName(name string) FooOption {
   return func(foo *Foo) {
      foo.name = name
   }
}
```

有兴趣可以看看知名爬虫框架colly-https://github.com/gocolly/colly/blob/master/colly.go#L55，构造

### 巧用大括号控制变量作用域

在写 Go 的过程中，你一定有过为 := 和 = 烦恼的时刻。一个变量，到写的时候，我还要记得前面是否已经定义过了，如果没有定义过，使用 := ，如果已经定义过，使用 =。

当然很多时候你可能并不会犯这种错误，如果变量命名得比较好的话，我们是很容易记得这个变量前面是否有定义过的。但是更多时候，对于 err 这种通用的变量名字，你可能就不一定记得了。

**这个时候，巧妙使用大括号，就能很好避免这个问题。**

### 小结

* 使用 pkg/error 而不是官方 error 库
* 在初始化 slice 的时候尽量补全 cap
* 初始化一个类的时候，如果类的构造参数较多，尽量使用 Option 写法
* 巧用大括号控制变量作用域

这几种写法和注意事项都是我在工作和阅读开源项目中的一些总结和经验，每个经验都是对应为了解决不同的问题。虽然说 Go 已经对代码做了不少的规范和优化，但是好的代码和不那么好的代码还是有一些差距的，这些写法优化点就是其中一部分。
