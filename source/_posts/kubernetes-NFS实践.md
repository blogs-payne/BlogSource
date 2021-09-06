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
yum install -y nfs-common nfs-utils rpcbind
mkdir /nfs && chmod 766 /nfs && chown nfsnobody /nfs/
echo "/nfs *(rw,no_root_squash,no_all_squash,sync)" >> /etc/exports
systemctl restart rpcbind && systemctl restart nfs && systemctl status rpcbind && systemctl status nfs
```

#### 验证

```dart
showmount -e $IP
mkdir /test && cd $_ && mount -t nfs $IP:/nfs /test
echo "asdsadsa" >> a.txt
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
