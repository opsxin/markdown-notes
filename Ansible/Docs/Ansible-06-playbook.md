# Playbook

playbooks 是 Ansible 的配置，部署，编排语言。它们可以描述您希望远程系统执行的策略，或者 IT 流程中的一组步骤。 

Ansible 模块是你的工作区的工具，playbooks 是你的介绍手册，库存中的主机是你的原始资料。

最基本的，Ansible 可以被用来管理配置，在远程机器上部署。高级一点的，它们可以对涉及滚动更新的多层滚动进行排序，还可以将操作指派给其他主机，与监控服务器和负载平衡器进行交互。 

虽然这里有很多信息，但是没有必要一次学习所有的东西。您可以从一小点开始，随着时间的推移获得更多需要的功能。 

剧本被设计成容易读的，并且是用一种基本的文本语言开发的。有多种方法来管理 playbook 和它们所包含的文件，我们将提供一些建议，以最大限度地使用 Ansible。 

你应该看[例子](https://github.com/ansible/ansible-examples)当你在阅读这些文档的时候。这些例子将最佳实践以及许多不同的概念放在一起。

[TOC]

## 介绍 Playbook

### 关于 Playbooks 

Playbooks 和 ad-hoc 命令模式是完全不同的，playbook 更加强大。

简单地说，playbook 是一个非常简单的配置管理和多机部署系统的基础，不像任何已经存在的系统，它非常适合部署复杂的应用程序。

playbook 可以声明配置，但它们也可以编排任何手动排序过程的步骤，即使不同的步骤必须在特定的机器之间来回切换。它们可以同步或异步地启动任务。

虽然你可以使用 `ansible`运行 ad-hoc 任务，但 playbook 更适合保存在源代码中，用于更新您的配置或确保远程系统的配置符合规范。

### Playbook 例子

Playbook 使用 YAML 语法，它不是一种编程语言或脚本，而是配置或流程的模型。

每个 playbook 由一个或多个 paly 组成。

通过编写包含多个 plays 的 playbook，可以编排多机部署，在 webservers 组中的所有计算机上运行某些步骤，然后在 dbserver 组中运行某些步骤，然后在 webservers 组中返回更多命令，等等。

plays 类似运动。你可以有很多 plays 来影响你的系统，并去做很多事情。你只是定义了一个特定的状态或模型，你可以在不同的时间运行不同的 plays。 

这里有一个 包含一个 play 的 playbooks：

```yaml
- hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf
    notify:
    - restart apache
  - name: ensure apache is running
    service:
      name: httpd
      state: started
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```

包含多个 plays 的 playbooks，你可能有一个 playbook ，它的目标是 web servers，然后是 database servers：

```yaml
---
- hosts: webservers
  remote_user: root

  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

- hosts: databases
  remote_user: root

  tasks:
  - name: ensure postgresql is at the latest version
    yum:
      name: postgresql
      state: latest
  - name: ensure that postgresql is started
    service:
      name: postgresql
      state: started
```

您可以使用此方法在目标主机组、登录到远程服务器的用户名、是否使用 sudo 等之间进行切换。和任务一样，play 也是按照 playbook 中从上到下的顺序运行。

### 基础

#### 主机和用户

对于每个 playbook，你可以选择目标机器和远程用户。

`host`行可以是主机或组或匹配的主机，由冒号分割。`remote_user`：是用户的账户：

```yaml
---
- hosts: webservers
  remote_user: root
```

远程用户也可以在每个任务指定：

```yaml
---
- hosts: webservers
  remote_user: root
  tasks:
    - name: test connection
      ping:
      remote_user: yourname
```

使用另一个用户运行也是可以的：

```yaml
---
- hosts: webservers
  remote_user: yourname
  become: yes
```

你可以使用`become`关键词在任务中指定：

```yaml
---
- hosts: webservers
  remote_user: yourname
  tasks:
    - service:
        name: nginx
        state: started
      become: yes
      become_method: sudo
```

也可以设置成为其他用户：

```yaml
---
- hosts: webservers
  remote_user: yourname
  become: yes
  become_user: postgres
```

使用其他提权方式：

```yaml
---
- hosts: webservers
  remote_user: yourname
  become: yes
  become_method: su
```

如果您需要为 sudo 指定一个密码，请运行 ansible-playbook，使用`—ask-become-pass`或使用旧的 sudo 语法`–ask-sudo-pass (-K)`。如果您运行了一个成为 playbook，但 playbook 似乎挂起，它可能卡在提权提示的步骤。只需 `Control-C` 杀死它，然后再运行一次，并输入密码。 

> 注意：当对 root 用户以外的用户使用 `become_use` 时，模块参数被写入 /tmp 中的随机 tempfile 中。这些在命令执行后立即删除。这只发生在将用户的权限从`bob`更改为`timmy`时，而不是从`bob`更改为`root`或直接以`bob`或`root`登录时。如果您担心这些数据是可读的(而不是可写的)，请避免使用 become_user 设置来传输未加密的密码。在其他情况下，不使用 /tmp，Ansible 也不记录密码。

您还可以控制主机的运行顺序。默认是库存提供的顺序：

```yaml
- hosts: all
  order: sorted
  gather_facts: False
  tasks:
    - debug:
        var: inventory_hostname
```

可以提供排序的值：

- `inventory`：默认项。库存文件内提供的顺序。
- `reverse_inventory`：库存文件内提供的顺序相反。
- `sorted`：名字按照字母排序。
- `reverse_sorted`
- `shuffle`：随机

#### 任务列表

每个 playbook 都包含一个任务列表。在转移到下一个任务之前，任务是按顺序执行的，一次一个任务，对所有与主机模式匹配的机器执行。在一个剧本中，所有的主机都将获得相同的任务指令。play 的目的是让主机执行任务。 

从上到下运行 playbook 时，如果一个任务失败，则将退出整个 playbook 执行。如果执行失败了，只需修改 playbook 文件并重新运行。 

每个任务的目标是执行一个具有参数的模块。如上所述，变量可以用于模块的参数。

模块应该是幂等的，也就是说，按顺序运行一个模块多次应具有与仅运行一次相同的效果。 实现幂等的一种方法是让模块检查是否已达到其所需的最终状态，如果已经达到该状态，则不执行任何操作即可退出。 如果剧本使用的所有模块都是幂等的，则剧本本身很可能是幂等的，因此重新运行剧本应该是安全的。

`command`和`shell`模块通常会再次重新运行同一命令，如果该命令是诸如`chmod`或`setsebool`等，总的来说可以。尽管有一个`create`标志可用于使这些模块也成为幂等。 

每个任务都应有一个`name`，该名称包含在运行 playbook 的输出中。 这是人类可读的输出，因此提供每个任务步骤的良好描述很有用。 如果未提供名称，则输入到`action`的字符串将用于输出。

可以使用传统动作：`action: module options`，但是建议您使用更传统的模块：`action: options`。  这种推荐的格式在整个文档中都有使用，但是您可能会在一些剧本中遇到旧的格式。 

最基础的任务是像这样的。正如大部分模块， `service`模块使用`key=value`参数：

```yaml
tasks:
  - name: make sure apache is running
    service:
      name: httpd
      state: started
```

`command`和`shell`模块只需要参数列表，而不需要`key=value`格式。

```yaml
tasks:
  - name: enable selinux
    command: /sbin/setenforce 1
```

`command`和`shell`关注返回码，假如你有一个命令希望成功的返回码不是 0， 可以这样：

```yaml
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand || /bin/true
```

或者：

```yaml
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand
    ignore_errors: True
```

如果动作的行太长，你可以用空格和缩进换行：

```yaml
tasks:
  - name: Copy ansible inventory file to client
    copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
            owner=root group=root mode=0644
```

在动作行中可以使用变量。例如在`vars`部分中有`vhost`变量：

```yaml
tasks:
  - name: create a virtual host file for {{ vhost }}
    template:
      src: somefile.j2
      dest: /etc/httpd/conf.d/{{ vhost }}
```

这些相同的变量也可以在模板中使用。

#### 动作简写

Ansible 跟喜欢这种格式：

```yaml
template:
    src: templates/foo.j2
    dest: /etc/foo.conf
```

#### Handler：在变更后执行

正如我们已经提到的，模块应该是幂等的，并且在远程系统上更改后可以继续。 playbook 认识到这一点，并具有可用于响应变化的基本事件系统。

这些`notify` 动作在任务的末尾触发，即使通知了多次，也只触发一次。

例如，多个操作以为配置变更而指定 Apache 需要重启，但是 Apache 只会重启一次，避免不必要的重启。

这里有一个例子，在一个文件内容变更后需要重启两个服务：

```yaml
- name: template configuration file
  template:
    src: template.j2
    dest: /etc/foo.conf
  notify:
     - restart memcached
     - restart apache
```

`notify`处的任务被称为 handlers。

Handlers 是任务的列表，和常规任务没有什么区别，这里引用全局唯一名字，并由通知程序通知。假如 handler 没有被通知，它就不会运行。 **不管有多少任务通知 handler，在一个 play 中的所有任务完成之后，它都只运行一次**。 

```yaml
handlers:
    - name: restart memcached
      service:
        name: memcached
        state: restarted
    - name: restart apache
      service:
        name: apache
        state: restarted
```

从 Ansible 2.2 开始，handler 还可以监听通用任务，任务可以像下面这样通知 handler：

```yaml
handlers:
    - name: restart memcached
      service:
        name: memcached
        state: restarted
      listen: "restart web services"
    - name: restart apache
      service:
        name: apache
        state:restarted
      listen: "restart web services"

tasks:
    - name: restart everything
      command: echo "this task will restart the web services"
      notify: "restart web services"
```

 这样可以容易的触发多个 handler。它也将 handler 和它的名字解耦，使它更容易的在整个 playbook 和角色中共享。

> 注意：
>
> - Notify handler 总是按照定义它们的顺序运行，而不是按照 Notify -statement 中列出的顺序。使用 listen 的 handler 也是如此。 
> -  handler 名字和 listen 名字保存在全局命名空间中。
> -  假如两个 handler 名字相同，只有一个运行。
> -  不能通知在 include 中定义的 handler。 

角色将在之后讲，但是值得指出的是：

- 在每个`pre_tasks`，`tasks`，`post_tasks`末尾部分，handler 通知将会自动刷新。
- 在`roles`部分中通知的 handler 将在任务末尾自动刷新，但在所有 handler 之前。

假如你希望马上处理所有 handler：

```yaml
tasks:
   - shell: some tasks go here
   - meta: flush_handlers
   - shell: some other tasks
```

在上面的例子中，当到达`meta`语句时，任何排队的 handler 都会被提前处理。

#### 执行 playbook

使用 10 个并行进程：

```bash
ansible-playbook playbook.yml -f 10
```

#### 提示和技巧

使用`--syntax-check`检查语法。使用`--verbose`展示详细的输出。

```bash
ansible-playbook playbook.yml --list-hosts
```

## 创建可重用的 playbooks

虽然可以将 playbook 编写成一个大文件，但最终您需要重用文件部分的内容。在 Ansible，有三种方法可以做到这一点：includes，imports， roles。

Include 和 import 允许将一个大文件切分成小文件，小文件可以跨多个父 Playbook 使用，甚至可以在同一个 Playbook 中多次使用。 

角色不仅允许将任务打包在一起，还可以包含变量、handler、甚至模块和其他插件。

### 动态和静态

Ansible 有两种方式操作可重用内容：dynamic and static。

在 Ansible 2.0 中，引入了动态包含的概念。 由于这种方式动态 include 存在一些限制，因此 Ansible 2.1 中引入了强制 include  静态的能力。 由于 include 任务可以包含静态和动态语法，并且 include 的默认行为可能会根据 Task 上设置的其他选项而改变，因此 Ansible 2.4 引入了 include vs. import 的概念。

如果您使用任何`import*` 任务（`import_playbook`、`import_tasks`等），它是静态的。如果您使用任何`include* ` 任务（`include_tasks`、`include_role`等），它是动态的。

`include`现在也是可用的，但是将被弃用。

### 动态和静态的区别

两种操作模式非常简单：

- 在 playbook 解析时，Ansible 预处理所有静态导入（static imports）
- 动态包含（dynamic include）是在运行时遇到任务时处理的

当 Ansible 任务遇到 `tags`和`when`选项时：

- 对于静态 import，父任务的选项将复制到子任务
- 对于动态 include，任务选项只在评估动态任务时适用，并且不会拷贝到子任务

> 注意：角色是比较特殊的情况。在 Ansible 2.3 之前，角色总是通过特殊角色静态地包括：一个给定的 play 选项，总是在任何其他 play 任务之前执行(除非使用 pre_tasks)。角色仍然可以这样使用，但是，Ansible 2.3 引入了 include role 选项，允许角色与其他任务内联执行。 

### include 和 import 之间的折中和陷阱

使用`include*` ，`import*`有一些优点，也有一些折衷，用户在选择使用它们时应该加以考虑：

使用`include*`语句的主要优点在循环。当循环与`include`一起使用时，include 的任务或角色将对循环中的每个项执行一次。 

使用 include* 相比较 import* 有一些限制：

- 只存在于动态 include 中的标记不会出现在`—list-tags`输出中。 
- 只存在于动态 include 中的任务不会出现在`—list-tasks`输出中。 
- 当来自于动态 include，不能使用`notify`触发 handler
- 不能使用`——start-at-task`在动态 include 中开始执行任务。 

使用 import* 相比较 include* 有一些限制：

- 循环不能使用 import
- 将变量用作目标文件或角色名称时，无法使用清单资源（主机/组变量等）中的变量。

> 注意：动态任务使用`notify`仍然可以触发动态 include 本身，这将导致运行 include  中的所有任务。 

## 变量

自动化的存在使事情更容易重复，但所有系统不一定相同，有的配置可能和其他的不同。在一些情况下，系统的行为或状态可能影响到配置其他系统。例如，你可能需要查找系统的 IP，然后把它作为值配置在另一个系统。

Ansible 使用变量处理系统间的不同。

为了理解变量，你需要阅读[条件](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_conditionals.html#playbooks-conditionals)和[循环](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_loops.html#playbooks-loops)。在管理不同系统之间，`group_by`和`when`也可以和变量一起使用。

### 命名

变量以字母开始，后续为字母、数字、下划线组成。

`foo_port`和`foo5`是正确的命名。

`foo-port`，`foo bar`，`foo.port`，`12`都是错误的命名。

YAML 也支持字典：

```yaml
foo:
  field1: one
  field2: two
```

你可以引用指定的字典字段，通过`[]`和`.`：

```yaml
foo['field1']
foo.field1
```

关键字：

 `add`, `append`, `as_integer_ratio`, `bit_length`, `capitalize`, `center`, `clear`, `conjugate`, `copy`, `count`, `decode`, `denominator`, `difference`, `difference_update`, `discard`, `encode`, `endswith`, `expandtabs`, `extend`, `find`, `format`, `fromhex`, `fromkeys`, `get`, `has_key`, `hex`, `imag`, `index`, `insert`, `intersection`, `intersection_update`, `isalnum`, `isalpha`, `isdecimal`, `isdigit`, `isdisjoint`, `is_integer`, `islower`, `isnumeric`, `isspace`, `issubset`, `issuperset`, `istitle`, `isupper`, `items`, `iteritems`, `iterkeys`, `itervalues`, `join`, `keys`, `ljust`, `lower`, `lstrip`, `numerator`, `partition`, `pop`, `popitem`, `real`, `remove`, `replace`, `reverse`, `rfind`, `rindex`, `rjust`, `rpartition`, `rsplit`, `rstrip`, `setdefault`, `sort`, `split`, `splitlines`, `startswith`, `strip`, `swapcase`, `symmetric_difference`, `symmetric_difference_update`, `title`, `translate`, `union`, `update`, `upper`, `values`, `viewitems`, `viewkeys`, `viewvalues`, `zfill`. 

### 在库存中定义变量

 [Working with Inventory](https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html#intro-inventory) 。

### 在 playbook 中定义变量

```yaml
- hosts: webservers
  vars:
    http_port: 80
```

它是非常好的在阅读 playbook 的时候。

### Jinja2 使用变量

一旦你定义了变量，就可以在 Jinja2 中使用：

```jinja2
My amp goes to {{ max_amp_value }}
```

这个提供了最简单的变量替换。

你可以在 playbook 使用相同的语法：

```yaml
template: src=foo.cfg.j2 dest={{ remote_install_path }}/foo.cfg
```

这里定义了文件的路径，但是不同系统之间可能不同。

在模板中，您可以访问主机范围内的所有变量。 实际上，你还可以读取其他主机的变量。我们稍后将展示如何做到这一点。 

### 注意

YAML 要求`{{ foo }}`开始的值需要使用`“”`包裹。

不正确：

```yaml
- hosts: app_servers
  vars:
      app_path: {{ base_path }}/22
```

正确：

```yaml
- hosts: app_servers
  vars:
       app_path: "{{ base_path }}/22"
```

### 发现系统变量

Facts 是远程系统的信息。你可以发现完整的值通过`ansible_facts`变量，大部分 facts 保存在以 `ansible_`为前缀的变量中，还有一些因为冲突被丢弃。可以通过 [INJECT_FACTS_AS_VARS](https://docs.ansible.com/ansible/2.7/reference_appendices/config.html#inject-facts-as-vars)  设置。

一个例子是发现远程机器的 IP 或系统。

为了看`ansible_facts`的值，可以：

```yaml
- debug: var=ansible_facts
```

获取原始信息：

```yaml
ansible hostname -m setup
```

将返回以下信息：

```json
{
    "ansible_all_ipv4_addresses": [
        "REDACTED IP ADDRESS"
    ],
    "ansible_all_ipv6_addresses": [
        "REDACTED IPV6 ADDRESS"
    ],
    "ansible_apparmor": {
        "status": "disabled"
    },
    "ansible_architecture": "x86_64",
    "ansible_bios_date": "11/28/2013",
    "ansible_bios_version": "4.1.5",
    "ansible_cmdline": {
        "BOOT_IMAGE": "/boot/vmlinuz-3.10.0-862.14.4.el7.x86_64",
        "console": "ttyS0,115200",
        "no_timer_check": true,
        "nofb": true,
        "nomodeset": true,
        "ro": true,
        "root": "LABEL=cloudimg-rootfs",
        "vga": "normal"
    },
    "ansible_date_time": {
        "date": "2018-10-25",
        "day": "25",
        "epoch": "1540469324",
        "hour": "12",
        "iso8601": "2018-10-25T12:08:44Z",
        "iso8601_basic": "20181025T120844109754",
        "iso8601_basic_short": "20181025T120844",
        "iso8601_micro": "2018-10-25T12:08:44.109968Z",
        "minute": "08",
        "month": "10",
        "second": "44",
        "time": "12:08:44",
        "tz": "UTC",
        "tz_offset": "+0000",
        "weekday": "Thursday",
        "weekday_number": "4",
        "weeknumber": "43",
        "year": "2018"
    },
    "ansible_default_ipv4": {
        "address": "REDACTED",
        "alias": "eth0",
        "broadcast": "REDACTED",
        "gateway": "REDACTED",
        "interface": "eth0",
        "macaddress": "REDACTED",
        "mtu": 1500,
        "netmask": "255.255.255.0",
        "network": "REDACTED",
        "type": "ether"
    },
    "ansible_default_ipv6": {},
    "ansible_device_links": {
        "ids": {},
        "labels": {
            "xvda1": [
                "cloudimg-rootfs"
            ],
            "xvdd": [
                "config-2"
            ]
        },
        "masters": {},
        "uuids": {
            "xvda1": [
                "cac81d61-d0f8-4b47-84aa-b48798239164"
            ],
            "xvdd": [
                "2018-10-25-12-05-57-00"
            ]
        }
    },
    "ansible_devices": {
        "xvda": {
            "holders": [],
            "host": "",
            "links": {
                "ids": [],
                "labels": [],
                "masters": [],
                "uuids": []
            },
            "model": null,
            "partitions": {
                "xvda1": {
                    "holders": [],
                    "links": {
                        "ids": [],
                        "labels": [
                            "cloudimg-rootfs"
                        ],
                        "masters": [],
                        "uuids": [
                            "cac81d61-d0f8-4b47-84aa-b48798239164"
                        ]
                    },
                    "sectors": "83883999",
                    "sectorsize": 512,
                    "size": "40.00 GB",
                    "start": "2048",
                    "uuid": "cac81d61-d0f8-4b47-84aa-b48798239164"
                }
            },
            "removable": "0",
            "rotational": "0",
            "sas_address": null,
            "sas_device_handle": null,
            "scheduler_mode": "deadline",
            "sectors": "83886080",
            "sectorsize": "512",
            "size": "40.00 GB",
            "support_discard": "0",
            "vendor": null,
            "virtual": 1
        },
        "xvdd": {
            "holders": [],
            "host": "",
            "links": {
                "ids": [],
                "labels": [
                    "config-2"
                ],
                "masters": [],
                "uuids": [
                    "2018-10-25-12-05-57-00"
                ]
            },
            "model": null,
            "partitions": {},
            "removable": "0",
            "rotational": "0",
            "sas_address": null,
            "sas_device_handle": null,
            "scheduler_mode": "deadline",
            "sectors": "131072",
            "sectorsize": "512",
            "size": "64.00 MB",
            "support_discard": "0",
            "vendor": null,
            "virtual": 1
        },
        "xvde": {
            "holders": [],
            "host": "",
            "links": {
                "ids": [],
                "labels": [],
                "masters": [],
                "uuids": []
            },
            "model": null,
            "partitions": {
                "xvde1": {
                    "holders": [],
                    "links": {
                        "ids": [],
                        "labels": [],
                        "masters": [],
                        "uuids": []
                    },
                    "sectors": "167770112",
                    "sectorsize": 512,
                    "size": "80.00 GB",
                    "start": "2048",
                    "uuid": null
                }
            },
            "removable": "0",
            "rotational": "0",
            "sas_address": null,
            "sas_device_handle": null,
            "scheduler_mode": "deadline",
            "sectors": "167772160",
            "sectorsize": "512",
            "size": "80.00 GB",
            "support_discard": "0",
            "vendor": null,
            "virtual": 1
        }
    },
    "ansible_distribution": "CentOS",
    "ansible_distribution_file_parsed": true,
    "ansible_distribution_file_path": "/etc/redhat-release",
    "ansible_distribution_file_variety": "RedHat",
    "ansible_distribution_major_version": "7",
    "ansible_distribution_release": "Core",
    "ansible_distribution_version": "7.5.1804",
    "ansible_dns": {
        "nameservers": [
            "127.0.0.1"
        ]
    },
    "ansible_domain": "",
    "ansible_effective_group_id": 1000,
    "ansible_effective_user_id": 1000,
    "ansible_env": {
        "HOME": "/home/zuul",
        "LANG": "en_US.UTF-8",
        "LESSOPEN": "||/usr/bin/lesspipe.sh %s",
        "LOGNAME": "zuul",
        "MAIL": "/var/mail/zuul",
        "PATH": "/usr/local/bin:/usr/bin",
        "PWD": "/home/zuul",
        "SELINUX_LEVEL_REQUESTED": "",
        "SELINUX_ROLE_REQUESTED": "",
        "SELINUX_USE_CURRENT_RANGE": "",
        "SHELL": "/bin/bash",
        "SHLVL": "2",
        "SSH_CLIENT": "23.253.245.60 55672 22",
        "SSH_CONNECTION": "23.253.245.60 55672 104.130.127.149 22",
        "USER": "zuul",
        "XDG_RUNTIME_DIR": "/run/user/1000",
        "XDG_SESSION_ID": "1",
        "_": "/usr/bin/python2"
    },
    "ansible_eth0": {
        "active": true,
        "device": "eth0",
        "ipv4": {
            "address": "REDACTED",
            "broadcast": "REDACTED",
            "netmask": "255.255.255.0",
            "network": "REDACTED"
        },
        "ipv6": [
            {
                "address": "REDACTED",
                "prefix": "64",
                "scope": "link"
            }
        ],
        "macaddress": "REDACTED",
        "module": "xen_netfront",
        "mtu": 1500,
        "pciid": "vif-0",
        "promisc": false,
        "type": "ether"
    },
    "ansible_eth1": {
        "active": true,
        "device": "eth1",
        "ipv4": {
            "address": "REDACTED",
            "broadcast": "REDACTED",
            "netmask": "255.255.224.0",
            "network": "REDACTED"
        },
        "ipv6": [
            {
                "address": "REDACTED",
                "prefix": "64",
                "scope": "link"
            }
        ],
        "macaddress": "REDACTED",
        "module": "xen_netfront",
        "mtu": 1500,
        "pciid": "vif-1",
        "promisc": false,
        "type": "ether"
    },
    "ansible_fips": false,
    "ansible_form_factor": "Other",
    "ansible_fqdn": "centos-7-rax-dfw-0003427354",
    "ansible_hostname": "centos-7-rax-dfw-0003427354",
    "ansible_interfaces": [
        "lo",
        "eth1",
        "eth0"
    ],
    "ansible_is_chroot": false,
    "ansible_kernel": "3.10.0-862.14.4.el7.x86_64",
    "ansible_lo": {
        "active": true,
        "device": "lo",
        "ipv4": {
            "address": "127.0.0.1",
            "broadcast": "host",
            "netmask": "255.0.0.0",
            "network": "127.0.0.0"
        },
        "ipv6": [
            {
                "address": "::1",
                "prefix": "128",
                "scope": "host"
            }
        ],
        "mtu": 65536,
        "promisc": false,
        "type": "loopback"
    },
    "ansible_local": {},
    "ansible_lsb": {
        "codename": "Core",
        "description": "CentOS Linux release 7.5.1804 (Core)",
        "id": "CentOS",
        "major_release": "7",
        "release": "7.5.1804"
    },
    "ansible_machine": "x86_64",
    "ansible_machine_id": "2db133253c984c82aef2fafcce6f2bed",
    "ansible_memfree_mb": 7709,
    "ansible_memory_mb": {
        "nocache": {
            "free": 7804,
            "used": 173
        },
        "real": {
            "free": 7709,
            "total": 7977,
            "used": 268
        },
        "swap": {
            "cached": 0,
            "free": 0,
            "total": 0,
            "used": 0
        }
    },
    "ansible_memtotal_mb": 7977,
    "ansible_mounts": [
        {
            "block_available": 7220998,
            "block_size": 4096,
            "block_total": 9817227,
            "block_used": 2596229,
            "device": "/dev/xvda1",
            "fstype": "ext4",
            "inode_available": 10052341,
            "inode_total": 10419200,
            "inode_used": 366859,
            "mount": "/",
            "options": "rw,seclabel,relatime,data=ordered",
            "size_available": 29577207808,
            "size_total": 40211361792,
            "uuid": "cac81d61-d0f8-4b47-84aa-b48798239164"
        },
        {
            "block_available": 0,
            "block_size": 2048,
            "block_total": 252,
            "block_used": 252,
            "device": "/dev/xvdd",
            "fstype": "iso9660",
            "inode_available": 0,
            "inode_total": 0,
            "inode_used": 0,
            "mount": "/mnt/config",
            "options": "ro,relatime,mode=0700",
            "size_available": 0,
            "size_total": 516096,
            "uuid": "2018-10-25-12-05-57-00"
        }
    ],
    "ansible_nodename": "centos-7-rax-dfw-0003427354",
    "ansible_os_family": "RedHat",
    "ansible_pkg_mgr": "yum",
    "ansible_processor": [
        "0",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "1",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "2",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "3",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "4",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "5",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "6",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "7",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz"
    ],
    "ansible_processor_cores": 8,
    "ansible_processor_count": 8,
    "ansible_processor_threads_per_core": 1,
    "ansible_processor_vcpus": 8,
    "ansible_product_name": "HVM domU",
    "ansible_product_serial": "REDACTED",
    "ansible_product_uuid": "REDACTED",
    "ansible_product_version": "4.1.5",
    "ansible_python": {
        "executable": "/usr/bin/python2",
        "has_sslcontext": true,
        "type": "CPython",
        "version": {
            "major": 2,
            "micro": 5,
            "minor": 7,
            "releaselevel": "final",
            "serial": 0
        },
        "version_info": [
            2,
            7,
            5,
            "final",
            0
        ]
    },
    "ansible_python_version": "2.7.5",
    "ansible_real_group_id": 1000,
    "ansible_real_user_id": 1000,
    "ansible_selinux": {
        "config_mode": "enforcing",
        "mode": "enforcing",
        "policyvers": 31,
        "status": "enabled",
        "type": "targeted"
    },
    "ansible_selinux_python_present": true,
    "ansible_service_mgr": "systemd",
    "ansible_ssh_host_key_ecdsa_public": "REDACTED KEY VALUE",
    "ansible_ssh_host_key_ed25519_public": "REDACTED KEY VALUE",
    "ansible_ssh_host_key_rsa_public": "REDACTED KEY VALUE",
    "ansible_swapfree_mb": 0,
    "ansible_swaptotal_mb": 0,
    "ansible_system": "Linux",
    "ansible_system_capabilities": [
        ""
    ],
    "ansible_system_capabilities_enforced": "True",
    "ansible_system_vendor": "Xen",
    "ansible_uptime_seconds": 151,
    "ansible_user_dir": "/home/zuul",
    "ansible_user_gecos": "",
    "ansible_user_gid": 1000,
    "ansible_user_id": "zuul",
    "ansible_user_shell": "/bin/bash",
    "ansible_user_uid": 1000,
    "ansible_userspace_architecture": "x86_64",
    "ansible_userspace_bits": "64",
    "ansible_virtualization_role": "guest",
    "ansible_virtualization_type": "xen",
    "gather_subset": [
        "all"
    ],
    "module_setup": true
}
```

第一块硬盘的 model：

```yaml
{{ ansible_facts['devices']['xvda']['model'] }}
```

主机名：

```yaml
{{ ansible_facts['nodename'] }}
```

Facts 经常在条件（conditionals）语句和模板（templates）中用到。

Facts 还可以创建符合特定条件的动态主机组，看 [Conditionals](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_conditionals.html#playbooks-conditionals) 和  [Importing Modules](https://docs.python.org/3/library/modules.html#modules) 。

### 关闭 facts

```yaml
- hosts: whatever
  gather_facts: no
```

### 本地 facts

假如远程机器有`/etc/ansible/facts.d`文件夹，文件夹内有 Json、INI 等格式的以`.fact`结尾的文件，或者返回 JSON 的可执行文件，它们就是本地 facts。也可以通过 `fact_path`指定文件夹路径。

例如， `/etc/ansible/facts.d/preferences.fact `包含：

```ini
[general]
asdf=1
bar=2
```

则会生成名为`general`，成员为`asdf`和`bar`的变量：

```yaml
ansible <hostname> -m setup -a "filter=ansible_local"
```

你将看到：

```json
"ansible_local": {
        "preferences": {
            "general": {
                "asdf" : "1",
                "bar"  : "2"
            }
        }
 }
```

在 `template/playbook`中使用：

```yaml
{{ ansible_local['preferences']['general']['asdf'] }}
```

本地命名空间可以防止任何用户提供的 fact 覆盖在 playbook 中定义的系统 fact 或变量。 

> 注意：`ansible_local`的 `key` 都将被转化为小写，例如`XYZ=3`，则将是` {{ ansible_local['preferences']['general']['xyz'] }} `。

假如拷贝了一份 fact 到远程主机，如果需要使用，则必须显性再调用 `setup`，或者等下次 play。

```yaml
- hosts: webservers
  tasks:
    - name: create directory for ansible custom facts
      file: state=directory recurse=yes path=/etc/ansible/facts.d
    - name: install custom ipmi fact
      copy: src=ipmi.fact dest=/etc/ansible/facts.d
    - name: re-read facts after adding custom fact
      setup: filter=ansible_local
```

### Ansible 版本

```yaml
"ansible_version": {
    "full": "2.0.0.2",
    "major": 2,
    "minor": 0,
    "revision": 0,
    "string": "2.0.0.2"
}
```

### facts 缓存

一个服务器可以调用连一个服务器的变量：

```yaml
{{ hostvars['asdf.example.com']['ansible_facts']['os_family'] }}
```

在禁用 facts 缓存的情况下，为了做到这一点，Ansible 必须在当前剧本中与 `asdf.example.com`进行了对话，或者在之前 play 中进行了对话。

为了避免这样，Ansible 1.8 允许两个 playbook 之间保存 facts，这个特性需要手动开启。

在拥有数千台主机的大型基础设施中，可以将 facts 缓存配置为每晚运行。一小组服务器的配置可以临时运行，也可以在一天中定期运行。启用了 facts 缓存后，就不需要访问所有服务器来引用变量和有关变量的信息。 

Ansible 支持 `redis`和`jsonfile`缓存插件。

配置 `redis`缓存插件，在`ansible.cfg`：

```ini
[defaults]
gathering = smart
fact_caching = redis
fact_caching_timeout = 86400
# seconds
```

现在不支持redis 的 port 和 password 配置

jsonfile：

```ini
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /path/to/cachedir
fact_caching_timeout = 86400
# seconds
```

### 注册变量

变量的另一个主要用途是运行命令并将该命令的结果注册为变量。

任务的值将被保存为变量，并在之后使用。

```yaml
- hosts: web_servers

  tasks:

     - shell: /usr/bin/foo
       register: foo_result
       ignore_errors: True

     - shell: /usr/bin/bar
       when: foo_result.rc == 5
```

**当在循环中注册变量，每次的结果都会保存在`result`属性列表中**。

> 注意：当任务跳过或失败，变量任然注册为失败或跳过。只有使用 tag 的条件下，可以避免注册变量。

### 访问复杂的变量

得到 IP 地址：

```yaml
{{ ansible_facts["eth0"]["ipv4"]["address"] }}
```

或者：

```yaml
{{ ansible_facts.eth0.ipv4.address }}
```

### 访问其他主机的信息

不管您是否定义了任何变量，您都可以使用 Ansible 提供的[特殊变量](https://docs.ansible.com/ansible/2.7/reference_appendices/special_variables.html#special-variables)来访问有关主机的信息，包括变量、facts和连接变量。不要使用这些名称设置变量。变量`environment`也被保留。 

`hostvars`：访问另一个主机的变量，包括 facts。

```yaml
{{ hostvars['test.example.com']['ansible_facts']['distribution'] }}
```

`groups`：库存中组或主机的列表。

```jinja2
{% for host in groups['app_servers'] %}
   # something that applies to all app servers.
{% endfor %}
```

经常使用到的，看主机的 IP：

```jinja2
{% for host in groups['app_servers'] %}
   {{ hostvars[host]['ansible_facts']['eth0']['ipv4']['address'] }}
{% endfor %}
```

`group_names`：所有的组。

```jinja2
{% if 'webserver' in group_names %}
   # some part of a configuration file that only applies to webservers
{% endif %}
```

`inventory_hostname`是在 Ansible 的 inventory 主机文件中配置的主机名。当您禁用了 facts 收集，或者您不希望依赖于所发现的主机名 `ansible_hostname` 时，这可能会很有用。如果您有一个长 FQDN，您可以使用`inventory_hostname_short`，它包含第一个周期之前的部分，而不包含域的其余部分。

 其他魔法变量：`ansible_play_hosts`，` ansible_play_batch `,` ansible_playbook_python `,` inventory_dir `,` playbook_dir `, `role_path`,  `ansible_check_mode`。

### 文件中定义变量

使用额外的变量文件：

```yaml
---

- hosts: all
  remote_user: root
  vars:
    favcolor: blue
  vars_files:
    - /vars/external_vars.yml

  tasks:

  - name: this is just a placeholder
    command: /bin/echo foo
```

消除了共享时敏感数据的泄漏问题。

变量文件的格式：

```yaml
---
# in the above example, this would be vars/external_vars.yml
somevar: somevalue
password: magic
```

### 命令行解析变量

除了`vars_prompt`和 `vars_files`,还可以通过 `--extra-vars`设置变量：

```bash
ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
```

JSON 格式：

```bash
ansible-playbook release.yml --extra-vars '{"version":"1.23.45","other_variable":"foo"}'
ansible-playbook arcade.yml --extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}'
```

YAML 格式：

```bash
ansible-playbook release.yml --extra-vars '
version: "1.23.45"
other_variable: foo'

ansible-playbook arcade.yml --extra-vars '
pacman: mrs
ghosts:
- inky
- pinky
- clyde
- sue'
```

YAML 或 JSON 文件：

```bash
ansible-playbook release.yml --extra-vars "@some_file.json"
```

确保您对标记(例如 JSON)和正在操作的 shell 都进行了适当的转义。 

```bash
ansible-playbook arcade.yml --extra-vars "{\"name\":\"Conan O\'Brien\"}"
ansible-playbook arcade.yml --extra-vars '{"name":"Conan O'\\\''Brien"}'
ansible-playbook script.yml --extra-vars "{\"dialog\":\"He said \\\"I just can\'t get enough of those single and double-quotes"\!"\\\"\"}"
```

在这些情况下，最好使用包含变量定义的 JSON 或 YAML 文件。 

### 变量优先级

下面是优先级从最小到最大的顺序：

- command line values (eg “-u user”)
- role defaults [[1\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id15)
- inventory file or script group vars [[2\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id16)
- inventory group_vars/all [[3\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id17)
- playbook group_vars/all [[3\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id17)
- inventory group_vars/* [[3\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id17)
- playbook group_vars/* [[3\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id17)
- inventory file or script host vars [[2\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id16)
- inventory host_vars/* [[3\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id17)
- playbook host_vars/* [[3\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id17)
- host facts / cached set_facts [[4\]](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#id18)
- play vars
- play vars_prompt
- play vars_files
- role vars (defined in role/vars/main.yml)
- block vars (only for tasks in block)
- task vars (only for the task)
- include_vars
- set_facts / registered vars
- role (and include_role) params
- include params
- extra vars (always win precedence)

基本上，任何涉及“角色 default”（角色内的 default 文件夹）的东西都是很容易被覆盖的。 角色的 vars 目录中的所有内容都会覆盖命名空间中该变量的先前版本。 这里要遵循的想法是，范围越明确，在命令行中的优先级就越高，`-e`总是比额外的 var 优先。 主机变量或清单变量可以覆盖角色 default 值，但不能像 vars 目录或 include_vars 任务那样显式 incude。

[1] 每个角色的任务都会看到自己角色的 default。在角色外部定义的任务将看到最后一个角色的 default 。

[2] (1,2)库存文件中定义或动态库存提供的变量。

[3] (1,2,3,4,5,6)包括 vars 插件添加的 vars，以及 host_vars 和 group_vars，这些都是由 Ansible 自带的 vars 插件添加的。

[4]使用 set_facts 的可缓存选项创建时，变量在 play 中具有较高的优先级，但是当它们来自缓存时，它们的优先级与主机 facts 相同。

> 注意：在任何部分中，重新定义 var 将覆盖前面的值。如果多个组具有相同的变量，则最后加载的组获胜。如果在一个 play，定义一个变量两次，则第二个变量获胜。 

一个重要的事情是连接变量覆盖配置，命令行，play，角色，任务指定的选项和关键词。例如，假如你库存指定 `ansible_ssh_user: ramon`，然后运行：

```bash
ansible -u lola myhost
```

这将会继续使用 `ramon`连接，因为来自变量的值具有优先权（在这种情况下，变量来自 库存，但是无论在何处定义变量都一样）。

对于 `reote_user`也是一样：

```yaml
- hosts: myhost
  tasks:
   - command: I'll connect as ramon still
     remote_user: lola
```

将会使用`remote_user`覆盖`ansible_ssh_user`。

这样做是为了使特定主机的设置可以覆盖常规设置。 这些变量通常是按库存中的主机或组定义的，但它们的行为与其他变量类似。

假如你希望覆盖全局，请使用：

```bash
ansible... -e "ansible_user=maria" -u lola
```

`lola`值仍然被忽略，但是`ansible_user = maria`优先于设置`ansible_user`（或`ansible_ssh_user`或`remote_user`）的所有位置。

你也可以在 play 中使用普通变量覆盖：

```yaml
- hosts: all
  vars:
    ansible_user: lola
  tasks:
    - command: I'll connect as lola!
```

### 变量范围

- `global`：配置，环境，和命令行
- `play`：play 和包含的结构，vars（vars_files，vars_prompt），角色的 default 和 vars
- `host`：库存，include_vars，facts，注册变量

## 条件

### When 语句

一些时候，你可能想一部分主机跳过某些步骤。例如，如果操作系统是一个特定的版本，就不安装某个包，或者如果文件系统已经满了，就执行一些清理步骤。

 这在 Ansible 中很容易做到，因为它包含一个没有双花括号的原始 Jinja2 表达式：

```yaml
tasks:
  - name: "shut down Debian flavored systems"
    command: /sbin/shutdown -t now
    when: ansible_facts['os_family'] == "Debian"
    # note that all variables can be directly in conditionals without double curly braces
```

你也可以使用`()`分组：

```yaml
tasks:
  - name: "shut down CentOS 6 and Debian 7 systems"
    command: /sbin/shutdown -t now
    when: (ansible_facts['distribution'] == "CentOS" and ansible_facts['distribution_major_version'] == "6") or
          (ansible_facts['distribution'] == "Debian" and ansible_facts['distribution_major_version'] == "7")
```

多个条件都要满足，可以使用列表：

```yaml
tasks:
  - name: "shut down CentOS 6 systems"
    command: /sbin/shutdown -t now
    when:
      - ansible_facts['distribution'] == "CentOS"
      - ansible_facts['distribution_major_version'] == "6"
```

许多 Jinja2 测试和过滤器也可以用于 when 语句，其中一些由 Ansible 提供。假设我们想要忽略一个语句的错误，然后决定根据成功或失败有条件地做一些事情：

```yaml
tasks:
  - command: /bin/false
    register: result
    ignore_errors: True

  - command: /bin/something
    when: result is failed

  # In older versions of ansible use ``success``, now both are valid but succeeded uses the correct tense.
  - command: /bin/something_else
    when: result is succeeded

  - command: /bin/still/something_else
    when: result is skipped
```

要查看特定系统上有哪些 facts 可用，可以在 playbook 中执行以下操作：

```yaml
- debug: var=ansible_facts
```

提示:有时你会得到一个字符串变量，你需要对它做一个数学运算比较。你可以这样做：

```yaml
tasks:
  - shell: echo "only on Red Hat 6, derivatives, and later"
    when: ansible_facts['os_family'] == "RedHat" and ansible_facts['lsb']['major_release']|int >= 6
```

也可以基于变量的值：

```yaml
vars:
  epic: true
...  
tasks:
    - shell: echo "This certainly is epic!"
      when: epic
	- shell: echo "This certainly isn't epic!"
      when: not epic
```

假如要求变量没有被设置：

```yaml
tasks:
    - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
      when: foo is defined

    - fail: msg="Bailing out. this play requires 'bar'"
      when: bar is undefined
```

 如示例所示，您不需要使用`{{}}`来包含条件中的变量，因为这些已隐含。

### 循环与条件

 `when`和循环（loop）组合，`when`语句会处理循环的每一个元素。

```yaml
tasks:
    - command: echo {{ item }}
      loop: [ 0, 2, 4, 6, 8, 10 ]
      when: item > 5
```

如果需要根据定义的循环变量跳过整个任务，可以使用`|default()`过滤器提供一个空迭代器：

```yaml
- command: echo {{ item }}
  loop: "{{ mylist|default([]) }}"
  when: item > 5
```

循环字典：

```yaml
- command: echo {{ item.key }}
  loop: "{{ query('dict', mydict|default({})) }}"
  when: item.value > 5
```

### 在角色，导入，包括中使用 `when`

请注意，如果您有多个任务都共享同一个条件语句，则可以将该条件附加到`include_tasks`语句，如下所示。所有的任务都会被计算，每个任务都应用了条件：

```yaml
- import_tasks: tasks/sometasks.yml
  when: "'reticulating splines' in output"
```

或者：

```yaml
- hosts: webservers
  roles:
     - role: debian_stock_config
       when: ansible_facts['os_family'] == 'Debian'
```

当条件句与`include_*`一起使用，而不是与`import`一起使用时，它仅应用于`include`任务本身，而不应用于`include`文件中的任何其他任务：

```yaml
# We wish to include a file to define a variable when it is not
# already defined

# main.yml
- import_tasks: other_tasks.yml # note "import"
  when: x is not defined

# other_tasks.yml
- set_fact:
    x: foo
- debug:
    var: x
```

使用 `include`：

```yaml
- set_fact:
    x: foo
  when: x is not defined
- debug:
    var: x
  when: x is not defined
```

假如`x`未定义，`debug`任务将会跳过。使用`inlude_tasks`代替`inport_tasks`，两个任务都会执行。

### 有条件导入

根据不同标准，做一些不同的事情：

```yaml
---
- hosts: all
  remote_user: root
  vars_files:
    - "vars/common.yml"
    - [ "vars/{{ ansible_facts['os_family'] }}.yml", "vars/os_defaults.yml" ]
  tasks:
  - name: make sure apache is started
    service: name={{ apache }} state=started
```

变量 YAML 只包含键值：

```yaml
---
# for vars/RedHat.yml
apache: httpd
somethingelse: 42
```

### 基于变量选择文件和模板

```yaml
- name: template a file
  template:
      src: "{{ item }}"
      dest: /etc/myapp/foo.conf
  loop: "{{ query('first_found', { 'files': myfiles, 'paths': mypaths}) }}"
  vars:
    myfiles:
      - "{{ansible_facts['distribution']}}.conf"
      -  default.conf
    mypaths: ['search_location_one/somedir/', '/opt/other_location/somedir/']
```

### 注册变量

`register`关键字可以保存执行的结果。之后可以在模板、`command`或`when`语句中使用 

```yaml
- name: test play
  hosts: all

  tasks:

      - shell: cat /etc/motd
        register: motd_contents

      - shell: echo "motd contains the word hi"
        when: motd_contents.stdout.find('hi') != -1
```

如果注册的结果被转换为列表(或者已经是列表)，则可以在任务的循环中使用：

```yaml
- name: registered variable usage as a loop list
  hosts: all
  tasks:

    - name: retrieve the list of home directories
      command: ls /home
      register: home_dirs

    - name: add home dirs to the backup spooler
      file:
        path: /mnt/bkspool/{{ item }}
        src: /home/{{ item }}
        state: link
      loop: "{{ home_dirs.stdout_lines }}"
      # same as loop: "{{ home_dirs.stdout.split() }}"
```

注册的变量是字符串内容。可以检查变量字符串内容是否为空：

```yaml
- name: check registered variable for emptiness
  hosts: all

  tasks:

      - name: list contents of directory
        command: ls mydir
        register: contents

      - name: check contents for emptiness
        debug:
          msg: "Directory is empty"
        when: contents.stdout == ""
```

## 循环

### 标准循环

```yaml
- name: add several users
  user:
    name: "{{ item }}"
    state: present
    groups: "wheel"
  loop:
     - testuser1
     - testuser2
```

和这个相等：

```yaml
- name: add user testuser1
  user:
    name: "testuser1"
    state: present
    groups: "wheel"
- name: add user testuser2
  user:
    name: "testuser2"
    state: present
    groups: "wheel"
```

`yum`和 `apt`直接添加列表到`name`中，比使用循环更好：

```yaml
- name: optimal yum
  yum:
    name: "{{list_of_packages}}"
    state: present

- name: non optimal yum, not only slower but might cause issues with interdependencies
  yum:
    name: "{{item}}"
    state: present
  loop: "{{list_of_packages}}"
```

遍历 hash 列表：

```yaml
- name: add several users
  user:
    name: "{{ item.name }}"
    state: present
    groups: "{{ item.groups }}"
  loop:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
```

遍历 字典：

```yaml
- name: create a tag dictionary of non-empty tags
  set_fact:
    tags_dict: "{{ (tags_dict|default({}))|combine({item.key: item.value}) }}"
  loop: "{{ tags|dict2items }}"
  vars:
    tags:
      Environment: dev
      Application: payment
      Another: "{{ doesnotexist|default() }}"
  when: item.value != ""
```

在这里，我们不想设置空标签，所以我们创建了一个只包含非空标签的字典。

### 复杂的循环

使用 Jinja2 表达式生成复杂的列表：

```yaml
- name: give users access to multiple databases
  mysql_user:
    name: "{{ item[0] }}"
    priv: "{{ item[1] }}.*:ALL"
    append_privs: yes
    password: "foo"
  loop: "{{ ['alice', 'bob'] |product(['clientdb', 'employeedb', 'providerdb'])|list }}"
```

> 注意：`with_`循环实际是`with_`+ `lookup()`组合。

在循环使用 lookup 或 query

`query`提供了更简单的接口和比`lookup`插件的更可预测的输出，从而确保了更好的与循环的兼容性。 

以下调用是等效的，使用带有查找的`wantlist=True`来确保列表的返回类型：

```yaml
loop: "{{ query('inventory_hostnames', 'all') }}"

loop: "{{ lookup('inventory_hostnames', 'all', wantlist=True) }}"
```

### Do-until 循环

直到某个条件退出循环：

```yaml
- shell: /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```

>  如果`until`参数未定义，则`retries`参数的值将强制为 1。 

### 在循环中使用 register

运行的结果将包含在 `register`中的`results`列表中：

```yaml
- shell: "echo {{ item }}"
  loop:
    - "one"
    - "two"
  register: echo
```

这与不使用循环的 register 时返回的数据结构不同：

```json
{
    "changed": true,
    "msg": "All items completed",
    "results": [
        {
            "changed": true,
            "cmd": "echo \"one\" ",
            "delta": "0:00:00.003110",
            "end": "2013-12-19 12:00:05.187153",
            "invocation": {
                "module_args": "echo \"one\"",
                "module_name": "shell"
            },
            "item": "one",
            "rc": 0,
            "start": "2013-12-19 12:00:05.184043",
            "stderr": "",
            "stdout": "one"
        },
        {
            "changed": true,
            "cmd": "echo \"two\" ",
            "delta": "0:00:00.002920",
            "end": "2013-12-19 12:00:05.245502",
            "invocation": {
                "module_args": "echo \"two\"",
                "module_name": "shell"
            },
            "item": "two",
            "rc": 0,
            "start": "2013-12-19 12:00:05.242582",
            "stderr": "",
            "stdout": "two"
        }
    ]
}
```

在注册变量上进行后续循环以检查结果：

```yaml
- name: Fail if return code is not 0
  fail:
    msg: "The command ({{ item.cmd }}) did not have a 0 return code"
  when: item.rc != 0
  loop: "{{ echo.results }}"
```

在迭代期间，将当前项的结果放在变量中：

```yaml
- shell: echo "{{ item }}"
  loop:
    - one
    - two
  register: echo
  changed_when: echo.stdout != "one"
```

### 循环 inventory

```yaml
# show all the hosts in the inventory
- debug:
    msg: "{{ item }}"
  loop: "{{ groups['all'] }}"

# show all the hosts in the current play
- debug:
    msg: "{{ item }}"
  loop: "{{ ansible_play_batch }}"
```

```yaml
# show all the hosts in the inventory
- debug:
    msg: "{{ item }}"
  loop: "{{ query('inventory_hostnames', 'all') }}"

# show all the hosts matching the pattern, ie all but the group www
- debug:
    msg: "{{ item }}"
  loop: "{{ query('inventory_hostnames', 'all!www') }}"
```

### 循环控制

```yaml
# main.yml
- include_tasks: inner.yml
  loop:
    - 1
    - 2
    - 3
  loop_control:
    loop_var: outer_item

# inner.yml
- debug:
    msg: "outer item={{ outer_item }} inner item={{ item }}"
  loop:
    - a
    - b
    - c
```

在 Ansible 2.2（多了 `pasue`）：

```yaml
# main.yml
- name: create servers, pause 3s before creating next
  digital_ocean:
    name: "{{ item }}"
    state: present
  loop:
    - server1
    - server2
  loop_control:
    pause: 3
```

在 Ansible 2.5 可以这样（多了 `index_var`）：

```yaml
- name: count our fruit
  debug:
    msg: "{{ item }} with index {{ my_idx }}"
  loop:
    - apple
    - banana
    - pear
  loop_control:
    index_var: my_idx
```

### 从 with_* 到 loop

#### with_list

```yaml
- name: with_list
  debug:
    msg: "{{ item }}"
  with_list:
    - one
    - two

- name: with_list -> loop
  debug:
    msg: "{{ item }}"
  loop:
    - one
    - two
```

#### with_items

```yaml
- name: with_items
  debug:
    msg: "{{ item }}"
  with_items: "{{ items }}"

- name: with_items -> loop
  debug:
    msg: "{{ item }}"
  loop: "{{ items|flatten(levels=1) }}"
```

#### with_indexed_items

```yaml
- name: with_indexed_items
  debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  with_indexed_items: "{{ items }}"

- name: with_indexed_items -> loop
  debug:
    msg: "{{ index }} - {{ item }}"
  loop: "{{ items|flatten(levels=1) }}"
  loop_control:
    index_var: index
```

#### with_flattened

```yaml
- name: with_flattened
  debug:
    msg: "{{ item }}"
  with_flattened: "{{ items }}"

- name: with_flattened -> loop
  debug:
    msg: "{{ item }}"
  loop: "{{ items|flatten }}"
```

#### with_together

```yaml
- name: with_together
  debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  with_together:
    - "{{ list_one }}"
    - "{{ list_two }}"

- name: with_together -> loop
  debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  loop: "{{ list_one|zip(list_two)|list }}"
```

#### with_dict

```yaml
- name: with_dict
  debug:
    msg: "{{ item.key }} - {{ item.value }}"
  with_dict: "{{ dictionary }}"

- name: with_dict -> loop (option 1)
  debug:
    msg: "{{ item.key }} - {{ item.value }}"
  loop: "{{ dictionary|dict2items }}"

- name: with_dict -> loop (option 2)
  debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  loop: "{{ dictionary|dictsort }}"
```

#### with_sequence

```
- name: with_sequence
  debug:
    msg: "{{ item }}"
  with_sequence: start=0 end=4 stride=2 format=testuser%02x

- name: with_sequence -> loop
  debug:
    msg: "{{ 'testuser%02x' | format(item) }}"
  # range is exclusive of the end point
  loop: "{{ range(0, 4 + 1, 2)|list }}"
```

#### with_subelements

```
- name: with_subelements
  debug:
    msg: "{{ item.0.name }} - {{ item.1 }}"
  with_subelements:
    - "{{ users }}"
    - mysql.hosts

- name: with_subelements -> loop
  debug:
    msg: "{{ item.0.name }} - {{ item.1 }}"
  loop: "{{ users|subelements('mysql.hosts') }}"
```

#### with_nested/with_cartesian

```
- name: with_nested
  debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  with_nested:
    - "{{ list_one }}"
    - "{{ list_two }}"

- name: with_nested -> loop
  debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  loop: "{{ list_one|product(list_two)|list }}"
```

#### with_random_choice

```
- name: with_random_choice
  debug:
    msg: "{{ item }}"
  with_random_choice: "{{ my_list }}"

- name: with_random_choice -> loop (No loop is needed here)
  debug:
    msg: "{{ my_list|random }}"
  tags: random
```

## 块（blocks）

逻辑分组和错误处理。

```yaml
 tasks:
   - name: Install Apache
     block:
       - yum:
           name: "{{ item }}"
           state: installed
         with_items:
           - httpd
           - memcached
       - template:
           src: templates/src.j2
           dest: /etc/foo.conf
       - service:
           name: bar
           state: started
           enabled: True
     when: ansible_facts['distribution'] == 'CentOS'
     become: true
     become_user: root
```

在上面的例子中，这 3 个任务都是在`when`条件之后执行的。它们还继承了特权升级指令，使`become`能够包含所有任务。 

### 错误处理

```yaml
tasks:
 - name: Handle the error
   block:
     - debug:
         msg: 'I execute normally'
     - name: i force a failure
       command: /bin/false
     - debug:
         msg: 'I never execute, due to the above task failing, :-('
   rescue:
     - debug:
         msg: 'I caught an error, can do stuff here to fix it, :-)'
```

这将`revert`运行任务的失败状态，并且 play 就像成功一样继续。

`always`无论如何都会运行：

```yaml
 - name: Always do X
   block:
     - debug:
         msg: 'I execute normally'
     - name: i force a failure
       command: /bin/false
     - debug:
         msg: 'I never execute :-('
   always:
     - debug:
         msg: "This always executes, :-)"
```

包含所有的：

```yaml
- name: Attempt and graceful roll back demo
  block:
    - debug:
        msg: 'I execute normally'
    - name: i force a failure
      command: /bin/false
    - debug:
        msg: 'I never execute, due to the above task failing, :-('
  rescue:
    - debug:
        msg: 'I caught an error'
    - name: i force a failure in middle of recovery! >:-)
      command: /bin/false
    - debug:
        msg: 'I also never execute :-('
  always:
    - debug:
        msg: "This always executes"
```

运行 handlers 之后的错误救援：

```yaml
 tasks:
   - name: Attempt and graceful roll back demo
     block:
       - debug:
           msg: 'I execute normally'
         notify: run me even after an error
       - command: /bin/false
     rescue:
       - name: make sure all handlers run
         meta: flush_handlers
 handlers:
    - name: run me even after an error
      debug:
        msg: 'This handler runs even on error'
```

Ansible 为 `rescue`提供的变量：

- `ansible_failed_task`：捕获的触发救援的失败任务
- `ansible_failed_result`： 捕获的触发救援的失败任务的返回结果 

## 异步和轮询

为了避免阻塞或 SSH 超时问题，可以使用异步模式一次运行所有任务，然后轮询，直到完成为止。 

若要异步启动任务，请指定其最大运行时以及轮询状态的频率。如果不为轮询指定值，则默认轮询值为10秒 

```yaml
---

- hosts: all
  remote_user: root

  tasks:

  - name: simulate long running op (15 sec), wait for up to 45 sec, poll every 5 sec
    command: /bin/sleep 15
    async: 45
    poll: 5
```

如果不需要等待任务完成，可以指定一个轮询值 0 来异步运行任务：

```yaml
---

- hosts: all
  remote_user: root

  tasks:

  - name: simulate long running op, allow to run for 45 sec, fire and forget
    command: /bin/sleep 15
    async: 45
    poll: 0
```

如果希望异步执行某个任务，并在稍后进行检查：

```yaml
---
# Requires ansible 1.8+
- name: 'YUM - async task'
  yum:
    name: docker-io
    state: installed
  async: 1000
  poll: 0
  register: yum_sleeper

- name: 'YUM - check on async task'
  async_status:
    jid: "{{ yum_sleeper.ansible_job_id }}"
  register: job_result
  until: job_result.finished
  retries: 30
```

> 注意： 如果`async:`的值不够高,这将导致稍后的任务检查失败,因为async `status:`正在寻找的临时状态文件将不会被写入或不存在 

运行多个异步任务，同时限制并发运行的任务数量：

```yaml
#####################
# main.yml
#####################
- name: Run items asynchronously in batch of two items
  vars:
    sleep_durations:
      - 1
      - 2
      - 3
      - 4
      - 5
    durations: "{{ item }}"
  include_tasks: execute_batch.yml
  loop:
    - "{{ sleep_durations | batch(2) | list }}"

#####################
# execute_batch.yml
#####################
- name: Async sleeping for batched_items
  command: sleep {{ async_item }}
  async: 45
  poll: 0
  loop: "{{ durations }}"
  loop_control:
    loop_var: "async_item"
  register: async_results

- name: Check sync status
  async_status:
    jid: "{{ async_result_item.ansible_job_id }}"
  loop: "{{ async_results.results }}"
  loop_control:
    loop_var: "async_result_item"
  register: async_poll_results
  until: async_poll_results.finished
  retries: 30
```

###  滚动更新数量

默认情况下，Ansible 会尝试并行地管理一个 playbook 中引用的所有机器。对于滚动更新用例，可以使用`serial`关键字定义 Ansible 在同一时间应该管理多少台主机：

```yaml
- name: test play
  hosts: webservers
  serial: 2
  gather_facts: False
  tasks:
  - name: task one
    comand: hostname
  - name: task two
    command: hostname
```

输出：

```yaml
PLAY [webservers] ****************************************

TASK [task one] ******************************************
changed: [web2]
changed: [web1]

TASK [task two] ******************************************
changed: [web1]
changed: [web2]

PLAY [webservers] ****************************************

TASK [task one] ******************************************
changed: [web3]
changed: [web4]

TASK [task two] ******************************************
changed: [web3]
changed: [web4]

PLAY RECAP ***********************************************
web1      : ok=2    changed=2    unreachable=0    failed=0
web2      : ok=2    changed=2    unreachable=0    failed=0
web3      : ok=2    changed=2    unreachable=0    failed=0
web4      : ok=2    changed=2    unreachable=0    failed=0
```

`serial` 也可以使用百分数，列表（[1,3,5]）或混合使用：

```yaml
- name: test play
  hosts: webservers
  serial:
  - 1
  - 5
  - "20%"
```

### 最大失败百分数

默认情况下，只要批处理中有尚未失败的主机，Ansible 就会继续执行。当达到一定的故障阈值时，可能希望中止 play：

```yaml
- hosts: webservers
  max_fail_percentage: 30
  serial: 10
```

如果组中的 10 台服务器中有 3 台以上（**必须超过 30%**）发生故障，则将终止其余的操作。 

### 指派

```yaml
---

- hosts: webservers
  serial: 5

  tasks:

  - name: take out of load balancer pool
    command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
    delegate_to: 127.0.0.1

  - name: actual steps would go here
    yum:
      name: acme-web-stack
      state: latest

  - name: add back to load balancer pool
    command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
    delegate_to: 127.0.0.1
```

简写：

```yaml
---

# ...

  tasks:

  - name: take out of load balancer pool
    local_action: command /usr/bin/take_out_of_pool {{ inventory_hostname }}

# ...

  - name: add back to load balancer pool
    local_action: command /usr/bin/add_back_to_pool {{ inventory_hostname }}
```

如果需要其余参数：

```yaml
---
# ...
  tasks:

  - name: Send summary mail
    local_action:
      module: mail
      subject: "Summary Mail"
      to: "{{ mail_recipient }}"
      body: "{{ mail_body }}"
    run_once: True
```

### 指派 facts

将收集 facts 的工作指派给其他主机：

```yaml
- hosts: app_servers
  tasks:
    - name: gather facts from db servers
      setup:
      delegate_to: "{{item}}"
      delegate_facts: True
      loop: "{{groups['dbservers']}}"
```

> 注意：使用 ` hostvars[‘dbhost1’][‘default_ipv4’][‘address’]`等获取 facts。

### Run Once

```yaml
---
# ...

  tasks:

    # ...

    - command: /opt/application/upgrade_db.py
      run_once: true

    # ...
```

和指派一起用：

```yaml
- command: /opt/application/upgrade_db.py
  run_once: true
  delegate_to: web01.example.org
```

### 本地 Playbooks

自己运行 playbook：

```yaml
- hosts: 127.0.0.1
  connection: local
```

或：

```bash
ansible-playbook playbook.yml --connection=local
```

### 错误后中断执行

使用`any_errors_fatal`选项，多主机 play 中任何主机上的任何失败都将被视为致命的，Ansible 将立即退出，而无需等待其他主机。 

```yaml
---
- hosts: load_balancers_dc_a
  any_errors_fatal: True
  tasks:
  - name: 'shutting down datacenter [ A ]'
    command: /usr/bin/disable-dc

- hosts: frontends_dc_a
  tasks:
  - name: 'stopping service'
    command: /usr/bin/stop-software
  - name: 'updating software'
    command: /usr/bin/upgrade-software

- hosts: load_balancers_dc_a
  tasks:
  - name: 'Starting datacenter [ A ]'
    command: /usr/bin/enable-dc
```

## 错误处理

### 忽略错误

```yaml
- name: this will not be counted as a failure
  command: /bin/false
  ignore_errors: yes
```

### 重置不可达主机

连接失败被设置为 `unreachable`,通过`meta: clear_host_errors`重置。

### Handlers 错误

如过任务运行失败，但是之前任务触发的的 handlers 未运行，可能会导致配置修改却未加载等等的错误。

设置 `force_handlers: True`或`--force-handlers`，即使任务失败，Handlers 也会执行。

### 定义错误 

```yaml
- name: Fail task when the command error output prints FAILED
  command: /usr/bin/example-command -x -y -z
  register: command_result
  failed_when: "'FAILED' in command_result.stderr"
```

或：

```yaml
- name: Fail task when both files are identical
  raw: diff foo/file1 bar/file2
  register: diff_cmd
  failed_when: diff_cmd.rc == 0 or diff_cmd.rc >= 2
```

### 覆盖 Result

```yaml
tasks:

  - shell: /usr/bin/billybass --mode="take me to the river"
    register: bass_result
    changed_when: "bass_result.rc != 2"

  # this will never report 'changed' status
  - shell: wall 'beep'
    changed_when: False
```

### 终止 play

`any_errors_fatal`选项将标记为所有主机失败，如果任何一个 play 失败，将立即中止：

```yaml
- hosts: somehosts
  any_errors_fatal: true
  roles:
    - myrole
```

## 提示

```yaml
---
- hosts: all
  remote_user: root

  vars:
    from: "camelot"

  vars_prompt:
    - name: "name"
      prompt: "what is your name?"
    - name: "quest"
      prompt: "what is your quest?"
    - name: "favcolor"
      prompt: "what is your favorite color?"
```

设置默认值：

```yaml
vars_prompt:

  - name: "release_version"
    prompt: "Product release version"
    default: "1.0"
```

隐藏输入：

```yaml
vars_prompt:

  - name: "some_password"
    prompt: "Enter password"
    private: yes

  - name: "release_version"
    prompt: "Product release version"
    private: no
```

## 标签（tags）

```yaml
tasks:
    - yum:
        name: "{{ item }}"
        state: installed
      loop:
         - httpd
         - memcached
      tags:
         - packages

    - template:
        src: templates/src.j2
        dest: /etc/foo.conf
      tags:
         - configuration
```

使用标签：

```bash
ansible-playbook example.yml --tags "configuration,packages"
```

跳过标签：

```bash
ansible-playbook example.yml --skip-tags "packages"
```

### 标签重用

```yaml
---
# file: roles/common/tasks/main.yml

- name: be sure ntp is installed
  yum:
    name: ntp
    state: installed
  tags: ntp

- name: be sure ntp is configured
  template:
    src: ntp.conf.j2
    dest: /etc/ntp.conf
  notify:
    - restart ntpd
  tags: ntp

- name: be sure ntpd is running and enabled
  service:
    name: ntpd
    state: started
    enabled: yes
  tags: ntp
```

### 标签继承

添加`tags:`, 将这些标签添加到 playbook 或静态导入的任务和角色中。这称为标记继承。标记继承不适用于`include_role`和`include_tasks`等动态`include`。

标记了两个剧本中的所有任务。第一个 play 的所有任务都用 bar 标记，第二个 play 的所有任务都用 foo 标记。

 ```yaml
- hosts: all
  tags:
    - bar
  tasks:
    ...

- hosts: all
  tags: ['foo']
  tasks:
    ...
 ```

在 `roles`中：

```yaml
roles:
  - role: webserver
    vars:
      port: 5000
    tags: [ 'web', 'foo' ]
```

添加 `import_role`和`import_tasks`语句：

```yaml
- import_role:
    name: myrole
  tags: [web,foo]

- import_tasks: foo.yml
  tags: [web,foo]
```

### 特殊标记

`always`始终运行，除非指明跳过（`--skip-tags always`）：

```yaml
tasks:

    - debug:
        msg: "Always runs"
      tags:
        - always

    - debug:
        msg: "runs when you use tag1"
      tags:
        - tag1
```

`never`和 `always`相反：

```yaml
tasks:
  - debug: msg='{{ showmevar}}'
    tags: [ 'never', 'debug' ]
```

其他：`tagged`, `untagged`, `all`

##  关键词

查找[Keywords]( https://docs.ansible.com/ansible/2.7/reference_appendices/playbooks_keywords.html )

## 模块默认值

如果发现自己使用相同的参数重复调用相同的模块，则使用`module_defaults`属性为该特定模块定义默认参数：

```yaml
- hosts: localhost
  module_defaults:
    file:
      owner: root
      group: root
      mode: 0755
  tasks:
    - file:
        state: touch
        path: /tmp/file1
    - file:
        state: touch
        path: /tmp/file2
    - file:
        state: touch
        path: /tmp/file3
```

## 最佳实践

### 目录布局

```yaml
production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
   group1.yml             # here we assign variables to particular groups
   group2.yml
host_vars/
   hostname1.yml          # here we assign variables to particular systems
   hostname2.yml

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies
        library/          # roles can also include custom modules
        module_utils/     # roles can also include custom module_utils
        lookup_plugins/   # or other types of plugins, like lookup in this case

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/    
```

### 备用布局

```yaml
inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml

   staging/
      hosts               # inventory file for staging environment
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         stagehost1.yml   # here we assign variables to particular systems
         stagehost2.yml

library/
module_utils/
filter_plugins/

site.yml
webservers.yml
dbservers.yml

roles/
    common/
    webtier/
    monitoring/
    fooapp/
```

[最佳实践]( https://docs.ansible.com/ansible/2.7/user_guide/playbooks_best_practices.html )

<br/>

> [Working With Playbooks]( https://docs.ansible.com/ansible/2.7/user_guide/playbooks.html )