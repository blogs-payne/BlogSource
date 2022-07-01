---
title: go异常处理
author: Payne
tags:
  - go 
categories:
  - go
abbrlink: 1752556181
date: 2022-07-01 13:02:22
---

在了解go异常处理的时候,有必要先了解为什么需要做异常处理,异常处理主要在哪几个方面,区分异常和错误的区别等等.

## QA

### 为什么需要做异常处理?

我个人认为有一下几点

1. 从程序设计的角度来看, 保证程序的鲁棒性,健壮性
2. 从开发的角度来看,  快速定位问题,解决问题,预防问题

### 异常处理主要在哪几个方面

异常处理主要在实践上可以区分为 

- 业务层面: 保证业务的稳定性, 逻辑性
- 基础库: 保证代码逻辑正常

### 异常与错误的区别

编程语言中的异常和错误是两个相似但不相同的概念。异常和错误都可以引起程序执行错误而退出，他们属于程序没有考虑到的例外情况(exception)。

便于理解举个例子: 

一个网络请求, 没有网络-错误

一个网络请求过程中,对方服务器处理超时(注意是对方服务器正常) - 异常



## Error 和 Exception

### go error

>  go error 就是一个普通的接口, 普通的值.

```go
// https://golang.org/pkg/builtin/#error
type error interface {
    Error ()
}
```

经常使用 `errors.New()` 来返回一个 `error` 对象

```go
// https://go.dev/src/errors/errors.go

package errors

// New returns an error that formats as the given text.
// Each call to New returns a distinct error value even if the text is identical.
func New(text string) error {
	return &errorString{text}
}

// errorString is a trivial implementation of error.
type errorString struct {
	s string
}

func (e *errorString) Error() string {
	return e.s
}
```

> New() 返回的是 errorString对象的指针
>
> 为什么返回的是指针?
>
> - 避免创建的error的值一致



基础库中大量定义的error

```go
// https://go.dev/src/bufio/bufio.go

var (
	ErrInvalidUnreadByte = errors.New("bufio: invalid use of UnreadByte")
	ErrInvalidUnreadRune = errors.New("bufio: invalid use of UnreadRune")
	ErrBufferFull        = errors.New("bufio: buffer full")
	ErrNegativeCount     = errors.New("bufio: negative count")
)
```

tip: 在定义错误的时候带上包名,便于区分. 如`ErrInvalidUnreadByte = errors.New("bufio: invalid use of UnreadByte")` 中的`bufio:`

### Error VS Exception

各语言的演进历史

C: 但返回值, 入参通过传递指针作为入参, 返回int 表示成功还是失败, 以及如果失败的状态码是什么

C++: 引入了Exception,但无法知道被调用者抛出什么异常

Java: 引入了checked exception,方法的所有者必须申明, 调用者必须处理.

go: 支持多参数返回, 所以很容易在函数签名上实现了error interface的对象,交由调用者处理

> 如果一个函数返回了 `(value,error)`, 不能对这个`value`做任何假设, 必须先判定`error`

 补充: go中`panic`机制,意味着 fatal all, 不能假设调用者来解决`panic` 意味着代码down了

 **记录单一清晰的错误, 并处理!!!**

注意二值性

### go特征

- 简单
- 考虑失败而不是成功
- 没有隐藏的控制流
- 完全交给开发者来处理
- **Error are values**

 对于真正的错误, 表示不可恢复的程序错误,例如索引越界, 不可恢复的环境问题, 堆栈溢出,才使用`panic` ,对于其他的错误情况,应该是情况我使用error来进行判定 

## go error type

### Sentinel Error

预定义的特定错误,称之为 Sentinel Error. 这个名字起源于计算机编程中使用一个表示不可能进一步处理的做法. 使用特定值来表示错误.

```go
if err == ErrorSomething { ....}
// 类似于 io.EOF 更底层的syscall.ENOENT
```

使用 Sentinel Error 值是最不灵活的错误处理策略, 因为调用方法 必须使用`==`

将结果与预先声明的值进行比较. 当需要提供更多的上下文时,就会出现一个因为反返回一个不同的错误将被破坏相等性检查.

例如一些有意义的`fmt.Errorf` 携带一些上下文,也会破坏调用者的`==` ,调用者将被迫查看`error.Error()`方法的输出,以查看它是否与特定的字符串匹配

**tips:**

- 不依赖检查`error.Error`的输出.

>  不应该以来检测`error.Error`的输出, Error方法存在于error接口主要用于方便开发者使用,而不是程序(编写测试会依赖这个返回). 这个输出的字符串用于记录日志,输出到stdout

- Sentient errors 成为你API公共部分

> 如果公共函数或方法返回一个特定的值,那么该值必须是公共的,当然要有文档记录,这会增加API的表面积
>
> 如果API定义了以恶搞返回特定错误的`Interface` ,则该接口的所有实现都将被限制为仅返回该错误, 即使他们可以提供更具有描述性错误
>
> 比如: io.Reader. 像io.Copy这类函数需要reader的实现者比如返回 io.EOF 来告诉调用者没有更多数据量,但这又不是错误

- Sentient errors 在这个两个包之间创建依赖

> Sentinel errors 最糟糕的问题是他们在两个包之间创建了源码依赖关系
>
> 例如检查错误是否等于io.EOF, 代码就必须要导入io包, 虽然听起来似乎不那么糟糕,但想象一下,当项目中的许多包到处错误值时,存在耦合,项目中的其他包必须要导入这些错误值才能校验特定的错误条件

**建议:尽可能的避免使用 sentinel errors**

### Error Types

Error type 实现了error接口自定义类型.例如`ExampleError` 类型记录了文件和行号以及展示发生了什么. 如下代码所示

```go
import (
	"fmt"
)

type ExampleError struct {
	Msg      string
	FileName string
	Line     int
}

func (e *ExampleError) Error() string {
	return fmt.Sprintf(`%s:%d %s`, e.FileName, e.Line, e.Msg)
}

func test() error {
	return &ExampleError{`something happened`, `example.go`, 33}
}

func main() {
	err := test()
	switch err := err.(type) {
	case nil:
	// call succeeded, nothing to do
	case *ExampleError:
		fmt.Println(`Error occurred on call:`, err)
	default:
		// unknown error
	}
}
```

与错误值相比, 错误类型的优点是他们能够包装底层错误以提供更多上下文.

官方实例 os.PathError:

```go
type PathError struct {
	Op      string
	Path    string
	Err     int
}
```

调用者要使用类型断言和switch,就要让自定义的error变为公共的, 这种模型会导致和调用者产生强耦合,从而导致API非常脆弱

结论: 尽量避免使用error types,或者说尽量避免其成为公共API的一部分

虽然错误类型比sentinel error更完善,提供更多的上下文信息, 但error types 共享error value许多相同的问题.

### Opaque errors

>  不透明的错误处理

直接返回错误而不假设其内容

- Assert errors for behaviour, not type

> 在某些情况下,这种二分错误处理方法是不够的, 例如与外界交互(网络), 需要调用方法查错误的性质,以确定重试是否合理. 在这种情况下,可以使用断言错误实现了**特定的行为**.



