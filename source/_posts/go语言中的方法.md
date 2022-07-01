---
title: go语言中的方法
author: Payne
tags:
  - Go
categories:
  - - Go
    - go
    - golang
abbrlink: 3417717672
date: 2022-02-15 19:57:36
---

## 什么是方法

​ 方法一般是面向对象编程(OOP)的一个特性，在cpp中方法对应一个类对象的成员函数，是关联到具体对象上的虚表中的。但是Go语言的方法却是**关联到类型**的，这样可以在编译阶段完成方法的静态绑定。

​ 一个面向对象的程序会用方法来表达其属性对应的操作，这样使用这个对象的用户就不需要直接去操作对象，而是借助方法来做这些事情。面向对象编程(OOP)
进入主流开发领域一般认为是从cpp开始的，cpp就是在兼容C语言的基础之上支持了class等面向对象的特性。然后Java编程则号称是纯粹的面向对象语言，因为Java中函数是不能独立存在的，每个函数都必然是属于某个类的。

面向对象编程更多的只是一种思想，很多号称支持面向对象编程的语言只是将经常用到的特性内置到语言中了而已。

## 方法的声明

Go语言中的`方法（Method）`是一种作用于特定类型变量的函数。这种特定类型变量叫做`接收者（Receiver）`，其中方法接收器（receiver）参数、函数 / 方法参数，以及返回值变量对应的作用域范围，都是函数 /
方法体对应的显式代码块。

```go
func (接收者变量 接收者类型(值类型或指针类型)) 方法名(参数列表) (返回参数) {
    方法体
}
```

- 接收者变量：接收者中的参数变量名在命名时，官方建议使用接收者类型名称首字母的小写，而非`self`、`this`之类的命名。例如，`Person`类型的接收者变量应该命名为 `p`，`Connector`类型的接收者变量应该命名为`c`
  等。
- 接收者类型：接收者类型和参数类似，可以是指针类型和非指针类型。
- 方法名、参数列表、返回参数：具体格式与函数定义相同。

一个简单的例子

```go
package main

import "fmt"

type people struct {
	name             string
	age              uint16
	height           float32
	weight           float32
	hometown         string
	currentResidence string
	lifeMotto        string
	Hobby            map[string]string
	Job              string
}

// 构造函数
func newPeople(name string, age uint16, height float32, weight float32, hometown string, currentResidence string, lifeMotto string, hobby map[string]string, job string) *people {
	return &people{
		name:             name,
		age:              age,
		height:           height,
		weight:           weight,
		hometown:         hometown,
		currentResidence: currentResidence,
		lifeMotto:        lifeMotto,
		Hobby:            hobby,
		Job:              job,
	}
}

func main() {
	people := newPeople(
		`Payne`,
		23,
		1.767,
		75,
		`HuNan`,
		`ShangHai`,
		`stay hungry,stay foolish`,
		map[string]string{
			`first`: `reading`,
		},
		`data engineer`,
	)
	fmt.Println(people)
}
```

### 接收者

```go
//方法(值类型接受者)
//	当方法作用于值类型接收者时，Go语言会在代码运行时将接收者的值复制一份。
// 	在值类型接收者的方法中可以获取接收者的成员值，但修改操作只是针对副本，无法修改接收者变量本身。
func (p people) introduce()  {
	fmt.Println(p)
}

// 方法(指针类型接受者)
// 	指针类型的接收者由一个结构体的指针组成，由于指针的特性，
// 	调用方法时修改接收者指针的任意成员变量，在方法结束后，修改都是有效的。
// 	这种方式就十分接近于其他语言中面向对象中的this或者self。
func (p *people) introduceMe()  {
	fmt.Println(p)
}
```

### 什么时候应该使用指针类型接收者

1. 需要修改接收者中的值
2. 接收者是拷贝代价比较大的大对象
3. 保证一致性，如果有某个方法使用了指针接收者，那么其他的方法也应该使用指针接收者。

## Tips

### 构造函数优化

在上面的例子中发现过多的参数，这个写法乍看之下是没啥问题的，但是一旦 people 结构内部的字段发生了变化，增加或者减少了，那么这个初始化函数 newPeople 就怎么看都觉的别扭了。

​ 如果参数继续增加呢？那么所有调用了这个 newPeople 方法的地方也都需要进行修改，且按照代码整洁的逻辑，参数多于 5 个，这个函数就很难使用了。而且，如果这 5 个参数都是可有可无的参数，就是有的参数可以不填写，

有默认值，比如 age 这个字段，即使我们不填写，在后续的业务逻辑中可能也没有很多影响，那么我在实际调用 newPeople 的时候，age 这个字段还需要传递 0 值, 以及hometown为空值，那么构造方法newPeople如下所示

```go
people := newPeople(
		`Payne`,
		0,
		1.767,
		75,
		``,
		`ShangHai`,
		`stay hungry,stay foolish`,
		map[string]string{
			`first`: `reading`,
		},
		`data engineer`,
	)
```

乍看这行代码，你可能会以为我创建了一个 people，它的年龄为 0以及hometown为空值，但是实际上我们是希望表达这里使用了一个“缺省值”，这种代码的语义逻辑就不对了。那改怎么如何呢？

### 请使用options写法

options 为可选参数，以上面的代码为例，我们只需`name`, `age`,`job` 为必选，其他为可选参数的，那此时可以这么写，如下所示

```
package main

import "fmt"

type people struct {
	name             string
	age              uint16
	height           float32
	weight           float32
	hometown         string
	currentResidence string
	lifeMotto        string
	Hobby            map[string]string
	Job              string
}

// peopleOptions 可选参数
type peopleOptions func(p *people)

func withHeight(height float32) peopleOptions {
	return func(p *people) {
		p.height = height
	}
}

func withWeight(weight float32) peopleOptions {
	return func(p *people) {
		p.weight = weight
	}
}

func withHometown(hometown string) peopleOptions {
	return func(p *people) {
		p.hometown = hometown
	}
}

func withCurrentResidence(currentResidence string) peopleOptions {
	return func(p *people) {
		p.currentResidence = currentResidence
	}
}

func withLifeMotto(lifeMotto string) peopleOptions {
	return func(p *people) {
		p.lifeMotto = lifeMotto
	}
}

func withHobby(Hobby map[string]string) peopleOptions {
	return func(p *people) {
		p.Hobby = Hobby
	}
}

// 构造函数
// 必选: name, age, job
func newPeopleOptions(name string, age uint16, job string, options ...peopleOptions) *people {
	p := &people{
		name: name,
		age:  age,
		Job:  job,
	}
	for _, option := range options {
		option(p)
	}
	return p
}

//方法(值类型接受者)
func (p people) introduce() {
	fmt.Println(p)
}

//方法(指针类型接受者)
func (p *people) introduceMe() {
	fmt.Println(p)
}

func main() {
	people := newPeopleOptions(
		`Payne`,
		21,
		`data engineer`,
		withHeight(1.767),
	)
	people.introduce()
	//people.introduceMe()
}
```

其中with代表可选的， 如果我们后续 Foo 多了一个可变属性，那么我们只需要多一个 WithXXX 的方法就可以了，而 NewFoo 函数不需要任何变化，调用方只要在指定这个可变属性的地方增加 WithXXX 就可以了，扩展性非常好。

## 源码赏析

以下是go爬虫框架`colly`的初始化部分，大致结构如下

- 可选函数类型：`CollectorOption func(*Collector)`

- 采集器结构体：`Collector`

- 初始化方法：`Init`

- 虚拟环境处理方法：`parseSettingsFromEnv`

- 构造函数:`NewCollector`

> gocolly/colly.go

```go
// A CollectorOption sets an option on a Collector.
type CollectorOption func(*Collector)

// Collector provides the scraper instance for a scraping job
type Collector struct {
	// UserAgent is the User-Agent string used by HTTP requests
	UserAgent string
	// MaxDepth limits the recursion depth of visited URLs.
	// Set it to 0 for infinite recursion (default).
	MaxDepth int
	// AllowedDomains is a domain whitelist.
	// Leave it blank to allow any domains to be visited
	AllowedDomains []string
	// DisallowedDomains is a domain blacklist.
	DisallowedDomains []string
	// DisallowedURLFilters is a list of regular expressions which restricts
	// visiting URLs. If any of the rules matches to a URL the
	// request will be stopped. DisallowedURLFilters will
	// be evaluated before URLFilters
	// Leave it blank to allow any URLs to be visited
	DisallowedURLFilters []*regexp.Regexp
	// URLFilters is a list of regular expressions which restricts
	// visiting URLs. If any of the rules matches to a URL the
	// request won't be stopped. DisallowedURLFilters will
	// be evaluated before URLFilters

	// Leave it blank to allow any URLs to be visited
	URLFilters []*regexp.Regexp

	// AllowURLRevisit allows multiple downloads of the same URL
	AllowURLRevisit bool
	// MaxBodySize is the limit of the retrieved response body in bytes.
	// 0 means unlimited.
	// The default value for MaxBodySize is 10MB (10 * 1024 * 1024 bytes).
	MaxBodySize int
	// CacheDir specifies a location where GET requests are cached as files.
	// When it's not defined, caching is disabled.
	CacheDir string
	// IgnoreRobotsTxt allows the Collector to ignore any restrictions set by
	// the target host's robots.txt file.  See http://www.robotstxt.org/ for more
	// information.
	IgnoreRobotsTxt bool
	// Async turns on asynchronous network communication. Use Collector.Wait() to
	// be sure all requests have been finished.
	Async bool
	// ParseHTTPErrorResponse allows parsing HTTP responses with non 2xx status codes.
	// By default, Colly parses only successful HTTP responses. Set ParseHTTPErrorResponse
	// to true to enable it.
	ParseHTTPErrorResponse bool
	// ID is the unique identifier of a collector
	ID uint32
	// DetectCharset can enable character encoding detection for non-utf8 response bodies
	// without explicit charset declaration. This feature uses https://github.com/saintfish/chardet
	DetectCharset bool
	// RedirectHandler allows control on how a redirect will be managed
	// use c.SetRedirectHandler to set this value
	redirectHandler func(req *http.Request, via []*http.Request) error
	// CheckHead performs a HEAD request before every GET to pre-validate the response
	CheckHead bool
	// TraceHTTP enables capturing and reporting request performance for crawler tuning.
	// When set to true, the Response.Trace will be filled in with an HTTPTrace object.
	TraceHTTP bool
	// Context is the context that will be used for HTTP requests. You can set this
	// to support clean cancellation of scraping.
	Context context.Context

	store                    storage.Storage
	debugger                 debug.Debugger
	robotsMap                map[string]*robotstxt.RobotsData
	htmlCallbacks            []*htmlCallbackContainer
	xmlCallbacks             []*xmlCallbackContainer
	requestCallbacks         []RequestCallback
	responseCallbacks        []ResponseCallback
	responseHeadersCallbacks []ResponseHeadersCallback
	errorCallbacks           []ErrorCallback
	scrapedCallbacks         []ScrapedCallback
	requestCount             uint32
	responseCount            uint32
	backend                  *httpBackend
	wg                       *sync.WaitGroup
	lock                     *sync.RWMutex
}

// Init initializes the Collector's private variables and sets default
// configuration for the Collector
func (c *Collector) Init() {
	c.UserAgent = "colly - https://github.com/gocolly/colly/v2"
	c.MaxDepth = 0
	c.store = &storage.InMemoryStorage{}
	c.store.Init()
	c.MaxBodySize = 10 * 1024 * 1024
	c.backend = &httpBackend{}
	jar, _ := cookiejar.New(nil)
	c.backend.Init(jar)
	c.backend.Client.CheckRedirect = c.checkRedirectFunc()
	c.wg = &sync.WaitGroup{}
	c.lock = &sync.RWMutex{}
	c.robotsMap = make(map[string]*robotstxt.RobotsData)
	c.IgnoreRobotsTxt = true
	c.ID = atomic.AddUint32(&collectorCounter, 1)
	c.TraceHTTP = false
	c.Context = context.Background()
}



// NewCollector creates a new Collector instance with default configuration
func NewCollector(options ...CollectorOption) *Collector {
	c := &Collector{}
	c.Init()

	for _, f := range options {
		f(c)
	}

	c.parseSettingsFromEnv()

	return c
}

func (c *Collector) parseSettingsFromEnv() {
	for _, e := range os.Environ() {
		if !strings.HasPrefix(e, "COLLY_") {
			continue
		}
		pair := strings.SplitN(e[6:], "=", 2)
		if f, ok := envMap[pair[0]]; ok {
			f(c, pair[1])
		} else {
			log.Println("Unknown environment variable:", pair[0])
		}
	}
}
```

