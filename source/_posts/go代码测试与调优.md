---
title: go代码测试与调优
author: Payne
tags: ["Go"]
categories:
- ["Go"]
date: 2021-04-14 00:54:33
---
在了解golang的测试之前，先了解一下go语言自带的测试工具-go test

## go test工具

Go语言中的测试依赖`go test`命令。编写测试代码和编写普通的Go代码过程是类似的，并不需要学习新的语法、规则或工具。
<!--more-->
go test命令是一个按照一定约定和组织的测试代码的驱动程序。在包目录内，所有以`_test.go`为后缀名的源代码文件都是`go test`测试的一部分，不会被`go build`编译到最终的可执行文件中。

在`*_test.go`文件中有三种类型的函数，单元测试函数、基准测试函数和示例函数。

|   类型   |         格式          |              作用              |
| :------: | :-------------------: | :----------------------------: |
| 测试函数 |   函数名前缀为Test    | 测试程序的一些逻辑行为是否正确 |
| 基准函数 | 函数名前缀为Benchmark |         测试函数的性能         |
| 示例函数 |  函数名前缀为Example  |       为文档提供示例文档       |

#### 运行流程

`go test`命令会遍历所有的`*_test.go`文件中符合上述命名规则的函数，然后生成一个临时的main包用于调用相应的测试函数，然后构建并运行、报告测试结果，最后清理测试中生成的临时文件。

### 使用详解

上次对于`go test` 并没有详细的阐述，这次补上。

go test 的使用语法如下

```sh
go test [build/test flags] [packages] [build/test flags & test binary flags]
# 可以直接 go test 直接运行，那么它将运行本目录下的所有*_test.go的基准测试。
# 还可以进行编译后测试例如 go test build 
```

> 更多请查看 `go help testfunc`。
>
> `go test` 命令还会忽略 `testdata` 目录，该目录用来保存测试需要用到的辅助数据。
>
> go test 有两种运行模式：
>
> 1、本地目录模式，在没有包参数（例如 `go test` 或 `go test -v`）调用时发生。在此模式下，`go test` 编译当前目录中找到的包和测试，然后运行测试二进制文件。在这种模式下，caching 是禁用的。在包测试完成后，`go test` 打印一个概要行，显示测试状态、包名和运行时间。
>
> 2、包列表模式，在使用显示包参数调用 `go test` 时发生（例如 `go test math`，`go test ./...` 甚至是 `go test .`）。在此模式下，go 测试编译并测试在命令上列出的每个包。如果一个包测试通过，`go test` 只打印最终的 `ok` 总结行。如果一个包测试失败，`go test` 将输出完整的测试输出。如果使用 `-bench` 或 `-v` 标志，则 `go test` 会输出完整的输出，甚至是通过包测试，以显示所请求的基准测试结果或详细日志记录。
>
> 下面详细说明下 `go test` 的具体用法，flag 的作用及一些相关例子。需要说明的是：一些 flag 支持 `go test` 命令和编译后的二进制测试文件。它们都能识别加 `-test.` 前缀的 flag，如 `go test -test.v`，但编译后的二进制文件必须加前缀 `./sum.test -test.bench=.`。

参数详解

### test flag

以下 flag 可以跟被 `go test` 命令使用：

- `-args`：传递命令行参数，该标志会将 -args 之后的参数作为命令行参数传递，最好作为最后一个标志。

```
  $ go test -args -p=true
```

- `-c`：编译测试二进制文件为 [pkg].test，不运行测试。

```
  $ go test -c && ./sum.test -p=true
```

- `-exec xprog`：使用 xprog 运行测试，行为同 `go run` 一样，查看 `go help run`。
- `-i`：安装与测试相关的包，不运行测试。

```
  $ go test -i
```

- `-o file`：编译测试二进制文件并指定文件，同时运行测试。

```
  go test -o filename
```

### test/binary flag

以下标志同时支持测试二进制文件和 `go test` 命令。

- `-bench regexp`：通过正则表达式执行基准测试，默认不执行基准测试。可以使用 `-bench .`或`-bench=.`执行所有基准测试。

```
  $ go test -bench=.
  $ go test -c
  $ ./sum.test -test.bench=.
```

- `-benchtime t`：每个基准测试运行足够迭代消耗的时间，time.Duration（如 -benchtime 1h30s），默认 1s。

```
  $ go test -bench=. -benchtime 0.1s
  $ ./sum.test -test.bench=. -test.benchtime=1s
```

- `-count n`：运行每个测试和基准测试的次数（默认 1），如果 -cpu 指定了，则每个 GOMAXPROCS 值执行 n 次，Examples 总是运行一次。

```
  $ go test -bench=. -count=2
  $ ./sum.test -test.bench=. -test.count=2
```

- `-cover`：开启覆盖分析，开启覆盖分析可能会在编译或测试失败时，代码行数不对。

```
  $ go test -bench=. -cover
```

- ```
  -covermode set,count,atomic
  ```

  ：覆盖分析的模式，默认是 set，如果设置 -race，将会变为 atomic。

    - set，bool，这个语句运行吗？
    - count，int，该语句运行多少次？
    - atomic，int，数量，在多线程正确使用，但是耗资源的。

- `-coverpkg pkg1,pkg2,pkg3`：指定分析哪个包，默认值只分析被测试的包，包为导入的路径。

```
  # sum -> $GOPATH/src/test/sum
  $ go test -coverpkg test/sum
```

- `-cpu 1,2,4`：指定测试或基准测试的 GOMAXPROCS 值。默认为 GOMAXPROCS 的当前值。
- `-list regexp`：列出与正则表达式匹配的测试、基准测试或 Examples。只列出顶级测试（不列出子测试），不运行测试。

```
  $ go test -list Sum
```

- `-parallel n`：允许并行执行通过调用 t.Parallel 的测试函数的最大次数。默认值为 GOMAXPROCS 的值。-parallel 仅适用于单个二进制测试文件，但`go test`命令可以通过指定 -p 并行测试不同的包。查看 `go help build`。

```
  $ go test -run=TestSumParallel -parallel=2
```

- `-run regexp`：只运行与正则表达式匹配的测试和Examples。可以通过 / 来指定测试子函数。`go test Foo/A=`，会先去匹配并执行 Foo 函数，再查找子函数。

```
  $ go test -v -run TestSumSubTest/1+
```

- `-short`：缩短长时间运行的测试的测试时间。默认关闭。

```
  $ go test -short
```

- `-timeout d`：如果二进制测试文件执行时间过长，panic。默认10分钟（10m）。

```
  $ go test -run TestSumLongTime -timeout 1s
```

- `-v`：详细输出，运行期间所有测试的日志。

```
  $ go test -v
```

### analyze flag

以下测试适用于 `go test` 和测试二进制文件：

- `-benchmem`：打印用于基准的内存分配统计数据。

```
  $ go test -bench=. -benchmem
  $ ./sum.test -test.bench -test.benchmem
```

- `-blockprofile block.out`：当所有的测试都完成时，在指定的文件中写入一个 goroutine 阻塞概要文件。指定 -c，将写入测试二进制文件。

```
  $ go test -v -cpuprofile=prof.out
  $ go tool pprof prof.out
```

- `-blockprofilerate n`：goroutine 阻塞时候打点的纳秒数。默认不设置就相当于 -test.blockprofilerate=1，每一纳秒都打点记录一下。
- `-coverprofile cover.out`：在所有测试通过后，将覆盖概要文件写到文件中。设置过 -cover。
- `-cpuprofile cpu.out`：在退出之前，将一个 CPU 概要文件写入指定的文件。
- `-memprofile mem.out`：在所有测试通过后，将内存概要文件写到文件中。
- `-memprofilerate n`：开启更精确的内存配置。如果为 1，将会记录所有内存分配到 profile。

```
  $ go test -memprofile mem.out -memprofilerate 1
  $ go tool pprof mem.out
```

- `-mutexprofile mutex.out`：当所有的测试都完成时，在指定的文件中写入一个互斥锁争用概要文件。指定 -c，将写入测试二进制文件。
- `-mutexprofilefraction n`：样本 1 在 n 个堆栈中，goroutines 持有 a，争用互斥锁。
- `-outputdir directory`：在指定的目录中放置输出文件，默认情况下，`go test` 正在运行的目录。
- `-trace trace.out`：在退出之前，将执行跟踪写入指定文件。



## 单元测试

> 以下是来自wiki对于单元测试的定义

在[计算机编程](https://zh.wikipedia.org/wiki/计算机编程)中，**单元测试**（英语：Unit Testing）又称为**模块测试**，是针对[程序模块](https://zh.wikipedia.org/wiki/模組_(程式設計))（[软件设计](https://zh.wikipedia.org/wiki/软件设计)的最小单位）来进行正确性检验的测试工作。程序单元是应用的最小可测试部件。在[过程化编程](https://zh.wikipedia.org/wiki/過程化編程)中，一个单元就是单个程序、函数、过程等；对于面向对象编程，最小单元就是方法，包括基类（超类）、抽象类、或者派生类（子类）中的方法。

通常来说，程序员每修改一次程序就会进行最少一次单元测试，在编写程序的过程中前后很可能要进行多次单元测试，以证实程序达到[软件规格书](https://zh.wikipedia.org/wiki/規格_(技術標準))要求的工作目标，没有[程序错误](https://zh.wikipedia.org/wiki/Bug)；虽然单元测试不是必须的，但也不坏，这牵涉到[项目管理](https://zh.wikipedia.org/wiki/專案管理)的政策决定。

每个理想的[测试案例](https://zh.wikipedia.org/wiki/测试案例)独立于其它案例；为测试时隔离模块，经常使用stubs、mock[[1\]](https://zh.wikipedia.org/wiki/单元测试#cite_note-mocksarentstubs-1)或fake等测试[马甲程序](https://zh.wikipedia.org/w/index.php?title=马甲程序&action=edit&redlink=1)。单元测试通常由[软件开发人员](https://zh.wikipedia.org/w/index.php?title=软件开发人员&action=edit&redlink=1)编写，用于确保他们所写的代码符合软件需求和遵循[开发目标](https://zh.wikipedia.org/w/index.php?title=开发目标&action=edit&redlink=1)。它的实施方式可以是非常手动的（透过纸笔），或者是做成[构建自动化](https://zh.wikipedia.org/wiki/構建自動化)的一部分。

简单来说，单元测试就是程序员自己对于自己的代码进行测试，而一个单元就是单个程序、函数、过程等；对于面向对象编程，最小单元就是方法，包括基类（超类）、抽象类、或者派生类（子类）中的方法。

更有一种开发手法，那就是TDD（Test Driven Development）,测试驱动开发。期望局部最优到全局最优，这个是一种非常不错的好习惯

> 请注意这里的局部最优的，局部，并不是函数内的详细。而是整个函数。甚至是一个类，等等。
>
> 因为有些函数内部的最优，并非这个函数的最优。这点需要格外的注意。若有兴趣，可了解一下有点关系的贪心算法

### 测试函数格式

其中参数`t`用于报告测试失败和附加的日志信息。 `testing.T`的拥有的方法如下：

```go
func (c *T) Error(args ...interface{})
func (c *T) Errorf(format string, args ...interface{})
func (c *T) Fail()
func (c *T) FailNow()
func (c *T) Failed() bool
func (c *T) Fatal(args ...interface{})
func (c *T) Fatalf(format string, args ...interface{})
func (c *T) Log(args ...interface{})
func (c *T) Logf(format string, args ...interface{})
func (c *T) Name() string
func (t *T) Parallel()
func (t *T) Run(name string, f func(t *T)) bool
func (c *T) Skip(args ...interface{})
func (c *T) SkipNow()
func (c *T) Skipf(format string, args ...interface{})
func (c *T) Skipped() bool
```

说了这么多，来实现一个`简单的`string中的Split函数，并对他进行单元测试，然后在剖析代码。了解单元测试的相关规范

```go
// splits.go
package splitStr

import (
	"strings"
)

// split package with a single split function.

// Split slices s into all substrings separated by sep and
// returns a slice of the substrings between those separators.
func Split(s, sep string) (result []string) {
	i := strings.Index(s, sep)
	for i > -1 {
		result = append(result, s[:i])
		s = s[i+1:]
		i = strings.Index(s, sep)
	}
	result = append(result, s)
	return
}

// split_test.go
package splitStr

import (
	"reflect"
	"testing"
)

// TestSplit 单元测试
func TestSplit(t *testing.T) { // 测试函数名必须以Test开头，必须接收一个*testing.T类型参数
	got := Split("a:b:c", ":")         // 程序输出的结果
	want := []string{"a", "b", "c"}    // 期望的结果
	if !reflect.DeepEqual(want, got) { // 因为slice不能直接比较，借助反射包中的方法比较
		t.Errorf("excepted:%v, got:%#v", want, got) // 测试失败输出错误提示
	}
}

// TestSplit2 单元测试组
func TestSplit2(t *testing.T) {
	// 定义一个测试用例类型
	type test struct {
		input string
		sep   string
		want  []string
	}
	// 定义一个存储测试用例的切片
	tests := []test{
		{input: "a:b:c", sep: ":", want: []string{"a", "b", "c"}},
		{input: "a:b:c", sep: ",", want: []string{"a:b:c"}},
		{input: "abcd", sep: "bc", want: []string{"a", "d"}},
	}
	// 遍历切片，逐一执行测试用例
	for _, tc := range tests {
		got := Split(tc.input, tc.sep)
		if !reflect.DeepEqual(got, tc.want) {
			t.Errorf("excepted:%v, got:%#v", tc.want, got)
		}
	}
}
```

运行结果如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnrolzdwnuj318y0dq3z2.jpg)

说明测试成功，本次通过。当然你也可以在`Terminal`里面直接运行`go test`，命令，如下所示

<img src="https://tva1.sinaimg.cn/large/008eGmZEgy1gnropdatxhj30oa0bg0t4.jpg" style="zoom:70%;" />



> 温馨提示：关于可能造成运行test不成功原因
>
> 直接在`split_test.go`,运行。
>
> - 或许知道，go是以文件夹的方法来区分项目。所以当前文件，并不能跑到旁边文件中去找到`Split`,以至于测试失败。或未达到预期效果
>
> 那么正确的打开方式应该是？
>
> 在goland中，鼠标右键点击run测试文件所在的文件夹，选择后面第二个 `go test projectFileName`
>
> 在`Terminal`中，应在`测试文件所在的文件夹`的路径中，进行`go test [arge...]`

示例看完了，那么进行简单的剖析。先从函数文件说起，(也就是这里的`splits.go`)

1. 不在是`package main`,而是`packge projectFileName`
2. 函数名大写，大写意味着公有函数，可支持外部调用

测试文件

1. 文件名为'*_test.go'
2. 不在是`package main`,而是`packge projectFileName`
3. 函数名为TestFuncName



## 基准测试

### 基准测试函数格式

基准测试就是在一定的工作负载之下检测程序性能的一种方法。基准测试的基本格式如下：

```go
func BenchmarkName(b *testing.B){
    // ...
}
```

基准测试以`Benchmark`为前缀，需要一个`*testing.B`类型的参数b，基准测试必须要执行`b.N`次，这样的测试才有对照性，`b.N`的值是系统根据实际情况去调整的，从而保证测试的稳定性。 `testing.B`拥有的方法如下：

```go
func (c *B) Error(args ...interface{})
func (c *B) Errorf(format string, args ...interface{})
func (c *B) Fail()
func (c *B) FailNow()
func (c *B) Failed() bool
func (c *B) Fatal(args ...interface{})
func (c *B) Fatalf(format string, args ...interface{})
func (c *B) Log(args ...interface{})
func (c *B) Logf(format string, args ...interface{})
func (c *B) Name() string
func (b *B) ReportAllocs()
func (b *B) ResetTimer()
func (b *B) Run(name string, f func(b *B)) bool
func (b *B) RunParallel(body func(*PB))
func (b *B) SetBytes(n int64)
func (b *B) SetParallelism(p int)
func (c *B) Skip(args ...interface{})
func (c *B) SkipNow()
func (c *B) Skipf(format string, args ...interface{})
func (c *B) Skipped() bool
func (b *B) StartTimer()
func (b *B) StopTimer()
```

### 基准测试示例

为自己写的`Split`函数编写基准测试如下：

```go
// BenchmarkSplit 基准测试(性能测试)
func BenchmarkSplit(b *testing.B) {
	for i := 0; i <b.N ; i++ {
		Split("abcdebdae", "b")
	}
}

// 输出结果如下
goos: darwin
goarch: amd64
pkg: Gp/part5/splitStr
BenchmarkSplit
BenchmarkSplit-8   	 5740642	       209 ns/op
PASS
ok  	Gp/part5/splitStr	1.963s
```

> 其中
>
> BenchmarkSplit：表示对Split函数进行基准测试
>
> BenchmarkSplit-8：数字`8`表示`GOMAXPROCS`的值，这个对于并发基准测试很重要
>
> 5188407和206 ns/op：表示每次调用`Split`函数耗时`203ns`

还可以为基准测试添加`-benchmem`参数，来获得内存分配的统计数据。

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnrw3i5yuej312k07adg0.jpg)

>  112 B/op：表示每次操作内存分配了112字节
>
> `3 allocs/op`：则表示每次操作进行了3次内存分配！！！

优化后代码如下

```go
// split.go
func Split(s, sep string) (result []string) {
	i := strings.Index(s, sep)
  // 手动分配固定内存，避免多次创建
	result = make([]string, 0, strings.Count(s, sep)+1)
	for i > -1 {
		result = append(result, s[:i])
		s = s[i+len(sep):] // 这里使用len(sep)获取sep的长度
		i = strings.Index(s, sep)
	}
	result = append(result, s)
	return
}
```

优化后代码如下

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gnrx800j18j314g07gjrk.jpg)

> 这个使用make函数提前分配内存的改动，减少了2/3的内存分配次数，并且减少了一半的内存分配。
>
> 仅仅小小的一处改动，就引起如此大的性能改变。so good
>
> 量变产生质变

### 性能比较函数

上面的基准测试只能得到给定操作的绝对耗时，但是在很多性能问题是发生在两个不同操作之间的相对耗时，比如同一个函数处理1000个元素的耗时与处理1万甚至100万个元素的耗时的差别是多少？再或者对于同一个任务究竟使用哪种算法性能最佳？通常需要对两个不同算法的实现使用相同的输入来进行基准比较测试。

性能比较函数通常是一个带有参数的函数，被多个不同的Benchmark函数传入不同的值来调用。举个例子如下：

```go
func benchmark(b *testing.B, size int){/* ... */}
func Benchmark10(b *testing.B){ benchmark(b, 10) }
func Benchmark100(b *testing.B){ benchmark(b, 100) }
func Benchmark1000(b *testing.B){ benchmark(b, 1000) }
```

例如编写了一个计算斐波那契数列的函数如下：

```go
// fib.go

// Fib 是一个计算第n个斐波那契数的函数
func Fib(n int) int {
	if n < 2 {
		return n
	}
	return Fib(n-1) + Fib(n-2)
}
```

编写的性能比较函数如下：

```go
// fib_test.go

func benchmarkFib(b *testing.B, n int) {
	for i := 0; i < b.N; i++ {
		Fib(n)
	}
}

func BenchmarkFib1(b *testing.B)  { benchmarkFib(b, 1) }
func BenchmarkFib2(b *testing.B)  { benchmarkFib(b, 2) }
func BenchmarkFib3(b *testing.B)  { benchmarkFib(b, 3) }
func BenchmarkFib10(b *testing.B) { benchmarkFib(b, 10) }
func BenchmarkFib20(b *testing.B) { benchmarkFib(b, 20) }
func BenchmarkFib40(b *testing.B) { benchmarkFib(b, 40) }
```

运行基准测试：

```bash
split $ go test -bench=.
goos: darwin
goarch: amd64
pkg: github.com/payne/Gp/code_demo/test_demo/fib
BenchmarkFib1-8         1000000000               2.03 ns/op
BenchmarkFib2-8         300000000                5.39 ns/op
BenchmarkFib3-8         200000000                9.71 ns/op
BenchmarkFib10-8         5000000               325 ns/op
BenchmarkFib20-8           30000             42460 ns/op
BenchmarkFib40-8               2         638524980 ns/op
PASS
ok      github.com/payne/Gp/code_demo/test_demo/fib 12.944s
```

这里需要注意的是，默认情况下，每个基准测试至少运行1秒。如果在Benchmark函数返回时没有到1秒，则b.N的值会按1,2,5,10,20,50，…增加，并且函数再次运行。

最终的BenchmarkFib40只运行了两次，每次运行的平均值只有不到一秒。像这种情况下应该可以使用`-benchtime`标志增加最小基准时间，以产生更准确的结果。例如：

```bash
split $ go test -bench=Fib40 -benchtime=20s
goos: darwin
goarch: amd64
pkg: github.com/payne/Gp/code_demo/test_demo/fib
BenchmarkFib40-8              50         663205114 ns/op
PASS
ok      github.com/payne/Gp/code_demo/test_demo/fib 33.849s
```

这一次`BenchmarkFib40`函数运行了50次，结果就会更准确一些了。

使用性能比较函数做测试的时候一个容易犯的错误就是把`b.N`作为输入的大小，例如以下两个例子都是错误的示范：

```go
// 错误示范1
func BenchmarkFibWrong(b *testing.B) {
	for n := 0; n < b.N; n++ {
		Fib(n)
	}
}

// 错误示范2
func BenchmarkFibWrong2(b *testing.B) {
	Fib(b.N)
}
```



## 重置时间

`b.ResetTimer`之前的处理不会放到执行时间里，也不会输出到报告中，所以可以在之前做一些不计划作为测试报告的操作。例如：

```go
func BenchmarkSplit(b *testing.B) {
	time.Sleep(2 * time.Second) // 假设需要做一些耗时的无关操作
	b.ResetTimer()              // 重置计时器
	for i := 0; i < b.N; i++ {
		strings.Split("山河和河山", "和")
	}
}
```

## 并行测试

`func (b *B) RunParallel(body func(*PB))`会以并行的方式执行给定的基准测试。

`RunParallel`会创建出多个`goroutine`，并将`b.N`分配给这些`goroutine`执行， 其中`goroutine`数量的默认值为`GOMAXPROCS`。用户如果想要增加非CPU受限（non-CPU-bound）基准测试的并行性， 那么可以在`RunParallel`之前调用`SetParallelism` 。`RunParallel`通常会与`-cpu`标志一同使用。

```go
func BenchmarkSplitParallel(b *testing.B) {
	// b.SetParallelism(1) // 设置使用的CPU数
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			Split("山河和河山", "和")
		}
	})
}
```

执行一下基准测试：

```bash
split $ go test -bench=.
goos: darwin
goarch: amd64
pkg: github.com/payne/Gp/code_demo/test_demo/split
BenchmarkSplit-8                10000000               131 ns/op
BenchmarkSplitParallel-8        50000000                36.1 ns/op
PASS
ok      github.com/payne/Gp/code_demo/test_demo/split       3.308s
```

还可以通过在测试命令后添加`-cpu`参数如`go test -bench=. -cpu 1`来指定使用的CPU数量。

## Setup与TearDown

测试程序有时需要在测试之前进行额外的设置（setup）或在测试之后进行拆卸（teardown）。



## Go性能优化

做了这么多的测试最终的目的是测试代码有没有写对，性能是否可以优化。接下来进行性能优化与调优

在计算机性能调试领域里，profiling 是指对应用程序的画像，画像就是应用程序使用 CPU 和内存的情况。 Go语言是一个对性能特别看重的语言，因此语言中自带了 profiling 的库。

Go语言项目中的性能优化主要有以下几个方面：

- CPU profile：报告程序的 CPU 使用情况，按照一定频率去采集应用程序在 CPU 和寄存器上面的数据
- Memory Profile（Heap Profile）：报告程序的内存的使用情况
- Block Profiling：报告 goroutine 不在运行状态的情况，可以用来分析与查找死锁等性能瓶颈
- Goroutine Profiling：报告 goroutines 的使用情况，有哪些 goroutine，它们的调用关系是怎样的

### 采集性能数据

Go语言内置了获取程序的运行数据的工具，包括以下两个标准库：

- `runtime/pprof`：采集工具型应用运行数据进行分析
- `net/http/pprof`：采集服务型应用运行时数据进行分析

pprof开启后，每隔一段时间（10ms）就会收集下当前的堆栈信息，获取各个函数占用的CPU以及内存资源；最后通过对这些采样数据进行分析，形成一个性能分析报告。

### pprof应用

如果你的应用程序是运行一段时间就结束退出类型。那么最好的办法是在应用退出的时候把 profiling 的报告保存到文件中，进行分析。对于这种情况，可以使用`runtime/pprof`库。 首先在代码中导入`runtime/pprof`工具：

```go
import "runtime/pprof"
```

### CPU性能分析

开启CPU性能分析：

```go
pprof.StartCPUProfile(w io.Writer)
```

停止CPU性能分析：

```go
pprof.StopCPUProfile()
```

应用执行结束后，就会生成一个文件，保存了 CPU profiling 数据。得到采样数据之后，使用`go tool pprof`工具进行CPU性能分析。

### 内存性能优化

记录程序的堆栈信息

```go
pprof.WriteHeapProfile(w io.Writer)
```

得到采样数据之后，使用`go tool pprof`工具进行内存性能分析。

`go tool pprof`默认是使用`-inuse_space`进行统计，还可以使用`-inuse-objects`查看分配对象的数量。

## 服务型应用

如果你的应用程序是一直运行的，比如 web 应用，那么可以使用`net/http/pprof`库，它能够在提供 HTTP 服务进行分析。

如果使用了默认的`http.DefaultServeMux`（通常是代码直接使用 http.ListenAndServe(“0.0.0.0:8000”, nil)），只需要在你的web server端代码中按如下方式导入`net/http/pprof`

```go
import _ "net/http/pprof"
```

如果你使用自定义的 Mux，则需要手动注册一些路由规则：

```go
r.HandleFunc("/debug/pprof/", pprof.Index)
r.HandleFunc("/debug/pprof/cmdline", pprof.Cmdline)
r.HandleFunc("/debug/pprof/profile", pprof.Profile)
r.HandleFunc("/debug/pprof/symbol", pprof.Symbol)
r.HandleFunc("/debug/pprof/trace", pprof.Trace)
```

如果你使用的是gin框架，推荐使用[github.com/gin-contrib/pprof](https://github.com/gin-contrib/pprof)，在代码中通过以下命令注册pprof相关路由。

```go
pprof.Register(router)
```

不管哪种方式，你的 HTTP 服务都会多出`/debug/pprof` endpoint，访问它会得到类似下面的内容：

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gpih7cgmhxj30hu0jwmy0.jpg)

这个路径下还有几个子页面：

- /debug/pprof/profile：访问这个链接会自动进行 CPU profiling，并生成一个文件供下载
- /debug/pprof/heap： Memory Profiling 的路径，访问这个链接会得到一个内存 Profiling 结果的文件
- /debug/pprof/block：block Profiling 的路径
- /debug/pprof/goroutines：运行的 goroutines 列表，以及调用关系

- 。。。 。。。

### go tool pprof命令

不管是工具型应用还是服务型应用，我们使用相应的pprof库获取数据之后，下一步的都要对这些数据进行分析，我们可以使用`go tool pprof`命令行工具。

`go tool pprof`最简单的使用方式为:

```bash
go tool pprof [binary] [source]
```

其中：

- binary 是应用的二进制文件，用来解析各种符号；
- source 表示 profile 数据的来源，可以是本地的文件，也可以是 http 地址。

**注意事项：** 获取的 Profiling 数据是动态的，要想获得有效的数据，请保证应用处于较大的负载（比如正在生成中运行的服务，或者通过其他工具模拟访问压力）。否则如果应用处于空闲状态，得到的结果可能没有任何意义。

### 命令行交互界面

我们使用go工具链里的`pprof`来分析一下。

```bash
go tool pprof cpu.pprof
```

执行上面的代码会进入交互界面如下：

```bash
runtime_pprof $ go tool pprof cpu.pprof
Type: cpu
Time: Jun 28, 2020 at 11:28am (CST)
Duration: 20.13s, Total samples = 1.91mins (538.60%)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof)  
```

我们可以在交互界面输入`top3`来查看程序中占用CPU前3位的函数：

```bash
(pprof) top3
Showing nodes accounting for 100.37s, 87.68% of 114.47s total
Dropped 17 nodes (cum <= 0.57s)
Showing top 3 nodes out of 4
      flat  flat%   sum%        cum   cum%
    42.52s 37.15% 37.15%     91.73s 80.13%  runtime.selectnbrecv
    35.21s 30.76% 67.90%     39.49s 34.50%  runtime.chanrecv
    22.64s 19.78% 87.68%    114.37s 99.91%  main.logicCode
```

其中：

- flat：当前函数占用CPU的耗时
- flat：:当前函数占用CPU的耗时百分比
- sun%：函数占用CPU的耗时累计百分比
- cum：当前函数加上调用当前函数的函数占用CPU的总耗时
- cum%：当前函数加上调用当前函数的函数占用CPU的总耗时百分比
- 最后一列：函数名称

在大多数的情况下，我们可以通过分析这五列得出一个应用程序的运行情况，并对程序进行优化。

还可以使用`list 函数名`命令查看具体的函数分析，例如执行`list logicCode`查看我们编写的函数的详细分析。

### 图形化

或者可以直接输入web，通过svg图的方式查看程序中详细的CPU占用情况。 想要查看图形化的界面首先需要安装[graphviz](https://graphviz.gitlab.io/)图形化工具。

Mac：

```bash
brew install graphviz
```

Windows: 下载[graphviz](https://graphviz.gitlab.io/_pages/Download/Download_windows.html) 将`graphviz`安装目录下的bin文件夹添加到Path环境变量中。 在终端输入`dot -version`查看是否安装成功。

![](https://tva1.sinaimg.cn/large/008eGmZEgy1gpihc6efdzj310a0q676g.jpg)

关于图形的说明： 每个框代表一个函数，理论上框的越大表示占用的CPU资源越多。 方框之间的线条代表函数之间的调用关系。 线条上的数字表示函数调用的次数。 方框中的第一行数字表示当前函数占用CPU的百分比，第二行数字表示当前函数累计占用CPU的百分比。

除了分析CPU性能数据，pprof也支持分析内存性能数据。比如，使用下面的命令分析http服务的heap性能数据，查看当前程序的内存占用以及热点内存对象使用的情况。

```bash
# 查看内存占用数据
go tool pprof -inuse_space http://127.0.0.1:8080/debug/pprof/heap
go tool pprof -inuse_objects http://127.0.0.1:8080/debug/pprof/heap
# 查看临时内存分配数据
go tool pprof -alloc_space http://127.0.0.1:8080/debug/pprof/heap
go tool pprof -alloc_objects http://127.0.0.1:8080/debug/pprof/heap
```

## go-torch和火焰图

火焰图（Flame Graph）是 Bredan Gregg 创建的一种性能分析图表，因为它的样子近似 🔥而得名。上面的 profiling 结果也转换成火焰图，如果对火焰图比较了解可以手动来操作，不过这里我们要介绍一个工具：`go-torch`。这是 uber 开源的一个工具，可以直接读取 golang profiling 数据，并生成一个火焰图的 svg 文件。

### 安装go-torch

```bash
   go get -v github.com/uber/go-torch
```

火焰图 svg 文件可以通过浏览器打开，它对于调用图的最优点是它是动态的：可以通过点击每个方块来 zoom in 分析它上面的内容。

火焰图的调用顺序从下到上，每个方块代表一个函数，它上面一层表示这个函数会调用哪些函数，方块的大小代表了占用 CPU 使用的长短。火焰图的配色并没有特殊的意义，默认的红、黄配色是为了更像火焰而已。

go-torch 工具的使用非常简单，没有任何参数的话，它会尝试从`http://localhost:8080/debug/pprof/profile`获取 profiling 数据。它有三个常用的参数可以调整：

- -u –url：要访问的 URL，这里只是主机和端口部分
- -s –suffix：pprof profile 的路径，默认为 /debug/pprof/profile
- –seconds：要执行 profiling 的时间长度，默认为 30s

### 安装 FlameGraph

要生成火焰图，需要事先安装 FlameGraph工具，这个工具的安装很简单（需要perl环境支持），只要把对应的可执行文件加入到环境变量中即可。

1. 下载安装perl：https://www.perl.org/get.html
2. 下载FlameGraph：`git clone https://github.com/brendangregg/FlameGraph.git`
3. 将`FlameGraph`目录加入到操作系统的环境变量中。
4. Windows平台，需要把`go-torch/render/flamegraph.go`文件中的`GenerateFlameGraph`按如下方式修改，然后在`go-torch`目录下执行`go install`即可。

```go
// GenerateFlameGraph runs the flamegraph script to generate a flame graph SVG. func GenerateFlameGraph(graphInput []byte, args ...string) ([]byte, error) {
flameGraph := findInPath(flameGraphScripts)
if flameGraph == "" {
	return nil, errNoPerlScript
}
if runtime.GOOS == "windows" {
	return runScript("perl", append([]string{flameGraph}, args...), graphInput)
}
  return runScript(flameGraph, args, graphInput)
}
```

### 压测工具wrk

推荐使用https://github.com/wg/wrk 或 https://github.com/adjust/go-wrk

### 使用go-torch

使用wrk进行压测:

```bash
go-wrk -n 50000 http://127.0.0.1:8080/book/list
```

在上面压测进行的同时，打开另一个终端执行:

```bash
go-torch -u http://127.0.0.1:8080 -t 30
```

30秒之后终端会出现如下提示：`Writing svg to torch.svg`

然后我们使用浏览器打开`torch.svg`就能看到如下火焰图了。

火焰图的y轴表示cpu调用方法的先后，x轴表示在每个采样调用时间内，方法所占的时间百分比，越宽代表占据cpu时间越多。通过火焰图我们就可以更清楚的找出耗时长的函数调用，然后不断的修正代码，重新采样，不断优化。

此外还可以借助火焰图分析内存性能数据：

```bash
go-torch -inuse_space http://127.0.0.1:8080/debug/pprof/heap
go-torch -inuse_objects http://127.0.0.1:8080/debug/pprof/heap
go-torch -alloc_space http://127.0.0.1:8080/debug/pprof/heap
go-torch -alloc_objects http://127.0.0.1:8080/debug/pprof/heap
```

## pprof与性能测试结合

`go test`命令有两个参数和 pprof 相关，它们分别指定生成的 CPU 和 Memory profiling 保存的文件：

- -cpuprofile：cpu profiling 数据要保存的文件地址
- -memprofile：memory profiling 数据要报文的文件地址

我们还可以选择将pprof与性能测试相结合，比如：

比如下面执行测试的同时，也会执行 CPU profiling，并把结果保存在 cpu.prof 文件中：

```bash
go test -bench . -cpuprofile=cpu.prof
```

比如下面执行测试的同时，也会执行 Mem profiling，并把结果保存在 cpu.prof 文件中：

```bash
go test -bench . -memprofile=./mem.prof
```

需要注意的是，Profiling 一般和性能测试一起使用，这个原因在前文也提到过，只有应用在负载高的情况下 Profiling 才有意义。

## referce

[李文周-Go性能优化](https://www.liwenzhou.com/posts/Go/performance_optimisation/)