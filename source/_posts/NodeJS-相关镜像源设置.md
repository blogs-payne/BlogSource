---
title: NodeJS 相关镜像源设置
author: Payne
tags:
  - nodejs
categories:
  - - nodejs
    - npm
    - yarn
abbrlink: 286144973
date: 2021-12-10 12:34:55
---

## `npm` 查看镜像源

```bash
# npm config (set | get | delete | list | edit)
npm config get (registry|sass_binary_site)
```

### 使用

**临时使用镜像**

```bash
npm install --registry=https://registry.npmmirror.com pkg_name -g cnpm
# 创建别名
alias npmc="npm --registry=https://registry.npmmirror.com"
```

**全局配置**

```bash
# npm
npm config set registry https://registry.npm.taobao.org
npm config set sass_binary_site=https://npm.taobao.org/mirrors/node-sass/phantomjs_cdn
```



## `yarn` 查看镜像源

```bash
# yarn config (set | get | delete | list | current)
yarn config get（registry｜sass_binary_site)
```

### 使用

**临时使用镜像**

```bash
yarn add --registry=https://registry.npm.taobao.org
```

**全局配置**

```bash
yarn config set registry https://registry.npm.taobao.org -g
yarn config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g
```



`yarn`使用

```bash
# 初始化项目
yarn init [-y]
# 添加依赖
yarn [global] add 
-D, --dev                           save package to your `devDependencies`(开发依赖)
-P, --peer                          save package to your `peerDependencies`(对等依赖)
-O, --optional                      save package to your `optionalDependencies`(可选依赖)
# 安装项目所有依赖 `yarn` or 
yarn install [--update-checksums]
# 更新
yarn upgrade
# 移除
yarn remove
```

