# 配置 Ansible

这个主题描述了怎么控制 Ansible 的设置。

[TOC]

## 配置文件

某些 Ansible 设置可以通过配置文件（ansible.cfg）调整。对于大多数用户来说， 默认配置应该足够了，但是可能有一些原因需要更改它们。在[参考文档](https://docs.ansible.com/ansible/2.7/reference_appendices/config.html#ansible-configuration-settings-locations)中列出了配置文件的路径。 

## 获得最新的配置

假如从包管理安装的 Ansible，最新的 ansible.cfg 应该在 /etc/ansible 文件夹中。

假如是通过 `pip` 或从源中安装，你可能想要创建一个文件为了覆盖默认的设置。

[Ansible 配置文件例子](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)。

更多的细节和全部可用的配置列表，查看[配置](https://docs.ansible.com/ansible/2.7/reference_appendices/config.html#ansible-configuration-settings)。从 Ansible 2.4 开始，你可以使用 `ansible-config`命令列出可用的选项和它的值。

为了更多的细节，请看 [Ansible configuration Settings](https://docs.ansible.com/ansible/2.7/reference_appendices/config.html#ansible-configuration-settings)。

## 环境配置

Ansible 也允许通过环境变量配置设置。**假如环境变量设置，他将覆盖从文件中加载的值。**

你可以看[完整的环境变量列表](https://docs.ansible.com/ansible/2.7/reference_appendices/config.html#ansible-configuration-settings)。

## 命令行选项

并不是所有的配置选项都出现在命令行中，只有那些被认为最有用或最常见的配置选项。命令行中的设置将覆盖通过配置文件和环境传递的值。 

你可以看完整的命令行选项列表，[ansible-playbook](https://docs.ansible.com/ansible/2.7/cli/ansible-playbook.html#ansible-playbook) 和 [ansible](https://docs.ansible.com/ansible/2.7/cli/ansible.html#ansible)。

<br/>

> [Configuring Ansible](https://docs.ansible.com/ansible/2.7/installation_guide/intro_configuration.html#id3)