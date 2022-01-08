---
title: 使用迭代器优化pymysql大量查询
author: Payne
tags:
  - pymysql
categories:
  - - pymysql
    - python
    - iter
abbrlink: 1032104040
date: 2021-12-10 19:25:19
---

## 缘由

当我们需要使用`pymysql`进行大量数据的提取时，发现越来越慢。直到阻塞，down。

## 解决

使用`SSDictCursor`无缓冲游标来操作，使用`fetchall_unbuffered`，来进行。同时辅以分页查询即可

```python
import pprint

import pymysql as pms
from pymysql import cursors

client = pms.connect(**client_config)
cursor = client.cursor()

step = 1000
for pg in range(1000):
    cursor.execute(f"select * from xiaohongshu_comment_note_2 limit {pg * step}, {step};")
    for _ in cursor.fetchall_unbuffered():
        pprint.pprint(_)
```

