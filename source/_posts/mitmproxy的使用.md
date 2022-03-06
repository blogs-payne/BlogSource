---
title: mitmproxy的使用
author: Payne
tags:
  - mitmproxy
categories:
  - - mitmproxy
    - mitmweb
    - mitmdump
date: 2022-03-07 00:38:21
---



MitmProxy是一组优秀的网络代理拦截工具，可为 HTTP/1、HTTP/2 和 WebSockets 提供交互式、支持 SSL/TLS 的拦截代理。它提供 拦截 HTTP 和 HTTPS 请求和响应并动态修改它们、保存完整的 HTTP 会话，以供重放攻击和分析、反向代理模式将流量转发到指定服务器、macOS 和 Linux 上的透明代理、对 HTTP 流量进行脚本化更改等功能。

- 官方地址：https://mitmproxy.org/
- 官方文档：https://docs.mitmproxy.org
- 官方博客：https://mitmproxy.org/posts/
- 插件: https://docs.mitmproxy.org/stable/addons-overview/
- Github: https://github.com/mitmproxy/mitmproxy
- Releases：https://github.com/mitmproxy/mitmproxy/releases
- DockerHub：[https://hub.docker.com/r/mitmproxy/mitmproxy](https://hub.docker.com/r/mitmproxy/mitmproxy/)
- 证书安装: http://mitm.it/

## 安装

### Python3安装

直接使用pip即可，使用如下命令进行安装

```bash
# 升级pip
python3 -m pip install -U pip
# 安装
python3 -m pip install -U mitmproxy
```

> 由于windows话默认是没有python3的（如果你没做兼容也就是将python复制一份副本并重命名为python3），使用python即可

### Mac

Mac 下推荐使用 `homebrew`安装，尤其是`m1`的，注意啦！！！

别问我怎么知道的，说多了都是泪

```bash
brew install mitmproxy
```

## mitmproxy组成

mitmproxy 由mitmproxy、mitmdump、mitmweb组成

### mitmproxy

mitmproxy是用于调试、测试、隐私测量和渗透测试的瑞士军刀。它可用于拦截、检查、修改和重放 Web 流量，例如 HTTP/1、HTTP/2、WebSockets 或任何其他受 SSL/TLS 保护的协议。您可以美化和解码从 HTML 到 Protobuf 的各种消息类型，即时截取特定消息，在它们到达目的地之前对其进行修改，并稍后将它们重播到客户端或服务器。

### mitmdump

强大的插件功能与python api集成，提供了对mitmproxy的完全控制，可以自动修改消息、重定向流量、可视化消息或实现自定义命令。基于mitmdump可实现拓展，完全自由定制。实现基于此的流量转发代理中间件。

###  mitmproxy

 在图形界面中使用 mitmproxy 的主要功能 mitmweb。mitmweb 为您提供任何其他应用程序或设备的类似体验，以及请求拦截和重放等附加功能。

## 证书安装与配置

对于任何中间人抓包工具来说，若需要完整的捕获HTTPS请求，必须需要配置HTTPS证书。由于mitmproxy的证书在安装时便已经自带了，所以不必多次安装。只需配置证书即可。

手机上需要下载直接进入  http://mitm.it/ 即可（需要先连接上mitmproxy的代理）



## mitmproxy界面

mitmproxy有许多的功能界面主要有以下几个

### index

打开代理时的index界面，此界面为中心界面，一进来就是这个，简要的介绍了包

![image-20220307012744921](https://tva1.sinaimg.cn/large/e6c9d24egy1h00od9mq9lj21js0u0qls.jpg)



### 包详情界面

使用`j `、`k` （或者上下方向键）实现包之间的移动，enter（回车）进入包的详情界面，可以使用tab进行切换。如下图所示

>  当然是要大写的 `P` 也可以进入这里

![image-20220307012909484](https://tva1.sinaimg.cn/large/e6c9d24egy1h00oeqi65tj21hp0u0tf3.jpg)



### 帮助界面

每个CLI基本上都有help，而mitmproxy自然也有， 如下

> `?`: 进入

![image-20220307013538512](https://tva1.sinaimg.cn/large/e6c9d24egy1h00olhfb8lj21hn0u0goo.jpg)

还有过滤帮助，可以使用`TAB` 实现切换。如下所示

![image-20220307013639677](https://tva1.sinaimg.cn/large/e6c9d24egy1h00omjcg24j21c40u0ady.jpg)

当使用`f` 快速进入过滤命令中 再加上过滤语法即可实现过滤，并在其中输入 `~u baidu`如下所示

![image-20220307013812180](https://tva1.sinaimg.cn/large/e6c9d24egy1h00ooh970tj21go0u0gnd.jpg)

实现对url为 `baidu` 的实现过滤展示

### Key Bindings界面

`shift + k` 也就是大写的K进入此界面

按键绑定界面，这里展示了所有的按键在mitmproxy中的功能，当然也可以修改其绑定，其界面如下所示。

![image-20220307013411247](https://tva1.sinaimg.cn/large/e6c9d24egy1h00ojylhwpj215g0u0tc4.jpg)





### Events界面

此界面可以查看捕获流量的所有事件，使用`E` 进入，如下所示

![image-20220307014113646](https://tva1.sinaimg.cn/large/e6c9d24egy1h00oraucocj21bz0u0ai3.jpg)



### Command Reference界面

所有的输入的命令都可以在这里找到，当然需要一些英文的识别能力， 如下所示

> `shift + c` ：进入Command Reference界面
>
> `:` 进入命令输入状态

![image-20220307014328724](https://tva1.sinaimg.cn/large/e6c9d24egy1h00otmz81bj21kd0u0wke.jpg)



###  Options界面

参数选项界面，可以认为这是mitmproxy设置界面， 如下所示

> 大写的`o` 进入

![image-20220307014527641](https://tva1.sinaimg.cn/large/e6c9d24egy1h00ovqurflj21em0u0792.jpg)

## 一些常用的按键

### 移动

| 快捷键 | command              | 说明               |
| ------ | -------------------- | ------------------ |
| q      | console.view.pop     | 返回：界面间的返回 |
| g      | console.nav.start    | 跳到第一行         |
| G      | console.nav.end      | 跳到最后一行       |
| h      | console.nav.left     | 跳到左面           |
| j      | console.nav.down     | 跳到下一行         |
| k      | console.nav.up       | 跳到上一行         |
| l      | console.nav.right    | 跳到右面           |
| space  | console.nav.pagedown | 跳到本页最后一行   |
| ctrl b | console.nav.pageup   | 跳到本页第一行     |
| ctrl f | console.nav.pagedown | 跳到本页最后一行   |
| tab    | console.nav.next     |                    |



可参考 `? ` 



## mitmdump具体实现

一个基于mitmdump 实现的流式流量转发处理平台: [mitmdumpMan](https://github.com/WebSpiderSuperStar/MitmDumpMan)







