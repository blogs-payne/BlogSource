---
title: kubernetes NFS实践
author: Payne
tags:
  - Kubernetes
  - NFS
categories:
  - - Kubernetes
    - NFS
abbrlink: 2760374101
date: 2021-09-03 23:46:49
---

## NFS实践

### 安装NFS

```bash
# 下载nfs相关软件（全成员）
yum install -y nfs-common nfs-utils rpcbind
# 创建NFS共享文件夹，以及授权（需要root）
mkdir /nfs && chmod 766 /nfs && chown nfsnobody /nfs/
# 声明共享文件权限（NFS主服务器）
echo "/nfs *(rw,no_root_squash,no_all_squash,sync)" >> /etc/exports
# 
exportfs -r
systemctl restart rpcbind && systemctl restart nfs && systemctl status rpcbind && systemctl status nfs
```

#### 验证

> IP: 主机地址

```bash
# 查看共享目录
showmount -e IP
mkdir /test
# 将本机目录（test）挂载至目标目录（nfs）
mount -t nfs IP:/nfs /test
cd /test
echo "asdsadsa" >> a.txt
cd /
umount /test && rm -rf /test
```

### 部署PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-master
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
  nfs:
    path: /nfs
    server: 192.168.0.27 # 节点ip
```

### PVC

```yaml

apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      name: web
  clusterIP: None

---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: wangyanglinux/myapp:v2
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
    - metadata:
        name: www
      spec:
        accessModes: [ "ReadWriteOnce" ]
        storageClassName: "nfs"
        resources:
          requests:
            storage: 1Gi
```

### 验证

```
kubectl get pv
kubectl desc
```

![image-20210903233505574](https://tva1.sinaimg.cn/large/008i3skNgy1gu3v3oji9fj62090u047b02.jpg)

```
# 192.168.0.27 /nfs
echo "asds"  > index.html
kubectl get pod -o wid
```

![image-20210903234426686](https://tva1.sinaimg.cn/large/008i3skNgy1gu3vd2jo46j61vk04uace02.jpg)

```bash
curl 10.244.1.53
# asds
```
