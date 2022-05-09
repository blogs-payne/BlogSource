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

使用`SSDictCursor`无缓冲游标来操作，使用`fetchall_unbuffered`，来进行。同时辅以分页查询即可。

首先是建立连接，`curror` 的选择

```python
from pymysql import connect, cursors

client = connect(**{
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "123321",
    "database": "test",
    'charset': 'utf8'
}, cursorclass=cursors.SSCursor)

cursor = client.cursor()
```

注意在此可以选择**无缓冲游标**， 来操作。即`cursors.SSCursor`,`cursors.SSDictCursor`。

```python
page_count = 1000
for pg in range(1000):
    query_sql = f"""select * from xiaohongshu_comment_note_2 limit {page_number * page_count}, {page_count};"""
		cursor.execute(query_sql)
    for results in cursor.fetchall_unbuffered():
        print(results)
```



当然还可以在函数中这样写

```python
def unbuffer_query(page_count=1000, max_page=1000):
    """
    :param page_count:
    :param max_page:
    :return:
    """
    for page_number in range(max_page):
        query_sql = f"""select * from xiaohongshu_comment_note_2 limit {page_number * page_count}, {page_count};"""
        cursor.execute(query_sql)
        yield from cursor.fetchall_unbuffered()


for i in unbuffer_query(page_count=999, max_page=9999):
    print(i)
```



瑞思拜～
