---
title: cni already has an IP address different from ...
author: Payne
tags:
  - 错误集合
  - Error Set
  - Kubernetes
categories:
  - Error Set
  - 错误集合
  - Kubernetes
abbrlink: 4032605777
date: 2021-08-30 23:20:51
---
  

## 错误如下

cni already has an IP address different from ...

如图所示

![1421630332579_.pic_hd](https://tva1.sinaimg.cn/large/008i3skNgy1gtz8c50ce1j627w0mex5w02.jpg)

## 缘由

node之前反复添加

## 解决方案

```bash
# 找到对应的节点
kubectl get pod --all-namespace -o wide
```

在对应node上执行如下命令

```bash
# 重置Kubernetes集群
kubeadm reset && systemctl stop kubelet && systemctl stop docker
# 删除残留
rm -rf /var/lib/cni/ && rm -rf /var/lib/kubelet/* && rm -rf /etc/cni/
# 删除旧网络
ifconfig cni0 down && ifconfig flannel.1 down && ifconfig docker0 down 
ip link delete cni0 && ip link delete flannel.1
# 重启服务
systemctl restart docker && systemctl start kubelet
```

在master上获取join token

```bash
kubeadm token create --print-join-command
```

重新加入节点

## Reference

https://www.cnblogs.com/wangxu01/articles/11803547.html
