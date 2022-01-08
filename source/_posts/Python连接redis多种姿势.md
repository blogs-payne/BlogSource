---
title: Python连接redis多种姿势
author: Payne
tags:
  - Redis
categories:
  - - Redis
    - Python
    - Batch
date: 2022-01-08 23:06:49

---

示例环境

```dart
python 3.10
redis 6.2
python redis 4.1.0
```

本实例所有包

```python
from redis import StrictRedis, ConnectionPool
from pprint import pprint
from concurrent.futures.process import ProcessPoolExecutor
```



## Basic 

### Basic Client

```python
rds = StrictRedis(
    host='127.0.0.1',
    port=3218,
    # redis 6.0 以后需要加入，默认为 default
    username='default',
    password='xxxxwadsad',
    decode_responses=True,
    db=1,
)

```

### Basic Client Based On URL

```python
rds_url = 'redis://default:xxxxwadsad@127.0.0.1:3218/1'
rds = StrictRedis.from_url(rds_url)
pprint(rds.info())
```



## Connection Pool 

### Connection Pool class

```python
connection_pool = ConnectionPool(
    host='127.0.0.1',
    port=3218,
    # redis 6.0 以后需要加入，默认为 default
    username='default',
    password='xxxxwadsad',
    decode_responses=True,
    db=1,
)
connection_pool_client = StrictRedis(connection_pool=connection_pool)
pprint(connection_pool_client.info())
```



### Connection Pool class Base on URL

```python
rds_url = 'redis://default:xxxxwadsad@127.0.0.1:3218/1'
connection_pool = ConnectionPool.from_url(rds_url)
connection_pool_client = StrictRedis(connection_pool=connection_pool)
pprint(connection_pool_client.info())
```



## Pipeline

> Batch process, Don't forget to use `pipeline.execute()` after the batch is finished 

```python
pipeline = rds.pipeline(transaction=True)
pipeline = connection_pool_client.pipeline(transaction=True)
```



multiprocessing batch

```python
def process_item():
		# pipeline process logic

def main():
    with ProcessPoolExecutor(max_workers=6) as p:
　　　　 for _ in range(100):
            p.submit(process_item)
```



> tips: IO密集型用线程、协程，CPU密集型用进程

