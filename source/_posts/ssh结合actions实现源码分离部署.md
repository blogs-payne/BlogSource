---
title: ssh结合actions实现源码分离部署
author: Payne
tags:
  - ssh
  - actions
  - blog
categories:
  - - blog
    - ssh
    - actions
abbrlink: 3847153486
date: 2021-09-04 13:37:41
---
本博客采用github page实现部署，但由于github的性质无法有效的进行分离快速部署。

必须博客展示页，必须以username.github.io结尾，这样感觉不是很方便

部署前基本流程为，部署github page -> 手动上传源码到对应仓库。

那么我们是否可以直接push到私有源码仓库，出发二段部署从实现自动的博客部署，此时我们只需要关心与维护自己的博客源码，再也不用刻意的关注部署了

说干就干

## 前置条件

### ssh部署

```
ssh-keygen -t rsa -C "your email"
```

> 若配置了全局的git email 可使用`ssh-keygen -t rsa -C "$(git config user.email)" -f gh-pages -N ""`

完成后将在本地`$HOME/.ssh`中生成私钥`id_rsa`,与公钥，`id_rsa.pub`,将公钥上传到github上，进入https://github.com/settings/keys ，登陆自己的github账号。如下所示

![image-20210904121559885](https://tva1.sinaimg.cn/large/008i3skNgy1gu4h329orfj60tf0a775a02.jpg)

New SSH Key

![image-20210904121643113](https://tva1.sinaimg.cn/large/008i3skNgy1gu4h3tn133j60lp0bomxg02.jpg)

其中title为自定义，key为`id_rsa.pub`中内容。完成后点击Add SSH key即可

## 建立私有博客源码仓库

github上创建一个私有仓库即可，详细流程不在过多赘述

## 创建Actions

### 配置Actions secrets

Settings -> Deploy keys -> New repository secrets，如下所示

![image-20210904110320916](https://tva1.sinaimg.cn/large/008i3skNgy1gu4ezhkflmj61mk0u0aeq02.jpg)

![image-20210904110617453](https://tva1.sinaimg.cn/large/008i3skNgy1gu4f2jcgr5j61sv0u00v602.jpg)

将上面生成的id_rsa，复制到私钥中。

![image-20210904122401191](https://tva1.sinaimg.cn/large/008i3skNgy1gu4hbf985wj6172072wf202.jpg)

将workflow增加到源码文件中，拉取到本地。

deploy.yml如下

```yaml
# This is a basic workflow to help you get started with Actions

name: Deploy to Github Pages

# Controls when the action will run. Triggers the workflow on push or pull request
# events but only for the master branch
on:
  push:
    branches: [ master ]

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2

      - name: Env setup
        run: |
          mkdir -p ~/.ssh/
          echo "${{ secrets.DEPLOY_KEY }}" > ~/.ssh/id_rsa	# DEPLOY_KEY 为secret name
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
          # setup deploy git account
          git config --global user.name "your user name"
          git config --global user.email "your email"

      - name: Hexo Build and Deploy
        run: |
          find . -type f -name *.log -delete
          npm install
          npm run clean
          npm run build
          npm run deploy
```

## 总结

以上便是github page 源码保护分析详细过程，其基本原理就是将ssh部署的工作交给自动构建的Actions。

