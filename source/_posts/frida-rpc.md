---
title: frida-rpc
author: Payne
tags:
  - frida
categories:
  - - frida
    - rpc
abbrlink: 4038451747
date: 2022-06-26 14:40:16
---

## frida 主动调用

主动调用: 强制去调用函数执行

被动调用: 由app主导,按照正常的执行顺序执行函数. 函数执行完全依靠与用户交互完成从而间接的调用到关键函数

在Java中,类的函数可以分为两种: 类函数与实例方法, 也可以称之为静态方法和动态方法.

类函数使用关键字`static` 修饰,与对应的类绑定, 当然如果该类函数还被`public` 修饰,则在外部就可以直接通过类去调用

实例方法没有被 `staic` 修饰,在外部只能通过实例化对应的类,在通过该实例调用对应的方法.

在frida中主动调用的类型会根据方法的类型区分开来, 类函数的直接调用使用`Java.use` 即可,实例方法则需要先找到对应的实例后对方法进行调用, 通常使用`Java.choose`.

示例代码如下

```js
setImmediate(function () {
    console.log('Script loaded successfully, start hook...');
    Java.perform(function () {
        console.log('Inside java perform function...');

        // 静态(类)函数 主动调用
        let class_name = Java.use('com.xxx.xxx.xxx');
        let result1 = class_name.method();

        // 动态(实例)方法 主动调用
        Java.choose('com.xxx.xxx.xxx', {
            onMatch: function (instance) {
                console.log('instance found ', instance);
                let result2 = instance.method();
            },
            onComplete: function () {
                console.log('search complete');
            }
        });
    });
})
```

## frida-rpc

通过exports 将结果导出,以便于python 结合frida模块直接调用.

js脚本与hook脚本写法基本一致,示例代码如下所示

```js
// rpc.js
function func1() {
    console.log('Script loaded successfully, start hook...');
    var xxx_result = '';
    Java.perform(function () {
        console.log('Inside java perform function...');
        var class_name = Java.use('com.xxx.xxx.xxx');
        xxx_result = class_name.method_name('参数');
    });
    return xxx_result;
};


function func2() {
    console.log('Script loaded successfully, start hook...');
    var xxx_result = '';
    Java.perform(function () {
        console.log('Inside java perform function...');
        Java.choose('com.xxx.xxx', {
            onMatch: function (instance) {
                xxx_result = class_name.method_name('参数');
            },
            onComplete: function () {
                console.log('search complete');
            }
        })
    });
    return xxx_result;
}

rpc.exports = {
    rpc_func1: func1,
    rpc_func2: func2
}
```

```python
# rpc.py
# File: proc.py
# User: Payne-Wu
# Date: 2022/6/26 17:33
# Desc:
import sys
import frida
from loguru import logger

device = frida.get_usb_device()
script_path = "HookScript/example.js"


def message_call_back(message, data):
    """
    message call back
    :param message:
    :param data:
    :return:
    """
    logger.info(message)
    logger.info(data)


def attach_hook(app_name):
    """
    :param app_name:
    :return:
    """
    process = device.attach(app_name)
    with open(script_path, 'r', encoding='utf-8') as f:
        script = process.create_script(f.read())
    script.on('message', message_call_back)
    script.load()
    sys.stdin.read()


def spawn(package_name):
    """
    :param package_name:
    :return:
    """
    pid = device.spawn(package_name)
    process = device.attach(pid)
    with open(script_path, 'r', encoding='utf-8') as f:
        script = process.create_script(f.read())
    script.on('message', message_call_back)
    script.load()
    # rpc 
    # script.exports.func_name
    device.resume(pid)
    sys.stdin.read()


if __name__ == '__main__':
    spawn('com.xxx.xxx')
```

