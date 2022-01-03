---
title: VsCode初始化配置 
author: Payne 
tags:
  - Visual Studio Code
categories:
  - - Visual Studio Code
abbrlink: 2104691580
date: 2021-11-05 20:01:44
---

## 配置

```json
"workbench.colorTheme": "Solarized Light",
"files.autoSave": "afterDelay",
"editor.formatOnSave": true,
"editor.fontSize": 14,
"editor.fontFamily": "JetBrains Mono, Menlo, Monaco, 'Courier New', monospace",
"editor.fontLigatures": true,
"search.exclude": {
"**/node_modules": true,
"**/bower_components": true,
"**/target": true,
"**/logs": true,
"**/.git": true,
"**/.svn": true,
"**/.hg": true,
"**/CVS": true,
"**/.DS_Store": true,
"**/*.js": {
"when": "$(basename).ts"
},
"**/.idea": true
},
"files.exclude": {
"**/node_modules": true,
"**/bower_components": true,
"**/target": true,
"**/logs": true,
"**/.git": true,
"**/.svn": true,
"**/.hg": true,
"**/CVS": true,
"**/.DS_Store": true,
"**/*.js": {
"when": "$(basename).ts"
},
"**/.idea": true
},
```

### 代码提示配置

settings -搜索-> prevent -> none

## 插件

### Program Language

#### Python

- Python Docstring Generator
- Python
- Python Environment Manager
- Visual Studio IntelliCode
- Python Indent

#### PHP

- php-extension-pack

#### Cloud

- DevOps Cloud Extension pack

#### Reception

- VS Code JavaScript (ES6) snippets
- open in browser
- auto complete Tag
- auto rename Tag
- auto close Tag
- Import Cost

#### Other

- vscode-icons
- vsc-essentials
- gitlens:    `git config pull.rebase false`

code studio pack

## 常用快捷键

### Window

`Alt + →` ：代码前进下一级

`Alt + ←` ：代码返回上一级

---

`Ctrl + K + 0`:    收缩所有代码(0是代码折叠级别，同理可以换用1，2，3等)

`Ctrl + K + J`:    取消收缩所有代码

---

`Ctrl + K + S`：快捷键文档

`Alt + Shift + F` ：代码格式化

`Ctrl + Shift + P`： 显示所有命令

`Ctrl + P`： 显示所有命令

### Mac

- `Ctrl + -`：代码返回上一级

- `Ctrl + Shift + -`： 代码前进下一级

---

- `Command + K + 0`:    收缩所有代码(0是代码折叠级别，同理可以换用1，2，3等)

- `Command + K + J` 取消收缩所有代码

---

- `Command + K + S`：快捷键文档

- `Opt + Shift + F` ：代码格式化

- `Command + Shift + P`： 显示所有命令

- `Command + p` ：打开最近文件

