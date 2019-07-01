###### 变量

```yaml
---
- hosts: C
  remote_user: root
  vars:
    var1: root
    var2: test
    var3:
      var31: /tmp
      var32: text
  #从文件中读取，文件内容和"vars"类似
  # vars_files:
    # - VARS_FILES
  tasks:
    - name: mkdir /root/test
      file:
        path: /{{ var1 }}/{{ var2 }}
        state: directory 

    - name: mkdir /tmp/text
      file: 
        #如果在行首，需要用引号包围
        path: "{{ var3.var31 }}/{{ var3.var32 }}"
        state: touch
        #或者使用"="
        #path={{ var3.var31 }}/{{ var3.var32 }}
        #state=touch 
    - name: debug msg
      debug:
        #**var和msg选项只能2选1**
        #var: var2
        msg: "debug msg: {{ var3.var32 }}"
```



###### setup模块

```bash
#显示远程主机的信息，使用json
ansible A -m setup
#显示以ansible开头的
ansible A -m setup -a 'filter=ansible*'
```



###### 用户输入变量

```yaml
---
- hosts: C
  remote_user: root
  #用户输入
  vars_prompt:
    - name: "you_name"
      prompt: "you name"
      private: no
    - name: "you_age"
      prompt: "you age"
      #默认就是不显示，private=yes
      private: yes
    - name: "you_choose"
      prompt: "
      A: A\n
      B: B\n
      C: C"
      #默认值
      default: A
  tasks:
    - name: debug msg
      debug:
        msg: "you name: {{you_name}}, you age: {{you_age}}, you choose {{you_choose}}"
```



###### 命令行变量

```bash
#可以在CLI中增加变量,在yaml中引用
#**会覆盖yaml中已定义的同名变量**
ansible-playbook PLAYBOOK-YAML -e 'var1="123" var2="456"'

#传入变量文件
#内容和vars定义格式相同
ansible-playbook PLAYBOOK-YAML -e "@/root/test.txt"
```



###### 不同play变量

```yaml
---
- hosts: C
  remote_user: root
  #用户输入
  vars_prompt:
    - name: "you_name"
      prompt: "you name"
      private: no
    - name: "you_age"
      prompt: "you age"
      #默认就是不显示
      private: yes
    - name: "you_choose"
      prompt: "
      A: A\n
      B: B\n
      C: C"
      #默认值
      default: A
  tasks:
  #set_fact模块可以设置变量
  #**通过set_fact设置的变量，在其他的play中同一台hosts，也可以引用**
    - name: set_fact
      set_fact: 
        var1: "{{you_name}}"
    - name: debug msg
      debug:
        msg: "you name: {{var1}}, you age: {{you_age}}, you choose {{you_choose}}"
```



###### 内置变量

```bash
#ansible_version
ansible A -m debug -a 'msg={{ansible_version}}'

#hostvars
#获取fact值
---
- name: "play 1: Gather facts of test71"
  hosts: test71
  remote_user: root
 
- name: "play 2: Get facts of test71 when operating on test70"
  hosts: test70
  remote_user: root
  tasks:
  - debug:
      msg: "{{hostvars['test71'].ansible_ens35.ipv4}}"
      
#inventory_hostname
#获取在hosts中配置的名字
ansible A -m debug -a 'msg={{inventory_hostname}}'

#play_hosts
#获取当前play操作的所有主机
ansible A -m debug -a 'msg={{play_hosts}}'

#group
#获取hosts中的分组信息
ansible A -m debug -a 'msg={{groups}}'

#group_names
#获取hosts中有A的组
ansible A -m debug -a 'msg={{group_names}}'

#inventory_dir
#获取hosts所在位置
ansible A -m debug -a 'msg={{inventory_dir}}'
```



###### include_vars

```yaml
---
- hosts: A 
  remote_user: root
  vars_files:
    - /root/varsfile
  tasks:
    - name: var1, var2
      debug: 
        msg: "{{var1}}, {{var2}}"
    - name: add var3
      lineinfile: 
        dest: /root/varsfile
        line: "var3: var3"
    #重新读取变量文件
    - include_vars: "/root/varsfile"
    #将文件中的内容赋值到变量中
    - include_vars:
        file: /root/varsfile
        name: trans_var
    #从文件夹中读取所有文件
    - include_vars:
        dir: /root/varsfile/
        #设置文件名扩展，不在的扩展后缀会报错
        extendions: [yaml, yml, json]
        #设置递归深度
        depth: 1
        #设置忽略文件
        ignore_files: ["ss.yaml"]
        name: trans_var2
    - name: var3
      debug:
        msg: "{{var3}}"
    - name: 
      debug: 
        msg: "{{trans_var.var1}}"
```





> [变量](<http://www.zsythink.net/archives/2671>)