# Kubernetes 集群部署

`kubeadm` 是官方社区推出的一个用于快速部署 kubernetes 集群的工具。

```bash
# 创建一个 Master 节点
kubeadm init

# 将一个 Node 节点加入到当前集群中
kubeadm join <Master 节点的 IP:Port>
```

[TOC]

##  安装要求

部署 Kubernetes 集群机器需要满足以下几个条件：

- 一台或多台机器，操作系统 CentOS 7
- 硬件配置：2GB 及以上，2 个 CPU 及以上，硬盘 30GB 以上
- 集群中所有机器之间网络互通
- 需要访问外网（拉取镜像）
- 禁止 swap

## 安装步骤

- 在所有节点上安装 Docker 和 kubeadm

- 部署 Kubernetes Master

- 部署容器网络插件

- 部署 Kubernetes Node，将节点加入 Kubernetes 集群中

- *部署 Dashboard Web 页面，可视化查看 Kubernetes 资源*

- 集群扩容

## 准备环境

   ```bash
# 关闭防火墙：
$ systemctl stop firewalld
$ systemctl disable firewalld

# 关闭selinux：
$ sed -i 's/enforcing/disabled/' /etc/selinux/config 
$ setenforce 0

## 关闭swap：
# 临时
$ swapoff -a  
# 永久
$ vim /etc/fstab

# 添加主机名与IP对应关系（记得设置主机名）：
$ cat /etc/hosts
192.168.1.2 k8s-master
192.168.1.3 k8s-node1
192.168.1.4 k8s-node2

# 将桥接的 IPv4 流量传递到 iptables 的链：
$ cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
$ sysctl -p
   ```

### 安装 `Docker/kubeadm/kubelet`

Kubernetes 默认 CRI（容器运行时）为 Docker，因此安装 Docker。

#### 安装 `Docker`

```bash
$ wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
$ yum -y install docker-ce
$ systemctl start docker && systemctl enable docker
```

#### 添加阿里云 YUM 软件源

```bash
$ cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

#### 安装 `kubeadm`，`kubelet` 和 `kubectl`

指定版本号部署：

```bash
$ yum install -y kubelet-1.15.2 kubeadm-1.15.2 kubectl-1.15.2
$ systemctl enable kubelet
```

## 部署 Kubernetes Master

在 192.168.1.2（Master）执行。

```bash
$ kubeadm init \
  --apiserver-advertise-address=192.168.1.2 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.15.2 \
  --service-cidr=10.1.0.0/16 \
  --pod-network-cidr=10.244.0.0/16
```

由于默认拉取镜像地址 k8s.gcr.io 国内无法访问，因此使用阿里云镜像仓库地址。

使用 `kubectl` 工具：

```bash
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
$ kubectl get nodes
```

## 安装 Pod 网络插件（CNI）

```bash
$ kubectl apply -f \ https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

# 如果 Kubernetes 的版本为 1.16 及以上，使用这个 Flannel
#kubectl apply -f \ https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

确保能够访问到 quay.io 这个 registery。

## 加入 Kubernetes Node

在 192.168.1.3/4（Node）执行。

向集群添加新节点，执行在 `kubeadm init` 输出的 `kubeadm join` 命令：

```bash
$ kubeadm join 192.168.1.2:6443 --token <Token> --discovery-token-ca-cert-hash sha256:<sha256-cert>
```

## 测试 kubernetes 集群

在 Kubernetes 集群中创建一个 pod，验证是否正常运行：

```bash
$ kubectl create deployment nginx --image=nginx
$ kubectl expose deployment nginx --port=80 --type=NodePort
$ kubectl get pod,svc
```

访问地址：http://NodeIP:Port  

## 部署 Dashboard

```bash
$ kubectl apply -f \ https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
```

默认 Dashboard 只能集群内部访问，修改 Service 为 NodePort 类型，暴露到外部：

```yaml
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001
  selector:
    k8s-app: kubernetes-dashboard
```

```bash
$ kubectl apply -f kubernetes-dashboard.yaml
```

访问地址：http://NodeIP:30001

创建 service account 并绑定默认 cluster-admin 管理员集群角色：

```bash
$ kubectl create serviceaccount dashboard-admin -n kube-system
$ kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
$ kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')
```

使用输出的 token 登录 Dashboard。

> ```yaml
> # 上方 1、2 步的命令对应这一份 YAML
> apiVersion: v1
> kind: ServiceAccount
> metadata: 
>   name: dashboard-admin
>   namespace: kube-system
> 
> ---
> apiVersion: rbac.authorization.k8s.io/v1
> kind: ClusterRoleBinding
> metadata: 
>   name: dashboard-admin
> subjects: 
>   - kind: ServiceAccount
>     name: dashboard-admin
>     namespace: kube-system
> roleRef: 
>   kind: ClusterRole
>   name: cluster-admin
>   apiGroup: rbac.authorization.k8s.io
> ```

## 集群扩容（增加新 Node）

### 创建新 TOKEN

```bash
kubeadm taken create 
# 查看创建的 Token
kubeadm token list
```

### 查看 sha256 加密字符串

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

### Node 加入集群

```bash
kubeadm join --token <TOKEN> 192.168.1.2:6443 --discovery-token-ca-cert-hash sha256:<SHA256>
```

<br/>

> [Kubernetes-集群扩容增加node节点](https://www.jianshu.com/p/748746c696c6)
>
> [flannel](https://github.com/coreos/flannel)


