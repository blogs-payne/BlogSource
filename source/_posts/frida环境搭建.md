---
title: frida环境搭建
author: Payne
tags:
  - frida
categories:
  - - frida
    - hook
abbrlink: 2062059201
date: 2022-06-18 01:03:45
---

## Frida是什么东东？

frida 是面向开发人员、逆向工程师和安全研究人员的动态检测工具包,他包含有如下特征

- 脚本式：将自己的脚本注入黑盒进程。挂钩任何函数，监视加密 API 或跟踪私有应用程序代码，无需源代码。编辑，点击保存，并立即查看结果。全部无需编译步骤或程序重启
- 便捷: 适用于 Windows、macOS、GNU/Linux、iOS、Android 和 QNX。从 npm 安装 Node.js 绑定，从 PyPI 获取 Python 包，或通过其 Swift 绑定、.NET 绑定、Qt/Qml 绑定或 C API 使用 Frida。
- 自由、开源：Frida 是并将永远是自由软件（就像自由一样自由）。我们希望为下一代开发者工具赋能，并通过逆向工程帮助其他自由软件开发者实现互操作性。

Frida 拥有一个全面的测试套件，并且在广泛的用例中经过了多年的严格测试。

 frida 框架分为三部分：  

1）frida 本身的客户端模块 frida （python、nodejs） 

2）运行在系统上的交互工具 frida CLI 也称之为 frida-tools 

3）运行在目标机器上的代码注入工具服务 frida-serve

## 运行原理 

Frida 通过其强大的仪器核心 Gum 提供动态检测，Gum 是用 C 语言编写的。因为这种检测逻辑很容易发生变化，所以通常需要用脚本语言编写，这样在开发和维护它时会得到一个简短的反馈循环。这就是 GumJS 发挥作用的地方。只需几行 C 就可以在运行时内运行一段 JavaScript，它可以完全访问 Gum 的 API，允许您Hook函数，枚举加载的库，导入和导出的函数，读写内存，扫描模式的内存等

## firda 安装

```bash
python3 -m pip install frida-tools==5.3.0 objection==1.8.4 jnitrace==3.0.8
```

> 若使用Windows电脑，请将`python3` 修改为`python`
>
> 注意: 这里不建议直接使用pip安装frida,会造成frida版本的不兼容.建议直接安装frida-tools,根据frida-tools的依赖从而间接安装frida.

```bash
frida --version
```

## 安装 frida-server在Android 中



启动调试手机首先使用  `adb devices -l`  查看手机设备，如下图所示

![img](https://uploader.shimo.im/f/TIAvwNbSeR1jBJYf.png!thumbnail?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhY2Nlc3NfcmVzb3VyY2UiLCJleHAiOjE2NTU0ODYxODQsImZpbGVHVUlEIjoiSjhwZEhRRFZHNlJ0ZFlIeCIsImlhdCI6MTY1NTQ4NTg4NCwidXNlcklkIjo0ODM3NDU4MX0.dyfXSX4rfyjwwtBJjOX63E-IKLJvbpp0hQHGxasb5Ks)

查看使用 `adb -s emulator-5554 shell getprop ro.product.cpu.abi` 查看设备CPU处理器型号。如下图所示

![img](https://uploader.shimo.im/f/skKsGEauVb98s52E.png!thumbnail?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhY2Nlc3NfcmVzb3VyY2UiLCJleHAiOjE2NTU0ODYxODQsImZpbGVHVUlEIjoiSjhwZEhRRFZHNlJ0ZFlIeCIsImlhdCI6MTY1NTQ4NTg4NCwidXNlcklkIjo0ODM3NDU4MX0.dyfXSX4rfyjwwtBJjOX63E-IKLJvbpp0hQHGxasb5Ks)

由于这里采用的是雷电模拟器，故此处显示为 `x86`, 若是真实的手机应该为 ARM 或 ARM64

进入 https://github.com/frida/frida/releases ，下载对应版本frida-server  `frida-server-xx.x.xx-android-x86.xz` 

> `frida-server-xx.x.xx-os-xxx.xz`  
>
> 其中 
>
> xx.x.xx 为 frida对应的版本，可使用 frida --version 查看
>
> os: 为手机系统，一般为Androidxxx：
>
> 为CPU处理器型号， 可使用`adb shell getprop ro.product.cpu.abi`  查看

![img](https://uploader.shimo.im/f/iCjfJc31PXTIQZ0R.png!thumbnail?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhY2Nlc3NfcmVzb3VyY2UiLCJleHAiOjE2NTU0ODY3NjgsImZpbGVHVUlEIjoiSjhwZEhRRFZHNlJ0ZFlIeCIsImlhdCI6MTY1NTQ4NjQ2OCwidXNlcklkIjo0ODM3NDU4MX0.tBAy_yxnGt7YIlWjwV-vuqm1tBLK9OdxbkkMTEmHKC8)

下载完成后，鼠标双击压缩包`frida-server-15.0.13-android-x86.xz`进行解压。解压完成后推送至调试手机中。

```bash
# 在宿主机打开端口转发
adb forward tcp:27042 tcp:27542; adb forward tcp:27043 tcp:27543
# 推送至对应设备中
adb -s emulator-5554 push frida-server-15.0.13-android-x86 /data/local/tmp
# 打开可执行权限
chmod a+x frida-server-15.0.13-android-x86
# 关闭 liunx 的 SELinux
echo 0 > /sys/fs/selinux/enforce
# 执行 frida-server
./frida-server-15.0.13-android-x86
```

> 提示：通常并不建议直接使用 `frida-server` 直接运行, 因为检测进程frida名也是常见的对于frida的检测.故可以对frida-server进行重命名,来绕过该特征检测 

```bash
# 后台执行
nohub frida-server-15.0.13-android-x86 > /dev/null 2>&1 &
```

在直接使用`./frida-server` 运行后发现该终端操纵界面会卡住，我们可以使用如上的命令让frida在后台以守护进程的方式运行



使用 `frida-ps -D emulator-5554` 进行安装校验，如下所示

![img](https://uploader.shimo.im/f/Kd6l4pIihE0QM7kL.png!thumbnail?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhY2Nlc3NfcmVzb3VyY2UiLCJleHAiOjE2NTU0ODcxMzksImZpbGVHVUlEIjoiSjhwZEhRRFZHNlJ0ZFlIeCIsImlhdCI6MTY1NTQ4NjgzOSwidXNlcklkIjo0ODM3NDU4MX0.DCb0V9mwa8Hvu4Su-IjGvqwpyLUeM0mIaif_ZvJKBtE)

至此 frida 已经安装完毕，请尽情的使用frida吧
