---
title: kubernetes搭建dashboard
author: Payne
tags:
  - Kubernetes
  - docker
  - 容器编排
  - 部署
categories:
  - - Kubernetes
    - docker
abbrlink: 1529878275
date: 2021-08-30 19:38:42
---

当部署完Kubernetes集群之后，为了便于管理Web UI或许是一种新型且快捷的部署方式。本节将以部署工具helm搭建Kubernetes Dashboard。以及拍坑

helm相关文档：

- [helm](https://helm.sh/zh/docs/)
- [CNCF Helm 项目过程报告](https://www.cncf.io/reports/cncf-helm-project-journey-report/)



## helm初始化

在这里推荐使用Kubernetes dashboard官方的仓库。在helm初始化完成后可使用如下命令进行helm repo初始化

```bash
# add repo
helm repo add kubernetes-dashboard	https://kubernetes.github.io/dashboard/
```

为避免加入的repo非最新，可使用如下命令进行更新

```bash
helm repo update
```

效果如下所示

![image-20210830201834557](https://tva1.sinaimg.cn/large/008i3skNgy1gtz2xowgsrj61di0880wn02.jpg)

### helm安装Kubernetes dashboard

笔者建议使用新的namespace

```bash
# create namespace
Kubernetes create ns monitor
# helm install kubernetes dashboard
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -n monitor
```

输出如下所示

![image-20210830210303410](https://tva1.sinaimg.cn/large/008i3skNgy1gtz47x30vvj627u0k2aj602.jpg)

等待部署完成，查看如下图所示

![image-20210830221157231](https://tva1.sinaimg.cn/large/008i3skNgy1gtz67m63w5j60yc08sdi602.jpg)

#### 修改端口暴露类型

```
kubectl edit -n monitor service kubernetes-dashboard
```

将type：ClusterIP修改为NodePort类型暴露端口，如下所示

![image-20210830221749368](https://tva1.sinaimg.cn/large/008i3skNgy1gtz6dpjcmjj60v20r844s02.jpg)

修改完成后，就可以获得暴露的端口啦，如下

![image-20210830221701538](https://tva1.sinaimg.cn/large/008i3skNgy1gtz6cvz8lmj610809iacr02.jpg)

> 若在云服务器上请开启对应端口，笔者这里为32623

此时访问服务器ip+端口，即可进入登陆页面。如下图所示

> 1. 必须为https://ip:port
>
> 2. 建议使用火狐浏览器

![image-20210830222235151](https://tva1.sinaimg.cn/large/008i3skNgy1gtz6inwfgxj624m0mqq6802.jpg)

至此部署部分已经完成



## 获取token与授权访问

### 获取token

```
# 查看token名称
kubectl get secrets -n monitor | grep kubernetes-dashboard-token
# 查看token详情
kubectl describe secrets -n monitor | grep kubernetes-dashboard-token-你自己的后缀名
```

![image-20210830222534534](https://tva1.sinaimg.cn/large/008i3skNgy1gtz6lrrzogj611001o74u02.jpg)

### 授权

此时我们刚进去界面，发现什么资源都显示不了，是因为dashboard默认的`serviceaccount`并没有权限，所以我们需要给予它授权。

> **注意**：这里直接赋予的是超级管理员权限，如果需要更加细颗粒度的授权，请参照官方的说明
>
> https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md

![image-20210830222709899](https://tva1.sinaimg.cn/large/008i3skNgy1gtz6nfrdq3j62060oktgn02.jpg)



```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  namespace: monitor
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: monitor
```

将以上的yaml文件copy到master服务器上创建即可,当然若您也是使用的monitor 的namespace可直接使用如下命令

```bash
kubectl apply -f https://raw.githubusercontent.com/KubernetersDeployExample/script/main/dashboard/authorization.yaml
```

