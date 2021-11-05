---
title: VsCode初始化配置
author: Payne
tags:
  - Mac
categories:
  - - Mac
    - Visual Studio Code
date: 2021-11-05 20:01:44
---

## 配置

```json lines
{
  "workbench.colorTheme": "Monokai Dimmed",
  "files.autoSave": "onFocusChange",
  "editor.formatOnSave": true,
  "editor.fontSize": 14,
  "editor.suggest.snippetsPreventQuickSuggestions": false,
  "workbench.iconTheme": "vscode-icons",
  "redhat.telemetry.enabled": true,
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "editor.suggestSelection": "first",
  "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
  "terminal.integrated.inheritEnv": false,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "editor.linkedEditing": true,
  "explorer.confirmDelete": false,
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/target": true,
    "**/logs": true
  },
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true,
    "**/CVS": true,
    "**/.DS_Store": true,
    "**/*.js": {
      "when": "$(basename).ts"
    },
    "**/node_modules": true,
    "**/.idea": true
  }
}

```

## 插件

### Program Language

#### Python

python-extension-pack

Jupyter



#### PHP

php-extension-pack



#### Go

Go Nightly 

> command + shift + p	`>go:install/Update Tools`



#### Cloud 

Docker

Kubernetes

Bridge to Kubernetes

Cloud code



#### Reception

View In Browser

Auto rename tag

Auto close tag



#### Other

vscode-icons

YAML

Path Intellisense

stylelint

Import Cost

Prettier - Code formatter

beautify

Better Comments

Bracket Pair Colorizer

gitlens	`git config pull.rebase false`





## 常用快捷键

> Mac

|                                                              |                                     |
| ------------------------------------------------------------ | ----------------------------------- |
| `ctrl + -`：代码返回上一级                                   | `ctrl + shift + -`： 代码前进下一级 |
| `command + k + 0`:	收缩所有代码(0是代码折叠级别，同理可以换用1，2，3等) | `command + k + j` 取消收缩所有代码  |
|                                                              |                                     |

`comand + k + s`：快捷键文档

`opt + shift + f` ：代码格式化

`command + shift + P` 显示所有命令

`command + p` 打开最近文件

