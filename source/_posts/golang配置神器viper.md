---
title: golang配置神器viper
author: Payne
tags:
  - Go
categories:
  - - Go
abbrlink: 2559205426
date: 2021-10-18 17:09:16
---

## Viper简介

Viper是一个完整的Go语言项目的配置解决方案。它可以处理所有类型的配置需求和格式，相关链接如下

包文档：https://pkg.go.dev/github.com/spf13/viper

github：https://github.com/spf13/viper

## Viper的优势

在构建Golang程序时可以不必担心配置文件格式而更专注于实现。

viper主要包含以下操作：

1. 查找、加载和反序列化 "json", "toml", "yaml", "yml", "properties", "props", "prop", "hcl", "tfvars", "dotenv", "env", "ini"
2. 提供一种机制来为不同的配置选项设置默认值。
3. 提供一种机制来为通过命令行参数设置指定覆盖值。
4. 提供别名，以在不破坏现有代码的情况下轻松重命名参数。
5. 使区分用户何时提供与默认值相同的命令行或配置文件变得容易。

每个项目的优先级都高于它下面的项目，Viper优先顺序。

- 显式调用 `Set`
- 命令行参数（flag）
- 环境变量
- 配置文件
- key/value存储
- 默认值

> **重要提示：** Viper 配置键不区分大小写。正在进行关于使之成为可选项的讨论。

## Viper使用场景

- 设置默认值
- "json", "toml", "yaml", "yml", "properties", "props", "prop", "hcl", "tfvars", "dotenv", "env", "ini"文件中读取载入
- 实时观看和重新读取配置文件（可选）
- 从环境变量中读取
- 从远程配置系统（etcd 或 Consul）读取，并观察变化
- 从命令行标志读取
- 从缓冲区读取
- 设置显式值

> Viper 可以被认为是满足所有应用程序配置需求的注册表

## Viper的安装

```bash
go get -u -v github.com/spf13/viper
```

## Viper使用实例

### 使用默认值

一个好的配置系统对于默认值拥有良好的支持，其重要性不言而喻。在Viper中的默认值使用如下

```go
package main

import (
	"fmt"
	"github.com/spf13/viper"
)

func main() {
	viper.SetDefault(`Name`, `Payne`)
	viper.SetDefault(`Age`, 20)
	viper.SetDefault(`hobby`, map[string]string{
		`First hobby`:  `sing`,
		`Second hobby`: `jump`,
		`Third hobby`:  `Rap`,
		`fourth hobby`: `Play Basketball`,
	})
	fmt.Println(viper.Get(`Name`))
	fmt.Println(viper.Get(`Age`))
	fmt.Println(viper.Get(`hobby`))
	for _, i := range viper.GetStringMapString(`hobby`) {
		fmt.Println(i)
	}
}
```

### 覆盖设置

这些可能来自命令行标志，也可能来自你自己的应用程序逻辑。

```go
viper.Set("Verbose", true)
viper.Set("LogFile", LogFile)
```

### 注册和使用别名

别名允许多个键引用单个值

```go
viper.RegisterAlias("loud", "Verbose")  // 注册别名（此处loud和Verbose建立了别名）

viper.Set("verbose", true) // 结果与下一行相同
viper.Set("loud", true)   // 结果与前一行相同

viper.GetBool("loud") // true
viper.GetBool("verbose") // true
```

## 配置文件使用

### 读取配置文件

抽离统一化管理成为配置文件，将所有的配置写在文件中便于管理修改与编辑。Viper 支持 "json", "toml", "yaml", "yml", "properties", "props", "prop", "hcl", "
tfvars", "dotenv", "env", "ini" 属性文件。Viper 可以搜索多个路径，但目前单个 Viper 实例仅支持单个配置文件。Viper
不会默认任何配置搜索路径，将默认决定留给应用程序。不需要任何特定路径，但应至少提供一个需要配置文件的路径。以下是如何使用 Viper 搜索和读取配置文件的示例。

```go
viper.SetConfigFile("./config.yaml") 			// 指定配置文件路径

viper.SetConfigName("config") 						// 配置文件名称(无扩展名)
viper.SetConfigType("yaml") 							// 如果配置文件的名称中没有扩展名，则需要配置此项

viper.AddConfigPath("/etc/appname/")   		// 查找配置文件所在的路径
viper.AddConfigPath("$HOME/.appname")  		// 多次调用以添加多个搜索路径
viper.AddConfigPath(".")               		// 还可以在工作目录中查找配置

err := viper.ReadInConfig() 							// 查找并读取配置文件
if err != nil { 													// 处理读取配置文件的错误
	panic(fmt.Errorf("Fatal error config file: %s \n", err))
}

// 配置文件读取异常处理
if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			// Config file not found; ignore error if desired
			log.Println("no such config file")
		} else {
			// Config file was found but another error was produced
			log.Println("read config error")
		}
		log.Fatal(err) // 读取配置文件失败致命错误
	}
```

> **注意**若采用`setConfigName`则只会使用第一个配置文件夹
>
> 推荐使用`SetConfigFile("path/file_name")` 来完成配置文件的载入

### 从io.Reader读取配置

Viper预先定义了许多配置源，如文件、环境变量、标志和远程K/V存储，但也可以实现自己所需的配置源并将其提供给viper。

```go
import (
	"bytes"
	"fmt"
	"github.com/spf13/viper"
)

func yamlConf() {
	viper.SetConfigType("yaml") 
	ExampleYaml := []byte(`
name: Payne
Age: 18
`)
	viper.ReadConfig(bytes.NewBuffer(ExampleYaml))
	fmt.Println(viper.Get("NAME"))
	fmt.Println(viper.Get("Age"))

}

func jsonConf() {
	viper.SetConfigType(`json`)

	ExampleJSON := []byte(`{
 	"name": "payne",
 	"age": 21
}`)
	viper.ReadConfig(bytes.NewBuffer(ExampleJSON))
	fmt.Println(viper.Get("name"))
	fmt.Println(viper.GetInt("age"))
}
```

### 写入配置文件

从配置文件中读取是很有用的，但有时你想存储在运行时所作的所有修改都比较繁琐。viper提供了相关功能

- WriteConfig - 将当前的`viper`配置写入预定义的路径并覆盖（如果存在的话）。如果没有预定义的路径，则报错。
- SafeWriteConfig - 将当前的`viper`配置写入预定义的路径。如果没有预定义的路径，则报错。如果存在，将不会覆盖当前的配置文件。
- WriteConfigAs - 将当前的`viper`配置写入给定的文件路径。将覆盖给定的文件(如果它存在的话)。
- SafeWriteConfigAs - 将当前的`viper`配置写入给定的文件路径。不会覆盖给定的文件(如果它存在的话)。

> 根据经验，标记为`safe`的所有方法都不会覆盖任何文件，而是直接创建（如果不存在），而默认行为是创建或截断。

### 监听配置文件

Viper支持在运行时实时读取配置文件的功能。

需要重新启动服务器以使配置生效的日子已经一去不复返了，viper驱动的应用程序可以在运行时读取配置文件的更新，而不会错过任何消息。

只需告诉viper实例watchConfig。可选地，你可以为Viper提供一个回调函数，以便在每次发生更改时运行。

> **确保在调用`WatchConfig()`之前添加了所有的配置路径。**

```go
viper.WatchConfig()
viper.OnConfigChange(func(e fsnotify.Event) {
  // 配置文件发生变更之后会调用的回调函数
	fmt.Println("Config file changed:", e.Name)
})
```

**实例**

```go
package main

import (
	"fmt"
	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
	"log"
	"time"
)

func main() {
	for {
		viper.SetConfigFile(`./example/config.yaml`)
		if err := viper.ReadInConfig(); err != nil {
			if _, ok := err.(viper.ConfigFileNotFoundError); ok {
				// Config file not found; ignore error if desired
				log.Println("no such config file")
			} else {
				// Config file was found but another error was produced
				log.Println("read config error")
			}
			log.Fatal(err) // 读取配置文件失败致命错误
		}
		viper.SetDefault(`a`, `b`)
		viper.WatchConfig()
		viper.OnConfigChange(func(e fsnotify.Event) {
			// 配置文件发生变更之后会调用的回调函数
			fmt.Println("Config file changed:", e.Name)
		})
		fmt.Println(viper.Get(`port`))
		time.Sleep(time.Second * 2)
	}
}

```

## 环境变量

Viper完全支持环境变量。以下几种方法进行对ENV协作:

```go
// AllowEmptyEnv 告诉 Viper 将设置但为空的环境变量视为有效值，而不是回退。出于向后兼容性的原因，默认情况下这是错误的
AllowEmptyEnv(allowEmptyEnv bool) 

// AutomaticEnv 使 Viper 检查环境变量是否与任何现有键（配置、默认值或标志）匹配。如果找到匹配的环境变量，则将它们加载到 Viper 中
AutomaticEnv()

// BindEnv 将 Viper 键绑定到 ENV 变量。ENV 变量区分大小写。如果只提供了一个键，它将使用与键匹配的 env 键，大写。如果提供了更多参数，它们将表示应绑定到此键的环境变量名称，并将按指定顺序使用。当未提供 env 名称时，将在设置时使用 EnvPrefix。
func BindEnv(input ...string) error

// SetEnvPrefix 定义了 ENVIRONMENT 变量将使用的前缀
func SetEnvPrefix(in string)

// SetEnvKeyReplacer允许你使用strings.Replacer对象在一定程度上重写 Env 键
func SetEnvKeyReplacer(r *strings.Replacer)
```

> ***使用ENV变量时，务必要意识到Viper将ENV变量视为区分大小写。***

```go
// case 1
i := 0
for {
  viper.SetDefault(`Val`, `Original`)
  viper.BindEnv(`Val`)
  fmt.Println(viper.Get(`Val`))

  // 通常是在应用程序之外完成的
  if i == 3 {
    os.Setenv("VAL", "changed")
  }

  fmt.Println(i)
  i += 1
  time.Sleep(1 * time.Second)
}

// case 2
i := 0
for {
  viper.SetDefault(`Val`, `Original`)
  viper.SetEnvPrefix(`CUSTOM`) // 将自动转为大写
  viper.BindEnv(`Val`)
  fmt.Println(viper.Get(`Val`))

  // 通常是在应用程序之外完成的
  if i == 3 {
    os.Setenv("CUSTOM_VAL", "changed")
  }

  fmt.Println(i)
  i += 1
  time.Sleep(1 * time.Second)
}
```

> 当第四次输出时`VAL`,将输出`change`
>
> 小技巧：在使用环境变量的时候推荐采用全大写，避免混淆

## 使用viper获取值

> 获取函数如下所示，具体作用见名思意

```go
Get(key string) interface{}
Sub(key string) *Viper
GetBool(key string) bool
GetDuration(key string) time.Duration
GetFloat64(key string) float64
GetInt(key string) int
GetInt32(key string) int32
GetInt64(key string) int64
GetIntSlice(key string) []int
GetSizeInBytes(key string) uint
GetString(key string) string
GetStringMap(key string) map[string]interface{}
GetStringMapString(key string) map[string]string
GetStringMapStringSlice(key string) map[string][]string
GetStringSlice(key string) []string
GetTime(key string) time.Time
GetUint(key string) uint
GetUint32(key string) uint32
GetUint64(key string) uint64
InConfig(key string) bool
IsSet(key string) bool
AllSettings() map[string]interface{}
```

### 访问嵌套的键

访问器方法也接受深度嵌套键的格式化路径。例如，如果加载下面的JSON文件：

```json
{
  "host": {
    "address": "localhost",
    "port": 5799
  },
  "datastore": {
    "metric": {
      "host": "127.0.0.1",
      "port": 3099
    },
    "warehouse": {
      "host": "198.21.112.32",
      "port": 2112
    }
  }
}
```

Viper可以通过传入`.`分隔的路径来访问嵌套字段：

```go
GetString("datastore.datastore.warehouse.host") 
// 返回 "198.21.112.32"
```

这遵守上面建立的优先规则；搜索路径将遍历其余配置注册表，直到找到为止。(译注：因为Viper支持从多种配置来源，例如磁盘上的配置文件>命令行标志位>环境变量>远程Key/Value存储>
默认值，我们在查找一个配置的时候如果在当前配置源中没找到，就会继续从后续的配置源查找，直到找到为止。)

例如，在给定此配置文件的情况下，`datastore.metric.host`和`datastore.metric.port`均已定义（并且可以被覆盖）。如果另外在默认值中定义了`datastore.metric.protocol`
，Viper也会找到它。然而，如果`datastore.metric`被直接赋值覆盖（被flag，环境变量，`set()`方法等等…），那么`datastore.metric`
的所有子键都将变为未定义状态，它们被高优先级配置级别“遮蔽”（shadowed）了。最后，如果存在与分隔的键路径匹配的键，则返回其值。例如：

```go
{
    "datastore.metric.host": "0.0.0.0",
    "host": {
        "address": "localhost",
        "port": 5799
    },
    "datastore": {
        "metric": {
            "host": "127.0.0.1",
            "port": 3099
        },
        "warehouse": {
            "host": "198.0.0.1",
            "port": 2112
        }
    }
}

GetString("datastore.metric.host") 
// 返回 "0.0.0.0"
```

### 提取子树

从Viper中提取子树，`viper`实例现在代表了以下配置：

```yaml
app:
  cache1:
    max-items: 100
    item-size: 64
  cache2:
    max-items: 200
    item-size: 80
```

执行后：

```go
subv := viper.Sub("app.cache1")
```

`subv`现在就代表：

```yaml
max-items: 100
item-size: 64
```

假设我们现在有这么一个函数：

```go
func NewCache(cfg *Viper) *Cache {...}
```

它基于`subv`格式的配置信息创建缓存。现在，可以轻松地分别创建这两个缓存，如下所示：

```go
cfg1 := viper.Sub("app.cache1")
cache1 := NewCache(cfg1)

cfg2 := viper.Sub("app.cache2")
cache2 := NewCache(cfg2)
```

### 反序列化

你还可以选择将所有或特定的值解析到结构体、map等。

有两种方法可以做到这一点：

- `Unmarshal(rawVal interface{}) : error`
- `UnmarshalKey(key string, rawVal interface{}) : error`

```go
type config struct {
	Port int
	Name string
	PathMap string `mapstructure:"path_map"`
}

var C config

err := viper.Unmarshal(&C)
if err != nil {
	t.Fatalf("unable to decode into struct, %v", err)
}
```

如果你想要解析那些键本身就包含`.`(默认的键分隔符）的配置，你需要修改分隔符：

```go
v := viper.NewWithOptions(viper.KeyDelimiter("::"))

v.SetDefault("chart::values", map[string]interface{}{
    "ingress": map[string]interface{}{
        "annotations": map[string]interface{}{
            "traefik.frontend.rule.type":                 "PathPrefix",
            "traefik.ingress.kubernetes.io/ssl-redirect": "true",
        },
    },
})

type config struct {
	Chart struct{
        Values map[string]interface{}
    }
}

var C config

v.Unmarshal(&C)
```

Viper还支持解析到嵌入的结构体：

```go
/*
Example config:

module:
    enabled: true
    token: 89h3f98hbwf987h3f98wenf89ehf
*/
type config struct {
	Module struct {
		Enabled bool

		moduleConfig `mapstructure:",squash"`
	}
}

// moduleConfig could be in a module specific package
type moduleConfig struct {
	Token string
}

var C config

err := viper.Unmarshal(&C)
if err != nil {
	t.Fatalf("unable to decode into struct, %v", err)
}
```

Viper在后台使用[github.com/mitchellh/mapstructure](https://github.com/mitchellh/mapstructure)来解析值，其默认情况下使用`mapstructure`tag。

> **注意** 当我们需要将viper读取的配置反序列到我们定义的结构体变量中时，一定要使用`mapstructure`tag！

### 序列化成字符串

你可能需要将viper中保存的所有设置序列化到一个字符串中，而不是将它们写入到一个文件中。你可以将自己喜欢的格式的序列化器与`AllSettings()`返回的配置一起使用。

```go
import (
    yaml "gopkg.in/yaml.v2"
    // ...
)

func yamlStringSettings() string {
    c := viper.AllSettings()
    bs, err := yaml.Marshal(c)
    if err != nil {
        log.Fatalf("unable to marshal config to YAML: %v", err)
    }
    return string(bs)
}
```

## 远程Key/Value存储支持

在Viper中启用远程支持，需要在代码中匿名导入`viper/remote`这个包。

```
import _ "github.com/spf13/viper/remote"
```

Viper将读取从Key/Value存储（例如etcd或Consul）中的路径检索到的配置字符串（如`JSON`、`TOML`、`YAML`、`HCL`、`envfile`和`Java properties`
格式）。这些值的优先级高于默认值，但是会被从磁盘、flag或环境变量检索到的配置值覆盖。（译注：也就是说Viper加载配置值的优先级为：磁盘上的配置文件>命令行标志位>环境变量>远程Key/Value存储>默认值。）

Viper使用[crypt](https://github.com/bketelsen/crypt)从K/V存储中检索配置，这意味着如果你有正确的gpg密匙，你可以将配置值加密存储并自动解密。加密是可选的。

你可以将远程配置与本地配置结合使用，也可以独立使用。

`crypt`有一个命令行助手，你可以使用它将配置放入K/V存储中。`crypt`默认使用在[http://127.0.0.1:4001](http://127.0.0.1:4001/)的etcd。

```bash
$ go get github.com/bketelsen/crypt/bin/crypt
$ crypt set -plaintext /config/hugo.json /Users/hugo/settings/config.json
```

确认值已经设置：

```bash
$ crypt get -plaintext /config/hugo.json
```

有关如何设置加密值或如何使用Consul的示例，请参见`crypt`文档。

### 远程Key/Value存储示例-未加密

#### etcd

```go
viper.AddRemoteProvider("etcd", "http://127.0.0.1:4001","/config/hugo.json")
viper.SetConfigType("json") // 因为在字节流中没有文件扩展名，所以这里需要设置下类型。支持的扩展名有 "json", "toml", "yaml", "yml", "properties", "props", "prop", "env", "dotenv"
err := viper.ReadRemoteConfig()
```

#### Consul

你需要 Consul Key/Value存储中设置一个Key保存包含所需配置的JSON值。例如，创建一个key`MY_CONSUL_KEY`将下面的值存入Consul key/value 存储：

```json
viper.AddRemoteProvider("consul", "localhost:8500", "MY_CONSUL_KEY")
viper.SetConfigType("json") // 需要显示设置成json
err: = viper.ReadRemoteConfig()
```

#### Firestore

```go
viper.AddRemoteProvider("firestore", "google-cloud-project-id", "collection/document")
viper.SetConfigType("json") // 配置的格式: "json", "toml", "yaml", "yml"
err := viper.ReadRemoteConfig()
```

当然，你也可以使用`SecureRemoteProvider`。

### 远程Key/Value存储示例-加密

```go
viper.AddSecureRemoteProvider("etcd","http://127.0.0.1:4001","/config/hugo.json","/etc/secrets/mykeyring.gpg")
viper.SetConfigType("json") // 因为在字节流中没有文件扩展名，所以这里需要设置下类型。支持的扩展名有 "json", "toml", "yaml", "yml", "properties", "props", "prop", "env", "dotenv"
err := viper.ReadRemoteConfig()
```

### 监控etcd中的更改-未加密

```go
// 或者你可以创建一个新的viper实例
var runtime_viper = viper.New()

runtime_viper.AddRemoteProvider("etcd", "http://127.0.0.1:4001", "/config/hugo.yml")
runtime_viper.SetConfigType("yaml") // 因为在字节流中没有文件扩展名，所以这里需要设置下类型。支持的扩展名有 "json", "toml", "yaml", "yml", "properties", "props", "prop", "env", "dotenv"

// 第一次从远程读取配置
err := runtime_viper.ReadRemoteConfig()

// 反序列化
runtime_viper.Unmarshal(&runtime_conf)

// 开启一个单独的goroutine一直监控远端的变更
go func(){
	for {
	    time.Sleep(time.Second * 5) // 每次请求后延迟一下

	    // 目前只测试了etcd支持
	    err := runtime_viper.WatchRemoteConfig()
	    if err != nil {
	        log.Errorf("unable to read remote config: %v", err)
	        continue
	    }

	    // 将新配置反序列化到我们运行时的配置结构体中。你还可以借助channel实现一个通知系统更改的信号
	    runtime_viper.Unmarshal(&runtime_conf)
	}
}()
```

## 基于Viper实现的环境变量动态链接

```go
import (
   "github.com/spf13/viper"
)

// DynamicEnv is a dynamic adapter that interoperates with environment variables
func DynamicEnv(envName, Prefix string, defaultVal interface{}) interface{} {
   viper.SetDefault(envName, defaultVal)
   viper.SetEnvPrefix(Prefix)
   viper.BindEnv(envName)
   return viper.Get(envName)
}
```





