# Ansible 使用向导

这个向导包括 Ansible 怎样工作，包括使用命令行，库存工作（ working with inventory ），编写 playbooks。

[TOC]

## 快速开始

我们录制了一个短的介绍 Ansible 视频。

[视频](https://www.ansible.com/resources/videos/quick-start-video)大约 13 分钟，介绍了 Ansible 怎么使用，也介绍了 Ansible 生态中的其他产品。

浏览其他文档学习更多。

## 开始

### 前言

现在，你阅读了安装向导，并安装上了 Ansible，现在是时候开始使用一些特别的命令了。

我们首先展示的不是 Ansible 强大的配置/部署/编排功能。这些特性由剧本处理，剧本将在单独的部分中介绍。

这个部分是关于怎样初始化 Ansible。一旦你理解这些概念，阅读[命令行介绍](https://docs.ansible.com/ansible/2.7/user_guide/intro_adhoc.html)获取更多的细节，然后你可以开始学习 playbooks 和探索更多有趣的部分。

### 远程连接信息

在开始之前，理解 Ansible 和远程主机怎样通过 SSH 交流的这点是重要的。

默认的，Ansible 将尝试使用原生 OpenSSH 假如远程机器可以使用这个。这个能够ControlPersist（一种性能特性），Kerberos，和`~/.ssh/config`，正如 Jump Host 设置。

然而，当使用 Enterprise Linux 6 操作系统作为控制机器（Red Hat Enterprise Linux 和 CentOS 等衍生工具）时，OpenSSH 版本可能太旧，无法支持 ControlPersist。在这些操作系统上，Ansible 将退回到使用高质量的 Python 实现的 OpenSSH paramiko。如果您希望使用 SSH 支持 Kerberized 等特性，可以考虑使用 Fedora、macOS 或 Ubuntu 作为您的控制机器，直到您的平台上出现了新的 OpenSSH 版本。

偶尔会遇到不支持 SFTP 的设备。这种情况很少见，但是如果出现这种情况，您可以在配置 Ansible 时使用 SCP 模式。 

当和远程机器交流时，Ansible 默认确认你是使用 SSH keys 的方式。SSH keys 的方式被鼓励使用，但是也可以通过 `–ask-pass` 提供密码。假如使用 `sudo`，并且也需要密码，可以通过 `--ask-become-pass`提供。

> 注意：在使用 ssh 连接时，Ansible 不公开允许用户和 ssh 进程之间的通信的通道来手动接受密码和解密 ssh 密钥。强烈建议使用 ssh-agent。

虽然这可能是常识，但值得分享：任何管理系统都应该在被管理的机器附近运行。如果您在云中运行 Ansible，可以考虑在云中运行控制机。在大多数情况下，这比在开放的互联网上运行更好。

作为一个高级主题 ，Ansible 不仅仅只能使用 SSH。传输是可插拔（ pluggable ）的，可以选择在本地管理事情，正如管理 chroot、lxc 和 jail 容器。一种称为 `ansible-pull` 的模式也可以反选（revert）系统，并通过预定的 git 检出让系统通过 phone hom 从中央存储库获取配置指令。 

### 你的第一个命令

现在你已经安装好 Ansible，是时候开始一些基础了。

编辑 `/etc/ansible/hosts`，然后放一个或者多个主机到这个文件内。你的 SSH keys 应该在 `authorized_keys`内：

```ini
192.0.2.50
aserver.example.org
bserver.example.org
```

这是一个仓库文件，这里有更深入的解释： [Working with Inventory](https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html)。

我们确认你使用 SSH keys 认证，为了避免启动 SSH 时输入密码，你可以：

```bash
$ ssh-agent bash
$ ssh-add ~/.ssh/id_rsa
```

根据您的设置，您可以使用`--private-key`选项来指定 pem 文件。

现在 `ping` 你的所有节点：

```bash
ansible all -m ping
```

Ansible 将尝试使用您当前的用户名远程连接到机器，就像 SSH 一样。要覆盖远程用户名，只需使用`-u`参数。 

假如你需要接入 `sudo` 模式，你可以：

```bash
# as bruce
$ ansible all -m ping -u bruce
# as bruce, sudoing to root
$ ansible all -m ping -u bruce --sudo
# as bruce, sudoing to batman
$ ansible all -m ping -u bruce --sudo --sudo-user batman

# With latest version of ansible `sudo` is deprecated so use become
# as bruce, sudoing to root
$ ansible all -m ping -u bruce -b
# as bruce, sudoing to batman
$ ansible all -m ping -u bruce -b --become-user batman
```

现在运行其他命令在你的所有节点上：

```bash 
ansible all -a "/bin/echo hello"
```

恭喜，刚刚你通过 Ansible 联系到了你的节点。在[ Ad-Hoc 命令](https://docs.ansible.com/ansible/2.7/user_guide/intro_adhoc.html)中有更多的实际案例，探索如何使用不同的模块，以及学习如何使用 Playbooks 语言。Ansible 不仅仅是运行命令，它还有强大的配置管理和部署功能。还有更多功能需要探索。

> 提示：当运行一个命令，你可以指定本地服务器通过 `localhost`或`127.0.0.1`。

例如：

```bash
ansible localhost -m ping -e 'ansible_python_interpreter="/usr/bin/env python"'
```

你可以在仓库文件中明确的指定 localhost：

```ini
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python"
```

### 主机密钥检查

Ansible 主机密钥检查默认开启。

假如一台主机重新安装，并且拥有一个不同的密钥，这将导致一个错误发送。假如一台主机不在`known_hosts`中，将会导致提示密钥信息，并且需要交互。你可能不想要这样。

假如你理解这个含义并且希望关闭这个行为，你可以编辑 `/etc/ansible/ansible.cfg`或`!/.ansible.cfg`：

```ini
[defaults]
host_key_checking = False
```

另外也可以使用环境变量 `ANSIBLE_HOST_KEY_CHECKING`：

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

注意主机密钥检查在 paramiko 模式下是非常慢的，因此 SSH 时推荐使用这个特性。

Ansible 将记录一些关于远程主机模块参数的信息到远程 syslog 中。企业用户可能对 [Ansible Tower](https://docs.ansible.com/ansible/2.7/reference_appendices/tower.html#ansible-tower) 感兴趣。Tower 提供了一个非常健壮的数据库日志记录功能，可以根据主机、项目和特定的库存随时间查看，可通过图形化和通过 REST API 进行查询。

## 命令行工具

### ansible

针对一组主机定义并运行单个任务剧本 。

#### 语法

```bash
ansible <host-pattern> [options]
```

#### 描述

是一个非常简单的工具/框架/API 来做“远程的事情”。这个命令允许您对一组主机定义和运行一个任务“剧本”。

#### 选项

- `--ask-vault-pass`：询问密码
- `` `--become-method`` ` ： 使用权限升级方法（默认 sudo），有效选择:[sudo | su | pbrun | pfexec | doas | dzdo | ksu | runas | pmrun | enable | machinectl ]
- ` --become-user`：成为的用户（默认 root）
- `--list-hosts`：列出匹配的主机
- ` --playbook-dir`：这个工具不使用剧本，使用它作为一个替代剧本的目录。这为许多特性（包括角色/  group_vars /等）设置了相对路径
- `--private-key, --key-file`：SSH key 文件
- ` --scp-extra-args`：scp 额外参数
- `--sftp-extra-args`：sftp 额外参数
- `--ssh-common-args`：指定 SSH/SCP/SFTP 参数
- `--ssh-extra-args`：SSH 额外参数
- `--systax-check`：语法检查，不会执行
- `--vault-id`：认证使用
- ` --vault-password-file`：认证密码文件
- `-B , –backgroud`：异步，在 X 秒后失败（默认 N/A）
- `-C, --check`：模拟运行，不会真正执行
- `-b, --become`：改变用户
- `-T, --timeout`：执行超时时间
- `-f, --forks`：指定并行数（默认 5）
- `-k, --ask-pass`：询问密码
- `-i,--inventory`：hosts 文件路径
- `-u,--user`：使用的用户
- `-v,-vvv, -vvvv`：详细输出模式

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-config

查看 ansible 的配置。

#### 语法

```bash
ansible-config [view|dump|list] [--help] [options] [ansible.cfg]
```

#### 选项

- `-c, --config`：配置文件路径

#### 动作

##### view

显示现在的配置文件。

##### dump

合并 ansible.cfg 显示现在的设置 。假如指定 `--only-changed`，只显示改变的配置。

##### list

列出当前所有读取 lib/constants.py 的配置，并显示环境和配置文件名称

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-console

执行 Ansble 任务的 REPL 控制台。

#### 语法

```bash
ansible-console [<host-pattern>] [options]
```

一种允许对选定的仓库运行特定任务的 REPL。 

#### 选项

- `–become-user`：变成的用户（默认 root）
- `--list-hosts`：列出匹配的主机
- …

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-doc

文档工具。

#### 语法

```bash
ansible-doc [-l|-F|-s] [options] [-t <plugin type> ] [plugin]
```

显示安装在 Ansible 库中的模块信息。它显示插件及其简短描述的简短列表，提供插件文档字符串的打印输出，还可以创建一个可以粘贴到 playbook 中的简短代码片段。 

#### 选项

- `-l, --list`：显示可以用的文档
- `-s,--snippet`：显示 playbook 片段
- `-v,-vvv.-vvvv`：详细输出
- …

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-galaxy

执行各种角色相关的操作。 

#### 语法

```bash
ansible-galaxy [delete|import|info|init|install|list|login|remove|search|setup] [--help] [options] ...
```

#### 选项

- `--list`：列出所有
- `-c,--ignore-certs`：忽略证书认证错误

#### 动作

##### delete

删除一个从 Ansible Galaxy 下载的角色

##### import 

- `--branch`：导入的分支
- `--role-name`：角色名字
- `--status`：检查给定 github_user/github_repo 的最新导入请求的状态

##### info

打印关于已安装角色的详细信息。

- `-p,--roles-path`：包含角色的路径

##### init

创建符合 galaxy 元数据格式的角色的框架。

- `--type`：初始化类型。可用：container，apb，network
- `-f,--force`：覆盖已存在的角色

##### install

使用要安装的角色的 args 列表，除非指定了`-f`。 角色列表可以是一个名称（将通过 galaxy API 和 github下载），也可以是一个本地`.tar.gz`文件。

- `-f,--force`：覆盖已存在的角色
- `-i,--ignore-errors`：忽略错误
- `-r,--role-file`：导入角色

##### list

列出本地系统上的角色。 

- `-p,--role-path`：角色文件夹路径

##### login

通过 Github 验证用户的身份，并从 Ansible Galaxy 获取认证令牌。 

##### remove

从本地系统中删除角色。 

##### search

搜索 Ansible Galaxy 服务器上的角色。

##### setup

从 Github 或 Travis 为 Ansible Galaxy 角色设置集成。 

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-inventory

#### 语法

```bash
ansible-inventory [options] [host|group]
```

用于在 Ansible 显示或转储配置的主机。

#### 选项

- `--graph`：以图形显示
- `--host`：输出当前主机信息
- `--list`：输出所有主机信息
- `-y,--yaml`：使用 yaml 格式（默认 Json）

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-playbook

运行 Ansible 剧本，在目标主机上执行定义的任务。 

#### 语法

```bash
ansible-playbook [options] playbook.yml [playbook2 ...]
```

#### 选项

- `--list-hosts`：列出匹配主机
- `--list-tags`：列出所有 tags
- `--list-tasks`：列出所有将执行的任务
- `--force-handlers`：强制执行 handlers
- `--skip-tags`： 只运行不匹配的 tag 的剧本和任务 
- `--syntax-check`：语法检查
- `-C,--check`：模拟执行
- `-b,--become`：变成用户
- `-t,--tags`：只运行匹配的 tag 的剧本和任务 

#### 环境

下列环境变量可以指定。

`ANSIBLE_CONFIG`-- 覆盖默认的配置文件。

ansible.cfg 中的大多数选项都提供了环境变量。

#### 文件

 `/etc/ansible/ansible.cfg`：全局配置文件

`~/.ansible.cfg`：配置文件，覆盖全局配置文件

### ansible-pull

从 VCS repo 获取剧本并在本地主机执行剧本。

#### 语法

```bash
ansible-pull -U <repository> [options] [<playbook.yml>]
```

#### 描述

用于在每个托管节点上启动 ansible 的远程副本，每个副本为 cron 运行，并通过源存储库更新 playbook 源。这将把 ansible 默认的推架构（push）转化为拉架构（pull），拥有无限的扩展潜力。

可以对剧本进行调优，将 cron 频率、日志记录位置和参数更改为可调。这对于极端扩展和定期修复都很有用。使用`fetch`模块对 ansible-pull 收集的日志，分析来自 ansible-pull 的远程日志是一种很好的方法。

…

### ansible-vault

解密、加密 Ansible 数据文件。

#### 语法

```bash
ansible-vault [create|decrypt|edit|encrypt|encrypt_string|rekey|view] [options] [vaultfile.yml]
```

#### 描述

可以加密Ansible 使用的任何结构化数据文件 。包括 group_vars、host_vars、inventory 变量、include_vars、vars_files 加载的变量，或通过`-e @file.yml`传递到`ansibl-playbook`命令行的变量文件。角色变量和默认值也包括在内。

由于 Ansible 任务、handlers 和其他对象都是数据，所以它们也可以用 vault 加密。如果不想公开使用的变量，可以对单个任务文件进行加密。

对于所有希望同时使用的文件，当前 vault 使用的密码必须相同。

…

## 命令介绍

这里有一些例子显示了怎么使用 ansible。

什么是 ad-hoc 命令？

一个 ad-hoc 命令是你可能快速输入它，但是不会保存的命令。

在学习剧本之前，这是一个了解 Ansible 可以做什么的好方法，ad-hoc 命令也可以在不想写 playbook 时使用。

通常来说，真正的力量来自于剧本。为什么要使用 ad-hoc 而不是剧本呢？

例如，假如你想关闭你的电脑，你可以快速执行单行指令而不是剧本。

对于配置管理和部署，你将想去使用 `ansible-playbook`， 您在这里学习的概念将直接移植到 playbook。

###  并行和 shell 命令

让我们使用 Ansible 命令行工具来重新启动亚特兰大的所有 web 服务器，每次 10 个。首先，设置 SSH-agent，以便它能够记住我们的凭证。

```bash
$ ssh-agent bash
$ ssh-add ~/.ssh/id_rsa
```

假如你不想使用 ssh-agent，而想使用密码代替密钥，你可以通过`–ask-pass`，但是使用 ssh-agent 是更好的选择。

现在我们运行命令在这个组的所有服务器上，在这个例子，*atlanta*，10 个并行：

```bash
ansible atlanta -a "/sbin/reboot" -f 10
```

Ansible 默认在远程主机上使用和你执行这条命令的用户一样的用户，假如你需要其他用户，通过`-u`指令：

```bash
ansible atlanta -a "/usr/bin/foo" -u username
```

假如你需要升级权限：

```bash
ansible atlanta -a "/usr/bin/foo" -u username --become [--ask-become-pass]
```

使用 `--ask-become-pass`假如你想自己手输密码。

他也可以指定选择要成为的用户，不一定是 root：

```bash
ansible atlanta -a "/usr/bin/foo" -u username --become --become-user otheruser [--ask-become-pass]
```

这些都是基础知识。如果您还没有阅读过有关模式和组的内容，那么请阅读与[模式](https://docs.ansible.com/ansible/2.7/user_guide/intro_patterns.html#intro-patterns)相关的内容。

`-f 10`是指使用是个并行的程序。你也可以在配置文件中设置，避免重复设置。默认值是 5，它是小的和保守的。你可能想要同时更多的主机执行，你可以设置它。您可以地将这个值提升到您的系统所能处理的最高水平 。

你可以选择你想运行的模块。通常使用`-m`指定模块，但是默认的模块名是`command`，所以我们不需要一直指定它。在后面的示例中，我们将使用`-m`来运行一些经常使用的模块的操作。 

> 注意：命令模块不支持扩展的 shell 语法，比如管道和重定向（尽管 shell 变量总是可以工作）。如果您的命令需要 shell 特定的语法，那么可以使用 shell 模块。 

使用 shell 模块：

```bash
ansible raleigh -m shell -a 'echo $TERM'
```

当使用 Ansible ad-hoc CLI(而不是 playbook)运行任何命令时，要特别注意 shell 引用规则，这样本地 shell 在传递给 Ansible 之前不会吃掉变量。例如，在上面的例子中使用双引号而不是单引号来计算您所在引号中的变量。 

### 文件传输

Ansible 能 SCP 文件到多个远程机器。

传输文件路径到多个机器：

```bash
ansible atlanta -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

如果您使用 playbook，您还可以利用`template`模块，这又向前迈进了一步。

`file`模块可以修改属主和文件权限。 这些相同的选项也可以直接传递给`copy`模块：

```bash
$ ansible webservers -m file -a "dest=/srv/foo/a.txt mode=600"
$ ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"
```

`file`也可以创建文件夹：

```bash
ansible webservers -m file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"
```

递归删除文件夹和文件：

```bash
ansible webservers -m file -a "dest=/path/to/c state=absent"
```

### 包管理

包管理模块有 yum 和 apt。这里有 yum 的例子：

确保包安装，但是不升级它：

```bash
ansible webservers -m yum -a "name=acme state=present"
```

确保安装软件的指定的版本：

```bash
ansible webservers -m yum -a "name=acme-1.5 state=present"
```

确保在最新版本：

```bash
ansible webservers -m yum -a "name=acme state=latest"
```

确保包未安装：

```bash
ansible webservers -m yum -a "name=acme state=absent"
```

Ansible 有许多平台下管理软件包的模块。如果没有用于包管理器的模块，可以使用 `command`模块安装包。

### 用户和组

`user`允许创建和控制用户账户，也可以移除用户：

```bash 
$ ansible all -m user -a "name=foo password=<crypted password here>"

$ ansible all -m user -a "name=foo state=absent"
```

### 从源中部署

部署 webapp 从 git：

```bash
ansible webservers -m git -a "repo=https://foo.example.org/repo.git dest=/srv/myapp version=HEAD"
```

由于 Ansible 模块可以通知变更处理程序，所以当代码更新时，可以告诉 Ansible 运行特定的任务，比如直接从 git 部署 Perl/Python/PHP/Ruby，然后重新启动 apache。

### 管理服务

确保所有 webserver 服务启动：

```bash
ansible webservers -m service -a "name=httpd state=started"
```

重启所有服务：

```bash
ansible webservers -m service -a "name=httpd state=restarted"
```

停止服务：

```bash
ansible webservers -m service -a "name=httpd state=stopped"
```

### 后台操作时间限制

一个耗时长的应用可以运行在后台，然后在一段时间之后检查它的状态。例如，执行`long_running_operation` 在后台异步运行，超时时间为 3600 秒（-B），同时没有轮询（-P）：

```bash
ansible all -B 3600 -P 0 -a "/usr/bin/long_running_operation --do-stuff"
```

假如你想之后再检查任务的状态，你可以使用 `async_status` 模块，当你运行原始的任务后，将任务 id 传递给它：

```bash
ansible web1.example.com -m async_status -a "jid=488359678239.2844"
```

轮询是内置的：

```bash
ansible all -B 1800 -P 60 -a "/usr/bin/long_running_operation --do-stuff"
```

上面的例子说运行最多 30 分钟(-B 30*60=1800)，每 60 秒轮询一次状态(-P)。 

轮询模式是智能的，所以所有任务将在轮询开始之前开始。设置足够高的`--forks`值来保证所有任务快速启动。在超时之后（-B），所有任务将被远程机器终止。

通常，您只需要后台运行长时间的 shell 命令或软件升级。`copy`模块不能在后台传输。playbook 也支持轮询，语法和这边一样简单。

### 收集资料（Gathering Facts）

Facts 代表了系统的一些变量。它们可以用来实现任务的条件执行，也可以用来获取系统的特定信息。你可以这样获得资料：

```bash
ansible all -m setup
```

它也可以过滤输出，详细看 `setup`模块。

## 库存处理（Working with Inventory）

Ansible 同一时间在多个系统工作。它通过选择 Ansible 库存中列出的系统部分来做到这一点，默认存在 `/etc/ansible/hosts`，你也可以通过 `-i` 在命令行指定自己的库存文件。

 不仅库存可以配置，还可以同时使用多个文件和多种格式。

### 主机和组

库存文件可以是多种格式中的一种，这取决于库存插件。 例如，`/etc/ansible/hosts`像 INI 格式：

```ini
mail.example.com

[webservers]
foo.example.com
bar.example.com

[dbservers]
one.example.com
two.example.com
three.example.com
```

括号中的名字是组名，它们对系统进行分类，决定了什么时间或什么意图要使用哪些机器：

```yaml
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
```

可以将系统放在多个组中，例如服务器可以同时是 webserver 和 dbserver。如果这样做，请注意变量将控制它们所属的所有组。可变优先级将在后面的章节中详细介绍。 

如果有运行在非标准 SSH 端口上的主机，则可以将端口号放在主机名后面，并加上冒号。SSH 配置文件中列出的端口将不会与 paramiko 连接一起使用，而是与 openssh 连接一起使用。 

为了使事情清晰，建议你这样设置：

```ini
badwolf.example.com:5309
```

假设您只有静态 ip，并且希望在主机文件中设置一些别名，或者通过隧道进行连接。您还可以通过变量来描述主机：

```ini
jumper ansible_port=5555 ansible_host=192.0.2.50
```

```yaml
...
  hosts:
    jumper:
      ansible_port: 5555
      ansible_host: 192.0.2.50
```

在上面的例子中，尝试 ansible 对主机别名 jumper （它甚至可能不是一个真正的主机名）连接 192.0.2.50:5555。注意，这是使用库存文件的特性来定义一些特殊变量。一般来说，这并不是定义变量的最佳方法，稍后将分享关于这方面的建议。 

> 注意：使用 key=value 语法以 INI 格式传递的值不会被解释为 Python 的文字结构(字符串、数字、元组、列表、字典、布尔值、None)，而是作为字符串。例如，var=FALSE 将创建一个等于 'FALSE' 的字符串。

如果你需要添加相似模式的主机，可以这样：

```ini
[webservers]
www[01:50].example.com
```

对于数字模式，可以包括也可以删除前面的 `0`，范围是包括的（ Ranges are inclusive ）。你可以定义字符范围：

```ini
[databases]
db-[a:f].example.com
```

你可以选择每台主机的连接类型和用户：

```ini
[targets]

localhost              ansible_connection=local
other1.example.com     ansible_connection=ssh        ansible_user=mpdehaan
other2.example.com     ansible_connection=ssh        ansible_user=mdehaan
```

如上所述，在 inventory 文件中设置这些只是一种简化方法，稍后我们将讨论如何将它们存储在`host_vars`目录的文件中。 

### 主机变量

上面描述的，它是容易的去注册主机变量，以便在后续的 playbook 中使用：

```ini
[atlanta]
host1 http_port=80 maxRequestsPerChild=808
host2 http_port=303 maxRequestsPerChild=909
```

### 组变量

变量可以应用到组内的每一个主机。

```ini
[atlanta]
host1
host2

[atlanta:vars]
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com
```

```yaml
atlanta:
  hosts:
    host1:
    host2:
  vars:
    ntp_server: ntp.atlanta.example.com
    proxy: proxy.atlanta.example.com
```

请注意，这只是一次将变量应用到多个主机的方便方法；即使您可以根据组来定位主机，在执行一个剧本之前，**变量总是被应用到每个主机**。

### 组的组，组变量

可以设置组的组，使用`:children`或`children:`，变量使用`:vars`或`vars:`：

```ini
[atlanta]
host1
host2

[raleigh]
host2
host3

[southeast:children]
atlanta
raleigh

[southeast:vars]
some_server=foo.southeast.example.com
halon_system_timeout=30
self_destruct_countdown=60
escape_pods=2

[usa:children]
southeast
northeast
southwest
northwest
```

```yaml
all:
  children:
    usa:
      children:
        southeast:
          children:
            atlanta:
              hosts:
                host1:
                host2:
            raleigh:
              hosts:
                host2:
                host3:
          vars:
            some_server: foo.southeast.example.com
            halon_system_timeout: 30
            self_destruct_countdown: 60
            escape_pods: 2
        northeast:
        northwest:
        southwest:
```

假如你需要存储列表或哈希数据，或者更好的保存主机和组的变量到库存文件。子组需要有几个属性需要注意：

- 任何属于子组的主机都自动成为父组的成员。 
- 子组的变量具有更高的优先级。
- 组可以有多个父组或子组，但是不能循环。
- 主机可以有多个组，合并多个组的数据后，只能有一个主机示例。

### 默认组

有连个默认组，`all`和`ungrouped`。`all`包含所有主机，`ungrouped`包括不在组内的主机。每个主机至少属于两个组。尽管 `all`和`ungrouped`总是存在，但它们是隐性的，不出现在组中。

### 分割主机和组指定的数据

Ansible 的首选做法是不在主库存文件存储变量。 

除了存储变量到库存文件外，主机和组也可以单独存为一个文件。

这些文件使用 YAML 格式。

确定库存文件路径是：

```bash
/etc/ansible/hosts
```

假如有 `foosball`、`raleigh`、`erbservers`组， 以下位置的 YAML 文件中的变量将提供给主机：

```bash
/etc/ansible/group_vars/raleigh # can optionally end in '.yml', '.yaml', or '.json'
/etc/ansible/group_vars/webservers
/etc/ansible/host_vars/foosball
```

例如，假设您有按数据中心分组的主机，并且每个数据中心使用一些不同的服务器。在 groupfile ' /etc/ansible/group_vars/raleigh' 的数据为 'raleigh' 组可能看起来像：

```yaml
---
ntp_server: acme.example.org
database_server: storage.example.org
```

如果文件不存在也可以。

作为高级用法，你可以创建组或主机的目录，Ansible 可以读取文件夹内的所有文件。一个 `raleigh`组的例子：

```bash
/etc/ansible/group_vars/raleigh/db_settings
/etc/ansible/group_vars/raleigh/cluster_settings
```

`raleigh`组中的所有主机都可以使用这些文件中定义的变量。

> 提示：`group_vars`和`host_vars`文件夹可以包含在 playbook 或者库存文件夹内。假如都存在，playbook 文件夹内的变量优先级更高。

### 变量怎么合并

默认的，变量将在 play 运行前合并。这样可以让 Ansible 关注主机和任务，组在匹配主机外不是真正存在。默认情况下，Ansible 会覆盖变量，包括为组和主机定义的变量。优先级(从最低到最高)：

- all
- 父组
- 子组
- 主机

当合并具有相同父/子级别的组时，按字母顺序进行，最后加载的组覆盖前面的组。例如，一个`a_group`将与`b_group`合并，匹配的`b_group`变量将覆盖`a_group`中的变量。

从 Ansible 2.4 版本开始，用户可以使用组变量`ansible_group_priority`来更改相同级别组的合并顺序(在父/子顺序解析之后)。数字越大，合并的时间越晚，优先级越高。如果没有设置，这个变量默认为 1：

```yaml
a_group:
    testvar: a
    ansible_group_priority: 10
b_group：
    testvar: b
```

在本例中，如果两个组具有相同的优先级，那么结果通常是`testvar == b`，但是由于我们给了 a 组更高的优先级，所以结果将是`testvar == a`。 

### 库存参数行为

设置以下变量控制 Ansible 如何与远程主机交互。 

- `asible_host`：主机
- `ansible_port`：端口
- `ansible_user`：用户
- `ansible_ssh_pass`：ssh 密码
- `ansible_become`：提高权限
- `ansible_become_user`：成为的用户（默认 root）
- `ansible_become_pass`：成为的用户的密码
- `andible_shell_type`：shell 类型
- `ansible_python_interpreter`：python 解析器

例子：

```ini
some_host         ansible_port=2222     ansible_user=manager
aws_host          ansible_ssh_private_key_file=/home/example/.ssh/aws.pem
freebsd_host      ansible_python_interpreter=/usr/local/bin/python
ruby_module_host  ansible_ruby_interpreter=/usr/bin/ruby.1.9.3
```

### 非 SSH 连接的类型

 Ansible 通过 SSH 执行剧本，但它不限于这种连接类型。使用主机特定的参数`ansible connection=<connector>`，可以更改连接类型。可以使用以下非基于 ssh 的连接器 

- `local`：主机本身
- `docker`：使用 Docker 客户端，将 playbook 部署到容器中。
  - `asible_host`：Docker 容器名字
  - `ansible_user`：操作容器的用户
  - `ansible_become`：提权
  - `andible_docker_extra_args`：自定义参数

容器的例子：

```yaml
- name: create jenkins container
  docker_container:
    docker_host: myserver.net:4243
    name: my_jenkins
    image: jenkins

- name: add container to inventory
  add_host:
    name: my_jenkins
    ansible_connection: docker
    ansible_docker_extra_args: "--tlsverify --tlscacert=/path/to/ca.pem --tlscert=/path/to/client-cert.pem --tlskey=/path/to/client-key.pem -H=tcp://myserver.net:4243"
    ansible_user: jenkins
  changed_when: false

- name: create directory for ssh keys
  delegate_to: my_jenkins
  file:
    path: "/var/jenkins_home/.ssh/jupiter"
    state: directory
```

<br/>

> [Ansible Quickstart]( https://docs.ansible.com/ansible/2.7/user_guide/quickstart.html )
>
> [Getting Started](https://docs.ansible.com/ansible/2.7/user_guide/intro_getting_started.html#id3)
>
> [Working with Command Line Tools](https://docs.ansible.com/ansible/2.7/user_guide/command_line_tools.html )
>
> [Introduction To Ad-Hoc Commands](https://docs.ansible.com/ansible/2.7/user_guide/intro_adhoc.html#id7)
>
> [Working with Inventory](https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html#id4)