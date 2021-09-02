---
title: docker分层构建
author: Payne
tags:
  - t
categories:
  - - Redis
    - redis
    - 小技巧
abbrlink: 2890729769
date: 2021-09-02 18:08:44
---

## 引子

​		在构建、部署、测试等情景中下不知你也是否遇到过这么几个问题，构建慢、依赖安装慢、重复性构建。以至于每一次采用docker来构建时，都需要等上那么几分钟。有时候是非常的浪费时间，那么是否有方法进行一次分离构建呢。当然正如docker口号所说的那般"**Build once，Run anywher**"，

那么该如何解决“**构建慢、依赖安装慢、重复性构建**”的问题呢，看似三个或者更多问题，其实归根结底是一个问题——分层构建

## 分层构建

想深层理解docker的分层构建，不得不从docker的设计特性出发。虚拟机与docker结构，如下图所示。

![image-20210902182150947](https://tva1.sinaimg.cn/large/008i3skNgy1gu2gf5gk5aj60kn0c40tr02.jpg)

**一层一层的分层结构**，那么所谓分层构建只需要将**环境依赖**与**业务代码**分开构建即可。实现如下

- 短时间内环境依赖构建一次且仅构建一次

- 业务代码触发构建

## 例子

### python

```dockerfile
#构建环境依赖
## 拉取pythoo镜像
FROM python:3.9
## 设置环境变量，相当于linux的export
ENV PATH /usr/local/bin:$PATH
## 在容器中进入根目录code（如果没有code目录则创建）相当于cd
WORKDIR /code
## 将执行docker build 路径下的所有文件copy到容器内所在的目录
COPY requirements.txt .
## 执行shell命令
RUN python3 -m pip install -U pip && \
    python3 -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

```sh
# 构建
docker build -t user/img_name:version .
# 发布
docker push user/img_name:version
```

```dockerfile
#项目构建
FROM user/img_name:version
WORKDIR /app
COPY . .
CMD ["supervisord","-c", "supervisord.conf"]
```

#### golang

两层：	1.依赖构建 2.编译与项目构建

三层：	1. 依赖构建 2.编译构建 3. 运行文件构建

```bash
FROM golang:1.16 as builder
# Setting environment variables
ENV GOPROXY="https://goproxy.cn,direct" GO111MODULE="on" CGO_ENABLED="0" GOOS="linux" GOARCH="amd64"
# Switch to workspace
WORKDIR /go/src/github.com/gowebspider/goproxies/
# Load file
COPY . .
# Build and place the results in /tmp/goproxies
RUN go build -o /tmp/goproxies .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /tmp/goproxies .
CMD ["./goproxies"]
```

