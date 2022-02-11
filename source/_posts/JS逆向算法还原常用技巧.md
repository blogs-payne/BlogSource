---
title: JS逆向算法还原常用技巧
author: Payne
tags:
  - Crawler
categories:
  - - JavaScript
    - 技巧
    - JS
abbrlink: 1413352655
date: 2021-12-23 15:19:04
---

Hi，许久不见，我是Payne啊。

ok，那么我们先说说核心本质吧，其核心本质个人认为依旧是伪装。就像爬虫为对面对反爬虫反制，从而添加特征，不断的逼近**像**真人。

自然在参数、环境还原这里也是。

无论是一下的**补环境**、**扣代码**、**手动还原**，也都是在模拟生成加密逻辑。

## 补环境

### 补环境的定义

补环境顾名思义就是，将获取到的关键JS在通过**修补环境**的方法在本地或服务器上能够正常运行获取到正确的返回值，从而完成参数的加密模拟。

当然大部分情况下补环境与抠代码密不可分（一般是扣代码，然后在补环境），扣代码移步第二部分

### 核心本质

无论是缺啥补啥的前的构建错误，还是使用代理监控运行。都是在做链路追踪。在补环境这里是秉承着遇河搭桥，缺啥补啥思路。

常用的方法一般有两个：

> 假设获取到了核心的JS代码后

一种是使用运行，从而构建错误实现报错，然后通过补方法、对象来fix。从而完成补环境，（当然这是必须的）。

当完成以上的操作后，遇见风控、遇见伏点。可以正常通过运行，但无法获取到正确的参数。此时使用`Proxy`来监听实现监测，协助调试。

### 实现

是方法写空方法`arguments`看传参，对象写空对象`Proxy`来相助，进行链路追踪，完成模拟

```javascript
window = global;
document = {
    location: {'protocol': 'https:'},
    referrer: '',
    getElementById: () => {
        console.log("getElementById:", arguments);
    },
    getElementsByClassName: () => {
        console.log("getElementsByClassName:", arguments);
    },
    getElementsByName: () => {
        console.log("getElementsByName:", arguments);
    },
    getElementsByTagName: () => {
        console.log("getElementsByTagName:", arguments);
    },
    getElementsByTagNameNS: () => {
        console.log("getElementsByTagNameNS:", arguments);
    },
    createElement: () => {
        console.log("createElement:", arguments);
    }

};
navigator = {
    appCodeName: "Mozilla",
    appName: "Netscape",
    appVersion: "5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
    language: "zh-CN",
    languages: (2)['zh-CN', 'zh'],
    platform: "MacIntel",
    product: "Gecko",
    productSub: "20030107",
    userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
    vendor: "Google Inc.",
};
screen = {
    availHeight: 1055,
    availLeft: 0,
    availTop: 25,
    availWidth: 1920,
    colorDepth: 24,
    height: 1080,
    pixelDepth: 24,
    width: 1920,
};
location = {
    href: 'https://www.xxx.com/website-login/captcha?redirectPath=https%3A%2F%2Fwww.xxx.com%2Fdiscovery%2Fitem%2F618bf8f60000000001027ccd',
    hostname: 'www.xxx.com',
    host: 'www.xxx.com',
};
```

### 小结

1. 缺啥补啥：通过本地运行实现错误

Proxy

空对象：使用proxy代理，空方法：使用其中的`arguments`，获取传入参数

获取DOM节点：当做`[ ]`处理

创建DOM节点：当作`{ }`处理

```javascript
null_function = () => {
    console.log(arguments)
};


// 代理
const proxy = (obj, obj_name) => {
    return new Proxy(obj, {
        get: (target, key) => {
            console.log(obj_name, "Getting", key)
            return target[key];
        },
    })
}


//吐环境
function proxy(proxy_array) {
    for (let i = 0; i < proxy_array; i++) {
        eval(proxy_array[i] + ' = new Proxy(' + proxy_array[i] + ',{ ' +
            'get(target,key){ ' +
            'debugger;' +
            'console.log("====================")' +
            'console.log("获取了",' + proxy_array[i] + ' 的key属性"); ' +
            'console.log("====================")' +
            'return target[key]; }')
    }
}

//常用的proxy_array
var proxy_array = ["window", "document", "location", "navigator"]
proxy(proxy_array)
```

## 抠代码

找到关键入口，抠下来🐶～。

重在调试，不再抠（抠就是复制粘贴）

小技巧：

打开浏览器的设置，找到如下所示的`code filding` 勾选打开。JS代码收缩复制一气呵成，妙啊～

![image-20211223145757359](https://tva1.sinaimg.cn/large/008i3skNgy1gxnrxih3bqj308v07mweo.jpg)

## 手动还原

通过调试查看算法实现过程，结合加密库复现。

> Tip: 可以但没必要，手撕随爽，但可不要贪杯哦
