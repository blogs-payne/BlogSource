---
title: svn rollback
author: Payne
tags:
  - svn
categories:
  - - svn
    - svn rollbackc
abbrlink: 2411485724
date: 2022-02-11 15:22:55
---

`svn`使用 命令行实现rollback

```bash
# 查看前100条提交日志
svn log -v -l 100
svn log -v -l 100 > svn_do.log
# 尝试回滚
svn merge --dry-run -r 当前版本号:目标版本号 target_repo_addr
# 回滚
svn merge -r 当前版本号:目标版本号 target_repo_addr
```
