# 安装向导

欢迎阅读 Ansible 安装向导。

[TOC]

## 基础 / 什么将被安装

Ansible 默认使用 SSH 协议管理机器。

一旦 Ansible 被安装，它不会添加数据库，也没有守护进程运行。你只需要安装它在一台机器（比如笔记本），然后通过这个中心点管理多个远程机器。当 Ansible 管理远程机器，它不需要安装客户端或者运行客户端，因此，不会有怎么升级 Ansible 的客户端版本的问题。

## 选择什么版本

因为它可以很容易地从源代码运行，并且不需要在远程机器上安装任何软件，所以许多用户会使用开发版本。 

Ansible 的正式版大约 4 个月长。因为周期短，bugs 将会修复将在下个正式版中发布，而不是使用 backports   方式。在必要的时候，主要的 bug 会有维护版本，尽管这种情况不常见。 

假如你希望运行最新的 Ansible，比如在 RedHat，CentOS，Debian 等操作系统，我们推荐使用 OS 的包管理器安装。

对于其他的安装选项，我们推荐使用`pip`，Python 的包管理器，尽管也有其他的选择。

如果您希望使用开发版本，以使用和测试最新的特性，我们将共享关于从源代码运行的信息。没有必要安装程序来从源代码运行。 

## 控制机要求

现在 Ansible 能运行在任何带有 Python2（Version 2.7）或者 Python3（Version 3.5 或者更高）的机器。不支持 Windows 作为控制机。

支持包括 RedHat，Debian，CentOS，macOS，BSDs 等等。

> macOS 默认情况下是配置为少量的文件句柄，所以如果您想使用 15 个或更多的分支，您需要使用`sudo launchctl limit maxfiles unlimited`来提高 ulimit。此命令还可以修复任何打开过多的文件错误。 

> 请注意,一些模块和插件有额外的要求。对于这些模块，需要在目标机器上得到满足,并且应该在模块的文档中列出。

## 管理节点要求

管理节点应该有一种交流方式，比如 SSH。默认情况下使用 sftp。如果不可用的，你可以在ansible.cfg 中切换使用 scp。您还需要 python2（版本 2.6 或更高）或python3（版本 3.5 或更高）。 

> - 假如远程主机开启了 SELinux，你应该安装 libselinux-python，假如你需要使用 copy/file/template 模块。
>
> - 默认的，Ansible 使用 Python 的解析器是 `/usr/bin/python`。然而，一些 Linux 发行版可能只安装 `/usr/bin/python3`，所以可能看见这样的错误：
>
>   ```json
>   "module_stdout": "/bin/sh: /usr/bin/python: No such file or directory\r\n"
>   ```
>
>   你可以设置 `ansible_python_interpreter`变量指示使用的解析器，或者安装 Python2。
>
> - Ansible 的`raw`模块（执行命令快速和不干净（dirty）方式）和 `script`模块不需要 Python 安装。因此，你可以使用 `raw`模块安装 Python，然后使用其他模块。例如，假如你需要在基于红帽的发行版中启动 Python2，你可以通过这样：
>
>   ```bash
>   ansible myhost --sudo -m raw -a "yum install -y python2"
>   ```

## 安装控制机

### 通过 DNF 或 Yum

在 Fedora：

```bash
sudo dnf install ansible
```

在 RHEL 和 CentOS：

```bash
sudo yum install ansible
```

### 通过 Apt（Ubuntu）

Ubuntu 构建在这个 [PPA](https://launchpad.net/~ansible/+archive/ubuntu/ansible)

#### 配置 PPA

```bash
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible
```

### 通过 Apt（Debian）

Debian 可以使用与 Ubuntu PPA 相同的源代码。 

添加下面行到  /etc/apt/sources.list：

```bash
deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
```

然后运行这些命令：

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt-get update
sudo apt-get install ansible
```

### macOS

推荐使用`pip`方式安装。

### 使用 Pip

假如 Pip 未安装，可以通过：

```bash
sudo easy_install pip
```

然后安装 Ansible：

```bash
sudo pip install ansible
```

<br/>

> 有些操作系统安装方法未列出，有需要，请到官方 Docs 查看。

> [Installation Guide](https://docs.ansible.com/ansible/2.7/installation_guide/intro_installation.html)