# Kubespray 安装 kubernetes

[Kubespray](https://github.com/kubernetes-sigs/kubespray) 是一个部署生产环境可用的 K8s 集群的工具。

[TOC]

## 优势

- 可以部署在 AWS、GCE、Azure、OpenStack、Vsphere、Packet（裸机）、Oracle 云（试验阶段），裸物理机。
- 高可用集群

- 灵活（可以选择实例的网络插件）
- 支持多种 Linux 发行版
- 持续集成测试

## 需求

- 支持 kubernetes v1.16 之上版本
- 在运行 Ansible 的机器上需要安装 **Ansible v2.9+, Jinja 2.11+ 和 python-netaddr**
- 服务器需要接入网络
- 服务器需要配置允许 **IPV4 转发**
- 服务器需要允许 ansible 主机通过 SSH Key 登录
- 需要自己配置防火墙。*建议暂时关闭防火墙*
- 如果服务器上执行 ansible role 的用户不是 root，应该执行权限升级（privilege escalation ）。通过指定`ansible_become`或`--become`或`-b`。
- 内存要求
  - Master：1500 MB
  - Node：1024 MB

### IPV4 转发

允许 IPV4 转发

```bash
sysctl -w net.ipv4.ip_forward=1
```

### 关闭防火墙

#### Ubuntu

```bash
systemctl stop ufw
```

#### CentOS

```bash
systemctl stop firewalld
```

#### 通用

```bash
iptables -F
```

## 说明

Kubespray 版本：[2.13.2](https://github.com/kubernetes-sigs/kubespray/releases/tag/v2.13.2)。

服务器配置及部署组件：

|             | 配置  | Master | Node   |
| ----------- | ----- | ------ | ------ |
| 192.168.1.2 | 4C+8G | Master | Node 1 |
| 192.168.1.3 | 2C+6G |        | Node 2 |
| 192.168.1.4 | 2C+6G |        | Node 3 |

## 使用

**在 Ansible 主机执行操作。**

### 下载

```
wget https://github.com/kubernetes-sigs/kubespray/archive/v2.13.2.tar.gz
tar zxvf v2.13.2.tar.gz
mv kubespray-2.13.2 kubespray
cd kubespray
```

### Python 虚拟环境

```bash
python3 -m venv .venv
# 进入虚拟环境
source .venv/bin/activate
```

### 安装依赖

```bash
pip install -r requirements.txt
```

### 拷贝 inventory

```bash
cp -rfp inventory/sample inventory/mycluster
```

### 更新主机信息

```bash
declare -a IPS=(192.168.1.2 192.168.1.3 192.168.1.4)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

### 调整 inventory 内的 hosts 信息

默认 Master 节点会配置两个，因为测试环境，因此保留一个即可。可按照自己需求保留两个或减少至一个。

`vim inventory/mycluster/hosts.yaml `

```yaml
...
kube-master:
      hosts:
        # 此处保留了一个
        node1:
        #node2:
kube-node:
...
```

### 调整 docker 镜像地址

`k8s.gcr.io`, `quay.io`, `hub.docker.com`三个地址需要调整到国内镜像。

`vim inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml`

```yaml
...
### 找到此处，修改并新增变量
## 变更
# kubernetes image repo define
kube_image_repo: "registry.cn-shanghai.aliyuncs.com/hsin"
## 新增
# gcr 地址，适用 kubespray:2.13.2
# 其他版本需要自己另寻可用 repo 地址
gcr_image_repo: "registry.cn-shanghai.aliyuncs.com/hsin"
# docker hub 国内镜像，建议使用阿里云镜像加速服务
docker_image_repo: "1nj0zren.mirror.aliyuncs.com"
# quay 国内可用地址，中科大提供
quay_image_repo: "quay.mirrors.ustc.edu.cn"
# 下载 docker 的国内源。此处为 Ubuntu，其他发行版请看附加
docker_ubuntu_repo_base_url: "http://mirrors.aliyun.com/docker-ce/linux/ubuntu"
docker_ubuntu_repo_gpgkey: "http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg"
...
```

附加：[离线环境](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/offline-environment.md)

### 执行

如果远程用户不是 root，使用`--become`, `--become-user`提权。

```bash
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
```

等待 ansible 执行完成：

![image-20200801220229507](Kubespray%E5%AE%89%E8%A3%85kubernetes.assets/image-20200801220229507.png)

## Mac 远程访问远程 K8s 集群

### 安装`kubectl`工具

```bash
brew install kubectl
```

### 添加 kube 配置

将 Master 上的`/root/.kube/config`内的内容添加到本机的`~/.kube/config`中。

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: xxxxxx
    server: https://192.168.1.2:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: xxxxxx
    client-key-data: xxxxxx
```

### 设置`Oh~my~zsh`命令提示和自动补全

在`.zshrc`的`plugins=()`中添加`kubectl`。完整示例：`plugins=(kubectl)`

### 重载`.zshrc`

```bash
source ~/.zshrc
```

## 测试

### 查看 k8s 的版本

```bash
kubectl version
```

![image-20200801222759031](Kubespray%E5%AE%89%E8%A3%85kubernetes.assets/image-20200801222759031.png)

### 新建一个 deploy

```bash
kubectl create deployment --image=nginx nginx
```

### 查看 pod

```bash
kubectl get pod
```

> [kubespray](https://github.com/kubernetes-sigs/kubespray#requirements)
>
> [安装并配置 kubectl](https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/)