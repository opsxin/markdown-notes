# Ansible 2.7 迁移向导

这个部分讨论了 Ansible 2.6 和 Ansible 2.7 之间的变更。

它为了帮助更新你的 playbooks，插件和其他的 Ansible 基础架构，以便他们在这个版本的 Ansible 工作。 

我们建议你阅读 [Andible 的变更日志](https://github.com/ansible/ansible/blob/stable-2.7/changelogs/CHANGELOG-v2.7.rst)去理解你需要应用更新。

本文档是移植的集合的一部分。你可在以下网址找到完整的[移植指引](https://docs.ansible.com/ansible/2.7/porting_guides/porting_guides.html#porting-guides)。

[TOC]

## 命令行

假如你在命令行多次指定 `--tags`或`--skip-tags`，Ansible 将合并指定的 tag。在早期的版本，你可以设置`merge_mutiple_cli_tags False` 来保持只有最后指定的 `--tags`。这个配置选项用于向后兼容。 在 2.3 中取消了覆盖行为，在 2.4 中更改了默认行为。Ansible-2.7 删除了配置选项;多个`–tags`现在总是被合并。 

假如你有 shell 脚本依赖 `merge_mutiple_cli_tags False`，请升级你的脚本，使用你真正需要的 `--tags`。

## Python 适配

在控制器上，Ansible 已经放弃了 Python-2.6（`/usr/bin/ansible` 或`/usr/bin/ansible-playbook`)的主机。Ansible 提供的模块仍然可以用来管理只有 Python-2.6 的主机。您只需要有一个 Python-2.7 或 Python-3.5 或更高版本的主机来管理这些主机。

这确实会影响使用`/usr/bin/ansible-pull`管理 Python-2.6 的主机的能力。`ansibl -pull`在被管理的主机上运行，但它是一个控制器脚本，不是模块，因此需要更新 Python。Linux 发行版附带的 Python-2.6 有一些手段来安装新的 Python 版本（例如,RHEL-6 sci 可以安装 Python - 2.7 ）但是你可能还需要安装 Python 依赖才能使许多公共模块工作 （例如, RHEL-6 selinux 和 yum 必须安装 Python）。

在控制器上取消 Python-2.6 支持的决定是由于许多依赖库在控制器上不可用。特别是 python-crytography 不再适用于 Python-2.6，pycrypto 的最后一个版本（python-crytography的替代版本）已经知道了永远无法修复的安全漏洞。 

## Palybook

### 修复角色加载期间角色优先级

Ansible 2.7 在加载角色时对变量优先级做了一个小的改变，解决了一个 bug，确保角色加载符合[变量优先级的期望](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_variables.html#ansible-variable-precedence)。 

在 Ansible 2.7 之前，在解析角色 `tasks/main.yml`时， `vars/main.yml`和 `default/main.yml` 的变量定义还不可用。阻止了角色在解析时使用这些变量。这个问题出现在使用 `import_tasks` 或 `import_role` 与定义在角色的 `vars` 或 `default`中变量一起使用时。

在 Ansible 2.7 中，角色`vars`和`default`现在在`tasks/main.yml`之前被解析。如果在 play 级别和 role 级别定义了具有不同值的相同变量，并利用 `import_tasks `或`import_role`来定义要导入的角色或文件，则会导致行为发生变化。

### include_role 和 import_role 变量 exposure

在 Ansible 2.7 ，`include_role` 模块中新加了一个 `public` 的参数，用来指出`default` 和 `vars` 是否要在角色外暴露，允许这些变量在之后的任务中使用。这个值默认时`public: False`，和现在的行为匹配。

`import_role` 不支持 `public`参数，将会无条件的对 playbook 之中暴露 `default`， `vars`。这个功能使 `import_role` 与剧本中角色头中列出的角色更加一致。

`include_role`（dynamic）和 `import_role`（static）暴露变量的方式非常不同。`import_role` 是预先处理的，`default` 和 `vars` 是在剧本解析时就求值，使变量在任务和角色在剧本的任何一个点都可用。`include_role`是有条件的任务，`default`和 `vars`是在执行时求值，使变量在`include_role`之后的任务和角色中可用。

### include_tasks/import_tasks 内联变量

在 Ansible 2.7，include_tasks 和 import_tasks 不再接受内联变量，请使用 `vars`关键词提供变量。

**OLD** 在 2.6 和 2.6 之前，定义变量：

```yaml
- include_tasks: include_me.yaml variable=value
```

**NEW**：

```yaml
- include_tasks: include_me.yml
  vars:
    variable: value
```

### vars_prompt 使用未知的算法

vars_prompt 现在抛出一个错误，如果 hash 算法指定的加密不被控制机支持。这增加了 vars_prompt 的安全性，因为以前如果算法未知，它将返回 None。有些模块，尤其是 user 模块，将一个 None 的密码视为不设置密码的请求。如果您的 playbook 因此开始出错，请更改与此筛选器一起使用的哈希算法。

## 弃用

### 加急弃用：在 `AnsibleModule`中使用`__file__`

…

```python
-    tempdir = os.path.dirname(__file__)
-    package = os.path.join(tempdir, to_native(deb.rsplit('/', 1)[1]))
+    package = os.path.join(module.tmpdir, to_native(deb.rsplit('/', 1)[1]))
```

### 在 squash_actions 中循环使用包模块

使用 `squash_actions`中调用包模块。例如`yum`，调用模块一次被被弃用，在 Ansible 2.11 中将被移除。

代替使用 squash_actions，任务应该给 `pkg`和`package`中的 `name`提供列表。这个功能在 Ansible 2.3 之后提供。

**OLD**：

```yaml
- name: Install Packages
  yum: 
  	name: "{{ item }}"
  	state: present
  with_items: "{{ packages  }}"
```

**NEW**：

```yaml
- name: Install Packages
  yum: 
  	name: "{{ packages }}"
  	state: present
```

## 模块

主要的流行模块变更在这

- `DEFAULT_SYSLOG_FACILITY`配置选项告诉 Ansible 模块在记录所有托管机器上的信息时使用特定的 syslog 功能。由于旧版本的 Ansible 有缺陷，这个设置不会影响安装了systemd Python 绑定的使用 journald 的机器。在这些机器上，可能的日志消息被发送到 /var/log/messages，即使您设置了`DEFAULT_SYSLOG_FACILITY`。Ansible 2.7 修复了这个 bug，根据`DEFAULT_SYSLOG_FACILITY`设置的值路由所有的 Ansible 日志消息。如果配置了`DEFAULT_SYSLOG_FACILITY`，那么使用 journald 的系统上的远程日志的位置可能会改变。

### 弃用提醒

下列模块将在 2.11 移除：

- `na_cdot_aggregate` use [na_ontap_aggregate](https://docs.ansible.com/ansible/2.7/modules/na_ontap_aggregate_module.html#na-ontap-aggregate-module) instead.
- `na_cdot_license` use [na_ontap_license](https://docs.ansible.com/ansible/2.7/modules/na_ontap_license_module.html#na-ontap-license-module) instead.
- `na_cdot_lun` use [na_ontap_lun](https://docs.ansible.com/ansible/2.7/modules/na_ontap_lun_module.html#na-ontap-lun-module) instead.
- `na_cdot_qtree` use [na_ontap_qtree](https://docs.ansible.com/ansible/2.7/modules/na_ontap_qtree_module.html#na-ontap-qtree-module) instead.
- `na_cdot_svm` use [na_ontap_svm](https://docs.ansible.com/ansible/2.7/modules/na_ontap_svm_module.html#na-ontap-svm-module) instead.
- `na_cdot_user` use [na_ontap_user](https://docs.ansible.com/ansible/2.7/modules/na_ontap_user_module.html#na-ontap-user-module) instead.
- `na_cdot_user_role` use [na_ontap_user_role](https://docs.ansible.com/ansible/2.7/modules/na_ontap_user_role_module.html#na-ontap-user-role-module) instead.
- `na_cdot_volume` use [na_ontap_volume](https://docs.ansible.com/ansible/2.7/modules/na_ontap_volume_module.html#na-ontap-volume-module) instead.
- `sf_account_manager` use [na_elementsw_account](https://docs.ansible.com/ansible/2.7/modules/na_elementsw_account_module.html#na-elementsw-account-module) instead.
- `sf_check_connections` use [na_elementsw_check_connections](https://docs.ansible.com/ansible/2.7/modules/na_elementsw_check_connections_module.html#na-elementsw-check-connections-module) instead.
- `sf_snapshot_schedule_manager` use [na_elementsw_snapshot_schedule](https://docs.ansible.com/ansible/2.7/modules/na_elementsw_snapshot_schedule_module.html#na-elementsw-snapshot-schedule-module) instead.
- `sf_volume_access_group_manager` use [na_elementsw_access_group](https://docs.ansible.com/ansible/2.7/modules/na_elementsw_access_group_module.html#na-elementsw-access-group-module) instead.
- `sf_volume_manager` use [na_elementsw_volume](https://docs.ansible.com/ansible/2.7/modules/na_elementsw_volume_module.html#na-elementsw-volume-module) instead.

### 值得注意的变更

- `command`和`shell`模块现在支持检查模式。但是，只有在`creates`或`removes`指定时。如果指定了其中任何一个，模块将检查文件是否存在并报告正确的更改状态，如果不包括，模块将像以前一样。

- …

- `include_role`和`include_tasks`可以被直接使用在`ansible(adhoc)`和 `ansible-console`：

  ```bash
  ansible -m include_role  -a "name=myrole" all
  ```

- …

## 插件

-  如果指定的哈希算法不被控制器支持，哈希密码过滤器将抛出一个错误。这增加了过滤器的安全性，因为如果算法未知，它以前不会返回任何值。有些模块，尤其是 user 模块，将一个 None 的密码视为不设置密码的请求。如果您的 playbook 因此开始出错，请更改与此筛选器一起使用的哈希算法。 

<br/>

> [Ansible 2.7 Porting Guide](https://docs.ansible.com/ansible/2.7/porting_guides/porting_guide_2.7.html#id1)