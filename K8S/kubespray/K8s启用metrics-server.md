# K8s 启用 metrics-server

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server)是一个可伸缩的、高效的容器资源指标源，用于 Kubernetes 内置的自动缩放管道。

Metrics Server 从 Kubelet 收集资源指标，并通过 Metrics API 在 Kubernetes apiserver 中公开，以便 pod 的水平（Horizontal）或垂直（Vertical）扩展。Metrics API 还可以在`kubectl top`中使用，从而更轻松调试自动扩展管道（autoscaling pipelines）。

Metrics Server 提供：

- 在大多数集群上单一部署（deployment）
- 支持 5000 个节点的伸缩
- 资源效率：Metrics Server 每个节点使用 0.5m CPU 核心和 4MB 内存

[TOC]

## 版本适配

| Metrics Server | Metrics API group/version | Kubernetes version |
| -------------- | ------------------------- | ------------------ |
| 0.3.x          | Metrics.k8s.io/v1beta1    | 1.8+               |

## 部署 Metrics Server

部署 metrics server 现在只需要一行命令：

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
```

上述 yaml 脚本将会安装 **metrics-server 的 0.3.7 版本**，但是 image 会从`k8s.gcr.io`下载，所以需要手动修改 image pull 地址。

### 编辑 deploy metrics-server

将 image 从 `k8s.gcr.io/metrics-server/metrics-server:v0.3.7`修改成`registry.cn-shanghai.aliyuncs.com/hsin/metrics-server:v0.3.7`。*此 repo 只有 0.3.7 版本，其他版本请使用其他 repo*

```bash
kubectl edit deploy/metrics-server -n kube-system
```

```yaml
...
spec:
  containers:
  - args:
    - --cert-dir=/tmp
    - --secure-port=4443
    - --kubelet-insecure-tls
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    # 修改此处 image
    image: registry.cn-shanghai.aliyuncs.com/hsin/metrics-server:v0.3.7
    imagePullPolicy: IfNotPresent
    name: metrics-server
...
```

保存退出后，k8s 会自动从新的 repo 拉取镜像并运行。

## 查看

部署成功后，查看是否所有 metrics-server 的 pod 处于 running 状态。

```bash
kubectl get pod -n kube-system
```

查看`kubectl top node`是否有数据。如果执行后，显示**error: metrics not available yet**，则需要再次调整 metrics-server yaml。

```bash
kubectl edit deploy/metrics-server -n kube-system
```

在 *args* 中添加：

```yaml
...
- args:
    - --cert-dir=/tmp
    - --secure-port=4443
    # 添加下面两行
    - --kubelet-insecure-tls
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
...
```

参考：[error: metrics not available yet](https://github.com/kubernetes-sigs/metrics-server/issues/247)

保存退出后，待新 pod 处于 running 状态后，等待片刻，再次执行`kubectl top node`，查看是否有节点的资源信息：

![image-20200802212203811](K8s%E5%90%AF%E7%94%A8metrics-server.assets/image-20200802212203811.png)