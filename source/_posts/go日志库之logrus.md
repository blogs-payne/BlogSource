---
title: go日志库之logrus
author: Payne
tags:
  - Go
categories:
  - - Go
date: 2021-09-25 06:59:56
---

无路是在开发、测试、亦或者调试有一好的日志，都会事半功倍。本节我来学习一下 go 语言明星日志库 logrus。相关链接如下所示
[github](https://github.com/sirupsen/logrus "github"): https://github.com/sirupsen/logrus
[pkg](https://pkg.go.dev/logur.dev/adapter/logrus "pkg")： https://pkg.go.dev/logur.dev/adapter/logrus

## Logrus 简介

Logrus 是 Go 语言结构化的 logger，与标准库 logger 完全 API 兼容。

它有以下特点：

- 完全兼容标准日志库，拥有七种日志级别：`Trace`, `Debug`, `Info`, `Warning`, `Error`, `Fatal`and `Panic`。
- 可选的日志输出格式，内置了两种日志格式 JSONFormater 和 TextFormatter，还可以自定义日志格式
- Field 机制，通过 Filed 机制进行结构化的日志记录
- 可扩展的 Hook 机制，允许使用者通过 Hook 的方式将日志分发到任意地方，如本地文件系统，logstash，elasticsearch 或者 mq 等，或者通过 Hook 定义日志内容和格式等
- 线程安全

## logrus 的安装

logrus 安装也非常的简单，直接使用`go get`即可，安装命令如下所示

```shell
go get -v -u logur.dev/adapter/logrus
```

> 其中
>
> `-v` 为显示包安装信息
>
> `-u` 为安装最新版

## logrus 的使用

介绍的包的使用，或许可以从几个维度，初始化、基本使用、骚操作及拓展。源于包使用，但不限于包使用

### 初始化

logrus 相关于初始化的方面，一共有三种方式。基于`New()`、`Logger`、`不操作`

#### 直接使用

直接使用相对来说更便捷，更清亮。也是相对来说性能最高的，但不足也显而易言，那就是不能有更自由的操作了，如设置 log Level、Hook、Format 等等。

```go
logrus.Trace("trace msg")
logrus.Tracef("trace %v", "msg")

logrus.Debug("debug msg")
logrus.Debugf("debug %v", "msg")

logrus.Info("info msg")
logrus.Infof("info %v", "msg")

logrus.Warn("warn msg")
logrus.Warnf("warn %v", "msg")

logrus.Error("error msg")
logrus.Errorf("error %v", "msg")

logrus.Fatal("fatal msg")
logrus.Fatalf("fatal  %v", "msg")

logrus.Panic("panic msg")
logrus.Panicf("panic  %v", "msg")
```

> 当然根据默认的规则会忽略掉一些输出信息

#### 使用 New 初始化于定制

相对直接使用，使用 New 初始化，拥有更多的操作空间。

首先声明一个全局变量`log`，代码如下所示

```go
var log = logrus.New()
```

常规情况下对于日志的定制主要在以下几个方面

- 日志可见等级
- 日志格式配置
- 执行调用信息
- 日志另存为

**日志可见等级**

> 相关源码如下

```go
const (
	// PanicLevel level, highest level of severity. Logs and then calls panic with the
	// message passed to Debug, Info, ...
	PanicLevel Level = iota
	// FatalLevel level. Logs and then calls `logger.Exit(1)`. It will exit even if the
	// logging level is set to Panic.
	FatalLevel
	// ErrorLevel level. Logs. Used for errors that should definitely be noted.
	// Commonly used for hooks to send errors to an error tracking service.
	ErrorLevel
	// WarnLevel level. Non-critical entries that deserve eyes.
	WarnLevel
	// InfoLevel level. General operational entries about what's going on inside the
	// application.
	InfoLevel
	// DebugLevel level. Usually only enabled when debugging. Very verbose logging.
	DebugLevel
	// TraceLevel level. Designates finer-grained informational events than the Debug.
	TraceLevel
)
```

简而言之，登记越高（数字越大），显示的等级越全。如 6 显示所有的日志，0 只显示`Panic`

设置可见等级之需要在`log.SetLevel()`*（log 为`var log = logrus.New()`而来）*设置整形(6-0)即可。

**日志格式化配置**

日志格式化主要分为文本格式化、JSON 格式化、自定义格式化或第三方插件格式化

如下

```go
// log.SetFormatter(&logrus.TextFormatter{
//		DisableColors: false,
//		FullTimestamp: true,
//	})
type TextFormatter struct {
	// Set to true to bypass checking for a TTY before outputting colors.
	ForceColors bool

	// Force disabling colors.
	DisableColors bool

	// Force quoting of all values
	ForceQuote bool

	// DisableQuote disables quoting for all values.
	// DisableQuote will have a lower priority than ForceQuote.
	// If both of them are set to true, quote will be forced on all values.
	DisableQuote bool

	// Override coloring based on CLICOLOR and CLICOLOR_FORCE. - https://bixense.com/clicolors/
	EnvironmentOverrideColors bool

	// Disable timestamp logging. useful when output is redirected to logging
	// system that already adds timestamps.
	DisableTimestamp bool

	// Enable logging the full timestamp when a TTY is attached instead of just
	// the time passed since beginning of execution.
	FullTimestamp bool

	// TimestampFormat to use for display when a full timestamp is printed.
	// The format to use is the same than for time.Format or time.Parse from the standard
	// library.
	// The standard Library already provides a set of predefined format.
	TimestampFormat string

	// The fields are sorted by default for a consistent output. For applications
	// that log extremely frequently and don't use the JSON formatter this may not
	// be desired.
	DisableSorting bool

	// The keys sorting function, when uninitialized it uses sort.Strings.
	SortingFunc func([]string)

	// Disables the truncation of the level text to 4 characters.
	DisableLevelTruncation bool

	// PadLevelText Adds padding the level text so that all the levels output at the same length
	// PadLevelText is a superset of the DisableLevelTruncation option
	PadLevelText bool

	// QuoteEmptyFields will wrap empty fields in quotes if true
	QuoteEmptyFields bool

	// Whether the logger's out is to a terminal
	isTerminal bool

	// FieldMap allows users to customize the names of keys for default fields.
	// As an example:
	// formatter := &TextFormatter{
	//     FieldMap: FieldMap{
	//         FieldKeyTime:  "@timestamp",
	//         FieldKeyLevel: "@level",
	//         FieldKeyMsg:   "@message"}}
	FieldMap FieldMap

	// CallerPrettyfier can be set by the user to modify the content
	// of the function and file keys in the data when ReportCaller is
	// activated. If any of the returned value is the empty string the
	// corresponding key will be removed from fields.
	CallerPrettyfier func(*runtime.Frame) (function string, file string)

	terminalInitOnce sync.Once

	// The max length of the level text, generated dynamically on init
	levelTextMaxLength int
}
```

格式 JSON 化

```go
// log.SetFormatter(&logrus.JSONFormatter{})
type JSONFormatter struct {
	// TimestampFormat sets the format used for marshaling timestamps.
	// The format to use is the same than for time.Format or time.Parse from the standard
	// library.
	// The standard Library already provides a set of predefined format.
	TimestampFormat string

	// DisableTimestamp allows disabling automatic timestamps in output
	DisableTimestamp bool

	// DisableHTMLEscape allows disabling html escaping in output
	DisableHTMLEscape bool

	// DataKey allows users to put all the log entry parameters into a nested dictionary at a given key.
	DataKey string

	// FieldMap allows users to customize the names of keys for default fields.
	// As an example:
	// formatter := &JSONFormatter{
	//   	FieldMap: FieldMap{
	// 		 FieldKeyTime:  "@timestamp",
	// 		 FieldKeyLevel: "@level",
	// 		 FieldKeyMsg:   "@message",
	// 		 FieldKeyFunc:  "@caller",
	//    },
	// }
	FieldMap FieldMap

	// CallerPrettyfier can be set by the user to modify the content
	// of the function and file keys in the json data when ReportCaller is
	// activated. If any of the returned value is the empty string the
	// corresponding key will be removed from json fields.
	CallerPrettyfier func(*runtime.Frame) (function string, file string)

	// PrettyPrint will indent all json logs
	PrettyPrint bool
}
```

https://github.com/sirupsen/logrus#formatters

![image-20210926173746478](https://tva1.sinaimg.cn/large/008i3skNgy1guu60plma8j60l00740to02.jpg)

**写入文件夹 SetOutput**

O_RDONLY：只读模式(read-only)

O_WRONLY：只写模式(write-only)

O_RDWR：读写模式(read-write)

O_APPEND：追加模式(append)

O_CREATE：文件不存在就创建(create a new file if none exists.)

O_EXCL：与 O_CREATE 一起用，构成一个新建文件的功能，它要求文件必须不存在(used with O_CREATE, file must not exist)

O_SYNC：同步方式打开，即不使用缓存，直接写入硬盘 O_TRUNC：打开并清空文件

示例代码如下

```go
func init(){
	logDirPath := `log/` + time.Now().Format("2006-01-02")
	logFilePath := filepath.Join(logDirPath, time.Now().Format(`15`))
	os.MkdirAll(logFilePath, 0775)
	file, err := os.OpenFile(logFilePath + `/` + time.Now().Format(`04`) + `.log`, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		log.Error(`open file error`)
	}
	log.SetOutput(file)
}
```

`log.SetReportCaller()`: 显示调用关系，开启这个模式会增加性能开销(成本在 20% 到 40% 之间)。

**Hook**

logrus 通过实现 `Hook`接口扩展 hook 机制,可以根据需求将日志分发到任意的存储介质, 比如 es, mq 或者监控报警系统,及时获取异常日志。可以说极大的提高了日志系统的可扩展性。

```go
type Hook interface {
  // 定义哪些等级的日志触发 hook 机制
	Levels() []Level
  // hook 触发器的具体执行操作
  // 如果 Fire 执行失败,错误日志会重定向到标准错误流
	Fire(*Entry) error
}
```

具体 Hook 示列可参考 https://github.com/sirupsen/logrus/blob/master/hooks/syslog/README.md

## referer

https://blog.csdn.net/wangzhezhilu001/article/details/95363789

https://blog.csdn.net/sserf/article/details/103388133
