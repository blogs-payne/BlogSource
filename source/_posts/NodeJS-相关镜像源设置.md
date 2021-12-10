---
title: NodeJS 相关镜像源设置
author: Payne
tags:
  - nodejs
categories:
  - - nodejs
    - npm
    - yarn
date: 2021-12-10 12:34:55
---



## 查看镜像源

```bash
# npm
# npm config (set | get | delete | list | edit)
npm config get (registry|sass_binary_site)
# yarn
# yarn config (set | get | delete | list | current)
yarn config get（registry｜sass_binary_site)
```

## 使用

### 临时使用

> 命令中指定

```bash
npm install --registry=https://registry.npmmirror.com pkg_name -g cnpm
yarn add --registry=https://registry.npm.taobao.org
```

> 别名
>
> 创建一个别名进行试验镜像源

```bash
alias npmc="npm --registry=https://registry.npmmirror.com"
```

### 全局配置

```bash
# npm
npm config set registry https://registry.npm.taobao.org
npm config set sass_binary_site=https://npm.taobao.org/mirrors/node-sass/phantomjs_cdn
# yarn
yarn config set registry https://registry.npm.taobao.org -g
yarn config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g
```

