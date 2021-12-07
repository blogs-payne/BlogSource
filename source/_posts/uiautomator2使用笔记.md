---
title: uiautomator2使用笔记
author: Payne
tags:
  - t1
categories:
  - - c1
    - c2
    - c3
date: 2021-12-06 14:51:53
---

## uiautomator2 简介

UiAutomator是Google提供的用来做安卓自动化测试的一个Java库，基于Accessibility服务。功能很强，可以对第三方App进行测试，获取屏幕上任意一个APP的任意一个控件属性，并对其进行任意操作。而uiautomator2便是UiAutomator的Python实现

除了对原有的库的bug进行了修复，还增加了很多新的Feature。主要有以下部分：

- 设备和开发机可以脱离数据线，通过WiFi互联（基于[atx-agent](https://github.com/openatx/atx-agent)）
- 集成了[openstf/minicap](https://github.com/openstf/minicap)达到实时屏幕投频，以及实时截图
- 集成了[openstf/minitouch](https://github.com/openstf/minitouch)达到精确实时控制设备
- 修复了[xiaocong/uiautomator](https://github.com/xiaocong/uiautomator)经常性退出的问题
- 代码进行了重构和精简，方便维护
- 实现了一个设备管理平台(也支持iOS) [atxserver2](https://github.com/openatx/atxserver2)
- 扩充了toast获取和展示的功能



相关链接如下：

[UiAutomator](https://developer.android.com/training/testing/ui-automator.html)：https://developer.android.com/training/testing/ui-automator.html

[uiautomator2](https://github.com/openatx/uiautomator2)： https://github.com/openatx/uiautomator2

[QUICK_REFERENCE](https://github.com/openatx/uiautomator2/blob/master/QUICK_REFERENCE.md)： https://github.com/openatx/uiautomator2/blob/master/QUICK_REFERENCE.md

## 安装

由于python实现的，在此可以使用`pip` 直接安装即可，命令如下

```bash
# # 如果是在Windows平台下，未做`python3` 与 `python` 的link，在这里使用`python` 而不是`python3`
python3 -m pip install --upgrade uiautomator2
```

> Tips： 建议使用虚拟环境



开发版安装

```bash
python3 -m pip install --upgrade --pre uiautomator2
```



源码安装

> 需要git客户端，若未安装git，可移步`https://git-scm.com/downloads`进行下载，
>
> 当然，源码也可以使用zip的方式进行下载，请自行探索

```bash
git clone https://github.com/openatx/uiautomator2
python3 -m pip install -e uiautomator2
```



### 校验

先准备一台（不要两台）开启了`开发者选项`的安卓手机，连接上电脑，确保执行`adb devices`可以看到连接上的设备。如下图所示

![image-20211206153159233](https://tva1.sinaimg.cn/large/008i3skNgy1gx45djlejbj30mr01e0sq.jpg)

运行`python3 -m uiautomator2 init`安装包含httprpc服务的apk到手机+`atx-agent, minicap, minitouch` 

> 在过去的版本中，这一步是必须执行的，但是从1.3.0之后的版本，当运行python代码`u2.connect()`时就会自动推送这些文件了



```python
import uiautomator2 as u2

# 连接设备(当只有只有一台设备的时候可以为空，当有多台设备可以是设备号或ip地址)
device = u2.connect()
# get uiautomator2 device info
pprint(device.info)
# get device info
pprint(device.device_info)
# get device windows size
print(device.window_size())
# get device wlan ip
pprint(device.wlan_ip)
# get serial id
pprint(device.serial)
```



![image-20211206153746081](https://tva1.sinaimg.cn/large/008i3skNgy1gx45jkcixoj30d906qmxa.jpg)

## app开启与关闭

当我们需要打开对应的app时，需要知道对应设备的包名。获取包名有两种方式

- 在设备上打开对应的app，获取当前app包名(`app_current()`)
- 获取全部的应用包(`app_list_running()`)

```bash
# 开启app
app_start
# 关闭app
app_stop
```

### Example

> 此时笔者的测试手机在已经打开app

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date         : 07-12-2021 
# @Author       : Payne
# @Email        : wuzhipeng1289690157@gmail.com
import random
import time
from loguru import logger
import uiautomator2 as u2

# content device
device = u2.connect()
logger.info(f"DEVICE INFO:{device.info}")
# check current app
current_app = device.app_current()
# get the package
device.app_start(current_app.get('package'), stop=True)
# 正态分布休眠,模拟操作
time.sleep(random.uniform(10, 20))
# stop all app
device.app_stop_all()
```



> Tips: 复习一下adb command

```bash
# adb 命令 -- 获取报包名

# current （需要打开app）
adb -s {device_serial} shell dumpsys activity | grep mFocusedActivity
# all
adb -s {device_serial} shell pm list packages

# 根据关键字过滤包
adb -s {device_serial} shell pm list packages | grep “keyword”
# 查看包安装位置 
adb -s {device_serial} shell pm list packages -f
```



## 点击

- Turn on/off screen

  ```
  d.screen_on() # turn on the screen
  d.screen_off() # turn off the screen
  ```

- Press hard/soft key

  ```
  d.press("home") # press the home key, with key name
  d.press("back") # press the back key, with key name
  d.press(0x07, 0x02) # press keycode 0x07('0') with META ALT(0x02)
  ```

- These key names are currently supported:

  - home、back、

  - left、right、up、down

  - center、menu、search

  - enter、delete ( or del)

  - recent (recent apps)

  - volume_up、volume_down、volume_mute

  - camera、power

- Click on the screen

```bash
d.click(x, y)
```

- Double click

```bash 
d.double_click(x, y)
d.double_click(x, y, 0.1) # default duration between two click is 0.1s
```

- long_click

```bash
d.long_click(x, y)
d.long_click(x, y, 0.5) # long click 0.5s (default)
```



## 滑动

**Swipe**

```python
# Swipe
swipe(self, fx, fy, tx, ty, duration: Optional[float] = None, steps: Optional[int] = None)
fx, fy：起始坐标
tx, ty：目标坐标
duration： 持续时间（力度）
steps： 分开滑动次数
```

**swipe_ext**

```bash
d.swipe_ext("right") # 手指右滑，4选1 "left", "right", "up", "down"
d.swipe_ext("right", scale=0.9) # 默认0.9, 滑动距离为屏幕宽度的90%
d.swipe_ext("right", box=(0, 0, 100, 100)) # 在 (0,0) -> (100, 100) 这个区域做滑动

# 实践发现上滑或下滑的时候，从中点开始滑动成功率会高一些
d.swipe_ext("up", scale=0.8) # 代码会vkk

# 还可以使用Direction作为参数
from uiautomator2 import Direction

d.swipe_ext(Direction.FORWARD) # 页面下翻, 等价于 d.swipe_ext("up"), 只是更好理解
d.swipe_ext(Direction.BACKWARD) # 页面上翻
d.swipe_ext(Direction.HORIZ_FORWARD) # 页面水平右翻
d.swipe_ext(Direction.HORIZ_BACKWARD) # 页面水平左翻
```

**Drag**

```
d.drag(sx, sy, ex, ey)
d.drag(sx, sy, ex, ey, 0.5) 

sx, sy：起始坐标
ex, ey：目标坐标
```

**Swipe points**

```python
# swipe from point(x0, y0) to point(x1, y1) then to point(x2, y2)
# time will speed 0.2s bwtween two points
# swipe_points(self, points, duration: float = 0.5)
d.swipe_points([(x0, y0), (x1, y1), (x2, y2)], 0.2))
```



## 选择器

选择器是一种在当前窗口中识别特定 UI 对象的便捷机制, 很多时候仅按照坐标时点击并不精确，通用型不强。

选择器支持以下参数。有关详细信息，请参阅[UiSelector Java 文档](http://developer.android.com/tools/help/uiautomator/UiSelector.html)。

- `text`, `textContains`, `textMatches`,`textStartsWith`
- `className`, `classNameMatches`
- `description`, `descriptionContains`, `descriptionMatches`,`descriptionStartsWith`
- `checkable`, `checked`, `clickable`,`longClickable`
- `scrollable`, `enabled`, `focusable`, `focused`,`selected`
- `packageName`, `packageNameMatches`
- `resourceId`, `resourceIdMatches`
- `index`, `instance`

