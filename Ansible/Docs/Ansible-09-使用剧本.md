# Playbooks 

[TOC]

## 示例

```yaml
# --- 表示 yaml 文档开始
---
# 第一个场景（PLAY）
# 注意多种 host 的写法
- hosts: A,B
  remote_user: root
  # 需要执行的任务（TASK）
  tasks:
  # 为任务命名(可省略，但建议写上)
  - name: Ping the host
    # 调用的模块
    ping:
  - name: mkdir /root/test
    file:
      # 模块的参数
      path: /root/test
      state: directory

# 第 2 个场景（PLAY）
- hosts: 
    A
    B
  remote_user: root
  tasks: 
  - name: rmdir /root/test
    file:
      path: /root/test
      state: absent
```

```bash
# 检查 playbook 语法
ansible-playbook --syntax-check PLAYBOOK-FILE
# 模拟执行(-C)
ansible-playbook --check PLAYBOOK-FILE
```

## handlers

### handler 使用

```yaml
# handler 只有在任务 'changed' 后执行
# 关联同一个 handler 的 tasks 都已被执行，才会执行 handler
# 这段只有 handler1 会执行，因为 “mkdir /root/test2” 不会有 ‘changed’，因为 ansible 具有幂等性
---
- hosts: A
  remote_user: root
  tasks:
    - name: mkdir /root/test1
      file:
        path: /root/test
        state: directory
      notify: handler1
      
    # 执行以上任务的 ‘handler’
    # 默认为等待所有 tasks 完成后才执行 ‘handler’
    - meta: flush_handlers
      
    - name: mkdir /root/test2
      file: 
        path: /root/test
        state: directory
      notify: handler2

  # handler 中也可以使用 ‘notify’，调用指定的 handler
  handlers: 
    - name: handler1
      file: 
        path: /root/test/test1.txt
        state: touch
      #notify: handler2
      
    - name: handler2
      file: 
        path: /root/test/test2.txt
        state: touch
```

### handler 组

```yaml
---
- hosts: A
  remote_user: root
  tasks:
    - name: mkdir /root/test 1
      file:
        path: /root/test
        state: directory
      # 调用 handler 组
      notify: handler group
    - name: mkdir /root/test 2
      file: 
        path: /root/test
        state: directory
      notify: handler3

  # 利用 ‘listen’，设置 handler 组
  handlers: 
    - name: handler1
      listen: handler group
      file: 
        path: /root/test/test1.txt
        state: touch
    - name: handler2
      listen: handler group
      file: 
        path: /root/test/test2.txt
        state: touch
    - name: handler3
      file: 
        path: /root/test/test3.txt
        state: touch
```

## tag

```yaml
---
- hosts: C
  remote_user: root
  tasks:
    - name: mkdir /root/test 1
      file:
        path: /root/test
        state: directory
      notify: handler group
      tags: tag1,tag
    - name: mkdir /root/test 2
      file: 
        path: /root/test
        state: directory
      notify: handler3
      # 设置 tag，多个任务可以用同一个 tag
      tags: tag2,tag

  handlers: 
    - name: handler1
      listen: handler group
      file: 
        path: /root/test/test1.txt
        state: touch
    - name: handler2
      listen: handler group
      file: 
        path: /root/test/test2.txt
        state: touch
    - name: handler3
      file: 
        path: /root/test/test3.txt
        state: touch
```

```bash
# 执行 tag1,tag2 的任务
ansible-playbook --tags tag1,tag2 TAGS-FILE.yaml
# 跳过执行 tag1 的任务
ansible-playbook --skip-tags=tag1 TAG-FILE.yaml
# 列出 yaml 中的 tags
ansible-playbook --list-tags TAGS-FILE.yaml

# 特殊 tag：always，never，tagged，untagged，all
# always：无论是否指明，该任务都执行。通过“--skip-tags”可以取消执行
# never：和 always 相反
# tagged：执行有打 tag 的任务
# untagged：执行未打 tag 的任务
# all：所有任务都执行，默认 tag
```

## variable

### vars 变量

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
  # 从文件中读取，文件内容和 "vars" 类似
  # vars_files:
  #   - VARS_FILES
  tasks:
    - name: mkdir /root/test
      file:
        path: /{{ var1 }}/{{ var2 }}
        state: directory 

    - name: mkdir /tmp/text
      file: 
        # 如果在行首，需要用引号包围
        path: "{{ var3.var31 }}/{{ var3.var32 }}"
        state: touch
        # 或者使用 "="
        # path={{ var3.var31 }}/{{ var3.var32 }}
        # state=touch 
    - name: debug msg
      debug:
        # var 和 msg 选项只能 2 选 1
        # var: var2
        msg: "debug msg: {{ var3.var32 }}"
```

### facts 变量

```bash
# 显示远程主机的信息，返回 json
ansible A -m setup
# 显示以 ansible 开头的
ansible A -m setup -a 'filter=ansible*'
```

```bash
# ansible_version
ansible A -m debug -a 'msg={{ansible_version}}'

# hostvars
# 获取 fact 值
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
      
# inventory_hostname
# 获取在 hosts 中配置的名字
ansible A -m debug -a 'msg={{inventory_hostname}}'

# play_hosts
# 获取当前 play 操作的所有主机
ansible A -m debug -a 'msg={{play_hosts}}'

# group
# 获取 hosts 中的分组信息
ansible A -m debug -a 'msg={{groups}}'

# group_names
# 获取 hosts 的所属组名
ansible A -m debug -a 'msg={{group_names}}'

# inventory_dir
# 获取 inventory 所在位置
ansible A -m debug -a 'msg={{inventory_dir}}'
```

### 用户输入变量

```yaml
---
- hosts: C
  remote_user: root
  # 用户输入
  vars_prompt:
    - name: "you_name"
      prompt: "you name"
      private: no
    - name: "you_age"
      prompt: "you age"
      # 默认为不显示，private=yes
      private: yes
    - name: "you_choose"
      prompt: "
      A: A\n
      B: B\n
      C: C"
      # 默认值
      default: A
  tasks:
    - name: debug msg
      debug:
        msg: "you name: {{you_name}}, you age: {{you_age}}, you choose {{you_choose}}"
```

### 命令行变量

```bash
# 可以在 CLI 中增加变量,在 yaml 中引用
# 覆盖 yaml 中已定义的同名变量
ansible-playbook PLAYBOOK-YAML -e 'var1="123" var2="456"'

# 传入变量文件
# 内容和 vars 定义格式相同
ansible-playbook PLAYBOOK-YAML -e "@/root/test.txt"
```

### 不同 play 变量

```yaml
---
- hosts: C
  remote_user: root
  # 用户输入
  vars_prompt:
    - name: "you_name"
      prompt: "you name"
      private: no
    - name: "you_age"
      prompt: "you age"
      # 默认就是不显示
      private: yes
    - name: "you_choose"
      prompt: "
      A: A\n
      B: B\n
      C: C"
      # 默认值
      default: A
  tasks:
  # set_fact 模块可以设置变量
  # 通过 set_fact 设置的变量，在其他的 play 中同一台 hosts，也可以引用
    - name: set_fact
      set_fact: 
        var1: "{{you_name}}"
    - name: debug msg
      debug:
        msg: "you name: {{var1}}, you age: {{you_age}}, you choose {{you_choose}}"
```

### 包含变量

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
    # 重新读取变量文件
    - include_vars: "/root/varsfile"
    # 将文件中的内容赋值到变量中
    - include_vars:
        file: /root/varsfile
        name: trans_var
    # 从文件夹中读取所有文件
    - include_vars:
        dir: /root/varsfile/
        # 设置文件名扩展，不在的扩展后缀会报错
        extendions: [yaml, yml, json]
        # 设置递归深度
        depth: 1
        # 设置忽略文件
        ignore_files: ["ss.yaml"]
        name: trans_var2
    - name: var3
      debug:
        msg: "{{var3}}"
    - name: 
      debug: 
        msg: "{{trans_var.var1}}"
```

## 循环

```yaml
---
- hosts: A 
  remote_user: root
  gather_facts: no
  vars:
    dirs:
      - "/tmp/a"
      - "/tmp/b"
      - "/tmp/c"
  tasks:
    - name: debug msg
      debug: 
        msg: "{{item}}"
      with_items: "{{dirs}}"
      
# 输出
ok: [172.18.0.4] => (item=/tmp/b) => {
    "item": "/tmp/b", 
    "msg": "/tmp/b"
}
ok: [172.18.0.4] => (item=/tmp/a) => {
    "item": "/tmp/a", 
    "msg": "/tmp/a"
}
ok: [172.18.0.4] => (item=/tmp/c) => {
    "item": "/tmp/c", 
    "msg": "/tmp/c"
}
```

```yaml
---
- hosts: A 
  remote_user: root
  gather_facts: no
  vars:
    dirs:
      - "/tmp/a"
      - "/tmp/b"
      - "/tmp/c"
  tasks:
    - name: ls /root and ls /tmp
      command: "{{item}}"
      with_items: "{{dirs}}"
      register: result_var
    - name: debug msg
      debug: 
        msg: "{{item.stdout}}"
      with_items: "{{result_var.results}}"
```

```yaml
# with_items 同 with_flattened
- [1, 2, 3]
- [a, b]
# 将会在 item 中循环显示每个元素
1
2
3
a
b

# whit_list
- [1, 2, 3]
- [a, b]
# 将会显示列表
[1, 2, 3]
[a, b]

# with_together
- [1, 2, 3]
- [a, b]
# 将会上下一起显示
[1, a]
[2, b]
[3, null]

# with_cartesian(笛卡尔)
- [1, 2, 3]
- [a, b]
# 输出笛卡尔积
[1, a]
[1, b]
[2, a]
[2, b]
[3, a]
[3, b]

# with_indexed_items
- [1, 2, [3, 4]]
- [a, b]
# 将会显示索引
[0, 1]
[1, 2]
[2, [3, 4]]
[3, a]
[4, b]

# with_sequence
with_sequence: start=2 end=10 stride=2
# 将会从 2（开始）到 10（结束），每隔 2（stride）
2
4
6
8
10
# 生成连续数字
count=5
start=1 end=5 stride=1

# with_random_choice
- 1
- 2
- 3
- 4
- 5
# 随机数字
# 可能返回 1，也可能 3

# with_dict
---
- hosts: A 
  remote_user: root
  gather_facts: no
  vars:
    dirs:
      a: 1
      b: 2
  tasks: 
    - name: debug msg
      debug:
        msg: "{{item}}"
      with_dict: "{{dirs}}"
# 输出
"key": "a", 
"value": 1
# 可使用 item.key 单独获取键
"key": "b", 
"value": 2

# with_subelements
---
- hosts: A 
  remote_user: root
  gather_facts: no
  vars:
    users:
      - name: bob
        gender: male
        hobby:
          - skateboade
          - videogame
      - name: alice
        gender: female
        hobby:
          - music
  tasks:
    - name: debug msg
      debug:
        msg: "{{item.0.name}} like {{item.1}}"
      with_subelements:
        - "{{users}}"
        - hobby
# 输出
"msg": "bob like videogame"
"msg": "bob like skateboade"
"msg": "alice like music"

# with_file(获取文件中的内容，文件在 ansible 机器中)
# with_fileglob(匹配文件，如 /root/*，获取的是 ansible 机器)
```

## 判断

### when

```yaml
---
- hosts: A
  remote_user: root
  tasks:
    - name: ls /root
      shell: 
        ls /root
      register: return_result
    - name: debug msg
      debug:
        msg: "成功执行"
      # when 相当于 if
      when: return_result.rc == 0
```

### test

```yaml
---
- hosts: A
  remote_user: root
  vars:
    dir: /root/test
  tasks:
    - name: debug msg 1
      debug: 
        msg: "YES"
      # 文件存在执行
      when: dir is exists 
    - name: debug msg 2
      debug: 
        msg: "NO"
      # 文件不存在执行
      when: not dir is exists  
```

```bash
# 测试 test 变量
defined(已定义)
undefined(未定义)
null（空值）

# 执行结果
success或succeeded（执行成功）
failure或failed（执行失败）
change或chenged（执行返回 changed）
skip或skipped（跳过的任务）

# 路径
file（是否为文件）
directory（是否为目录）
link（是否为连接）
mount（是否为挂载点）
is_exists或exists（是否存在）

# 字符串
lower（是否全为小写）
upper（是否全为大写）

# 数字类型
even（是否为偶数）
odd（是否为奇数）
divisibleby(num)（是否可以整数，如果返回 0，则为真）

# 比较操作符 := gt, ge, lt, le, eq, ne
version('版本号', '比较操作符')
version("7", 'gt')

a is subset(b)(a 是否为 b 子集)
a is superset(b)(a 是否为 b 超集)

string（是否为字符串）
number（是否为数字）
```

### block

```yaml
--- 
- hosts: A
  remote_user: root
  tasks: 
    - name: block 1
      debug: 
        msg: "block 1"
    - block: 
      - name: block 2.1
        debug: 
          msg: "block 2.1"
      - name: block 2.2
        debug: 
          msg: "block 2.2"
      when: YES  
# 输出
block 1
block 2.1
block 2.2
```

```yaml
---
- hosts: A
  remote_user: root
  tasks: 
    - name: ls /root/test
      shell: 
        ls /root/test
      register: return_valus
      ignore_errors: true
    - name: debug msg
      debug: 
        msg: "have a error"
      # shell 执行失败
      when: return_valus.rc != 0
```

```yaml
---
- hosts: A
  remote_user: root
  tasks: 
    - block: 
      - name: ls /root/sss
        shell: ls /root/sss
      - name: ls /tmp
        shell: ls /tmp
      # 如果上述任务有错误，就会执行 rescue 中代码
      # block 中，错误 task 后的 task 不会执行
      rescue: 
        - name: debug msg
          debug:
            msg: "have a error"
```

```yaml
---
- hosts: A
  remote_user: root
  tasks: 
    - block: 
      - name: ls /root
        shell: ls /root
      - name: false
        command: /bin/false
      - name: ls /tmp
        shell: ls /tmp
      rescue: 
        - name: debug msg 1 
          debug:
            msg: "rescue 1"
        - name: debug msg 2
          debug:
            msg: "rescue 2"
      # 无论失败还是成功，always 都会执行
      always: 
        - name:
          debug:
            msg: "always" 
```

```yaml
---
- hosts: A
  remote_user: root
  tasks: 
    - block: 
      - name: echo "error"
        shell:
          echo "error"
        register: return_values
      # fail 模块相当于 exit
      - name: fail
        fail:
          msg: "fail text"
        # "string" in "string"
        # in 判断是否在字符串内
        when: '"error" in return_values.stdout'
      - name: debug msg 1
        debug:  
          msg: "debug msg 1"
          
# failed_when
# failed_when 条件成立时，对应的任务状态就为失败
# 任务会执行，只是影响返回的状态
# changed_when
# 对应的任务状态为 changed
# 当将'changed_when'直接设置为 false 时，对应任务的状态将不会被设置为'changed'，如果任务原本的执行状态为'changed'，最终则会被设置为'ok'，所以，上例 playbook 执行后，shell 模块的执行状态最终为'ok'
```

## 过滤

### 字符相关

```yaml
---
- hosts: A 
  remote_user: root
  vars:
    - var1: "abcdefg"
    - var2: "ABCDEFG"
    - var3: "   123 "
  tasks:
    - name: "将字符串变成大写"
      debug: 
        msg: "{{ var1|upper }}"
    - name: "将字符串变成小写"
      debug: 
        msg: "{{ var2|lower }}"
    - name: "首字母变成大写"
      debug:
        msg: "{{ var1|capitalize }}"
    - name: "将字符串反转"
      debug:
        msg: "{{ var1|reverse }}"
    - name: "输出字符串的第一个字母"
      debug:
        msg: "{{ var1|first }}"
    - name: "输出字符串的最后一个字母"
      debug: 
        msg: "{{ var1|last }}"
    - name: "将字符串开头和末尾的空格删除"
      debug:
        msg: "{{ var3|trim }}"
    - name: "将字符串放在中间，左右用空格填充至指定长度"
      debug:
        msg: "{{ var1|center(width=30) }}"
    - name: "输出字符串长度"
      debug:
        msg: "{{ var1|length }}"
    - name: "将字符串转化为列表"
      debug: 
        msg: "{{ var1|list }}"
    - name: "打乱字符串的顺序"
      debug:
        msg: "{{ var1|shuffle }}"
```

### 数字相关

```yaml
---
- hosts: A 
  remote_user: root
  tasks:
    - name: "将字符串转为int"
      debug: 
        msg: "{{ 8+('-4'|int) }}"
    - name: "如果无法转换，就返回默认数值"
      debug: 
        msg: "{{ 8+('a'|int(default=6)) }}"
    - name: "将字符串转为float"
      debug:
        msg: "{{ '8'|float }}"
    - name: "如果无法转换float，就返回默认数值"
      debug:
        msg: "{{ 'a'|float(8.8) }}"
    - name: "绝对值"
      debug:
        msg: "{{ 12.4|abs }}"
    - name: "四舍五入"
      debug: 
        msg: "{{ 8.8|round }}"
    - name: "取小数点位数"
      debug:
        msg: "{{ 3.1415926|round(3) }}"
    - name: "从5到100返回随机数,步长5"
      debug:
        msg: "{{ 100|random(start=5, step=5) }}"
```

### 列表相关

```yaml
---
- hosts: A 
  remote_user: root
  vars:
    var1: [11, 18, 2, 22, 33, 54]
    var2: [1, [2, 3, [4, 5], 6], 7]
    var3: [1, 'a', 3, 1]
  tasks:
    - name: "返回列表长度"
      debug: 
        msg: "{{ var1|length }}"
    - name: "返回第一个值"
      debug: 
        msg: "{{ var1|first }}"
    - name: "最后一个值"
      debug:
        msg: "{{ var1|last }}"
    - name: "最小的值"
      debug:
        msg: "{{ var1|min }}"
    - name: "最大的值"
      debug:
        msg: "{{ var1|max }}"
    - name: "倒序"
      debug: 
        msg: "{{ var1|sort(reverse=true) }}"
    - name: "求和"
      debug:
        msg: "{{ var1|sum }}"
    - name: "合并成字符串"
      debug:
        msg: "{{ var2|join(',') }}"
    - name: "随机返回元素"
      debug:
        msg: "{{ var2|random }}"
    - name: "乱序"
      debug:
        msg: "{{ var2|shuffle }}"
    - name: "去除重复"
      debug:
        msg: "{{ var3|unique }}"
    - name: "并集"
      debug:
        msg: "{{ var1|union(var3) }}"
    - name: "交集"
      debug:
        msg: "{{ var1|intersect(var3) }}"
    - name: "补集"
      debug:
        msg: "{{ var1|difference(var3) }}"
    - name: "交集取反"
      debug:
        msg: "{{ var1|symmetric_difference(var3) }}"
```

### 默认值

```yaml
---
- hosts: A 
  remote_user: root
  vars:
    paths: 
      - path: /tmp/test1
        mode: '0111'
      - path: /tmp/test2
      - path: /tmp/test3
  tasks:
    - file: 
        dest: "{{ item.path }}"
        state: touch
        # 通过 default，设置默认值
        # omit 代表省略
        mode: "{{ item.mode|default(omit) }}"
      with_items: "{{ paths }}"
```

### 分析 json

```yaml
---
- hosts: A 
  remote_user: root
  tasks:
    - name: read log
      include_vars: 
        file: /root/test.log
        name: test_log
    - name: cat log
      debug: 
        # item.0 是 test_log.logs 中的元素
        # item.1 是 test_log.logs.files 中的元素
        msg: "{{item.0.domainName}} logUrl is {{item.1.logUrl}}"
      with_subelements:
        - "{{test_log.logs}}"
        # 相当与过滤
        - files
    - name: 直接使用 json_query 显示 logUrl
      debug: 
        msg: "{{item}}"
      with_items: "{{ test_log | json_query('logs[*].files[*].logUrl')}}"
    
    # ansible主机需要python-jmespath包支持
    - name: json_query domainName
      debug:
        msg: "{{test_log | json_query('logs[*].domainName')}}"
    - name: 将 domainName 在 msg 中显示 dn
   debug:  
        msg: "{{ test_log | json_query('logs[*].{dn:domainName}') }}"
```

### 常用

```yaml
---
- hosts: test70
  remote_user: root
  gather_facts: no
  tasks:
  ######################################################################
  # 在调用 shell 模块时，如果引用某些变量时需要添加引号，则可以使用 quote 过滤器代替引号
  # 示例如下，先看示例，后面会有注解
  - shell: "echo {{teststr | quote}} > /testdir/testfile"
    vars:
      teststr: "a\nb\nc"
  # 上例中 shell 模块的写法与如下写法完全等效
  # shell: "echo '{{teststr}}' > /testdir/testfile"
  # 没错，如你所见，quote 过滤器能够代替引号
  # 上例中，如果不对 {{teststr}} 添加引号，则会报错，因为 teststr 变量中包含"\n"转义符
  ######################################################################
  # ternary 过滤器可以实现三元运算的效果 示例如下
  # 如下示例表示如果 name 变量的值是 John，那么对应的值则为 Mr,否则则为 Ms
  # 简便的实现类似 if else 对变量赋值的效果
  - debug: 
      msg: "{{ (name == 'John') | ternary('Mr','Ms') }}"
    vars:
      name: "John"
  ######################################################################
  # basename 过滤器可以获取到一个路径字符串中的文件名
  - debug:
      msg: "{{teststr | basename}}"
    vars:
      teststr: "/testdir/ansible/testfile"
  ######################################################################
  # 获取到一个 windows 路径字符串中的文件名,2.0 版本以后的 ansible 可用
  - debug:
      msg: "{{teststr | win_basename}}"
    vars:
      teststr: 'D:\study\zsythink'
  ######################################################################
  # dirname 过滤器可以获取到一个路径字符串中的路径名
  - debug:
      msg: "{{teststr | dirname}}"
    vars:
      teststr: "/testdir/ansible/testfile"
  ######################################################################
  # 获取到一个 windows 路径字符串中的文件名,2.0 版本以后的 ansible 可用
  - debug:
      msg: "{{teststr | win_dirname}}"
    vars:
      teststr: 'D:\study\zsythink'
  ######################################################################
  # 将一个 windows 路径字符串中的盘符和路径分开,2.0 版 本以后的 ansible 可用
  - debug:
      msg: "{{teststr | win_splitdrive}}"
    vars:
      teststr: 'D:\study\zsythink'
  # 可以配合之前总结的过滤器一起使用，比如只获取到盘符，示例如下
  # msg: "{{teststr | win_splitdrive | first}}"
  # 可以配合之前总结的过滤器一起使用，比如只获取到路径，示例如下
  # msg: "{{teststr | win_splitdrive | last}}"
  ######################################################################
  #realpath过滤器可以获取软链接文件所指向的真正文件
  - debug:
      msg: "{{ path | realpath }}"
    vars:
      path: "/testdir/ansible/testsoft"
  ######################################################################
  # relpath 过滤器可以获取到 path 对于“指定路径”来说的“相对路径”
  - debug:
      msg: "{{ path | relpath('/testdir/testdir') }}"
    vars:
      path: "/testdir/ansible"
  ######################################################################
  # splitext 过滤器可以将带有文件名后缀的路径从“.后缀”部分分开
  - debug:
      msg: "{{ path | splitext }}"
    vars:
      path: "/etc/nginx/conf.d/test.conf"
  # 可以配置之前总结的过滤器，获取到文件后缀
  # msg: "{{ path | splitext | last}}"
  # 可以配置之前总结的过滤器，获取到文件前缀名
  # msg: "{{ path | splitext | first | basename}}"
  ######################################################################
  # to_uuid 过滤器能够为对应的字符串生成 uuid
  - debug:
      msg: "{{ teststr | to_uuid }}"
    vars:
      teststr: "This is a test statement" 
  ######################################################################
  # bool 过滤器可以根据字符串的内容返回 bool 值 true 或者 false
  # 字符串的内容为 yes、1、True、true 则返回布尔值 true，字符串内容为其他内容则返回 false
  - debug:
      msg: "{{ teststr | bool }}"
    vars:
      teststr: "1"
  # 当和用户交互时，有可能需要用户从两个选项中选择一个，比如是否继续，
  # 这时，将用户输入的字符串通过 bool 过滤器处理后得出布尔值，从而进行判断，比如如下用法
  # - debug:
  #     msg: "output when bool is true"
  #   when: some_string_user_input | bool
  ######################################################################
  # map过滤器可以从列表中获取到每个元素所共有的某个属性的值，并将这些值组成一个列表
  # 当列表中嵌套了列表，不能越级获取属性的值，也就是说只能获取直接子元素的共有属性值。
  - vars:
      users:
      - name: tom
        age: 18
        hobby:
        - Skateboard
        - VideoGame
      - name: jerry
        age: 20
        hobby:
        - Music
    debug:
      msg: "{{ users | map(attribute='name') | list }}"
  # 也可以组成一个字符串，用指定的字符隔开，比如分号
  # msg: "{{ users | map(attribute='name') | join(';') }}"
  ######################################################################
  # 与 python 中的用法相同，两个日期类型相减能够算出两个日期间的时间差
  # 下例中，我们使用 to_datatime 过滤器将字符串类型转换成了日期了类型，并且算出了时间差
  - debug:
      msg: '{{ ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 19:00:00" | to_datetime) }}'
  # 默认情况下，to_datatime 转换的字符串的格式必须是 “%Y-%m-%d %H:%M:%S”
  # 如果对应的字符串不是这种格式，则需要在 to_datetime 中指定与字符串相同的时间格式，才能正确的转换为时间类型
  - debug:
      msg: '{{ ("20160814"| to_datetime("%Y%m%d")) - ("2012-12-25 19:00:00" | to_datetime) }}'
  # 如下方法可以获取到两个日期之间一共相差多少秒
  - debug:
      msg: '{{ ( ("20160814"| to_datetime("%Y%m%d")) - ("20121225" | to_datetime("%Y%m%d")) ).total_seconds() }}'
  # 如下方法可以获取到两个日期“时间位”相差多少秒，注意：日期位不会纳入对比计算范围
  # 也就是说，下例中的 2016-08-14和2012-12-25 不会纳入计算范围
  # 只是计算 20:00:12 与 08:30:00 相差多少秒
  # 如果想要算出连带日期的秒数差则使用 total_seconds()
  - debug:
      msg: '{{ ( ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 08:30:00" | to_datetime) ).seconds }}'
  # 如下方法可以获取到两个日期“日期位”相差多少天，注意：时间位不会纳入对比计算范围
  - debug:
      msg: '{{ ( ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 08:30:00" | to_datetime) ).days }}'
  ######################################################################
  # 使用 base64 编码方式对字符串进行编码
  - debug:
      msg: "{{ 'hello' | b64encode }}"
  # 使用 base64 编码方式对字符串进行解码
  - debug:
      msg: "{{ 'aGVsbG8=' | b64decode }}"
  #######################################################################
  # 使用 sha1 算法对字符串进行哈希
  - debug:
      msg: "{{ '123456' | hash('sha1') }}"
  # 使用 md5 算法对字符串进行哈希
  - debug:
      msg: "{{ '123456' | hash('md5') }}"
  # 获取到字符串的校验和,与 md5 哈希值一致
  - debug:
      msg: "{{ '123456' | checksum }}"
  # 使用 blowfish 算法对字符串进行哈希，注:部分系统支持
  - debug:
      msg: "{{ '123456' | hash('blowfish') }}"
  # 使用 sha256 算法对字符串进行哈希,哈希过程中会生成随机"盐",以便无法直接对比出原值
  - debug:
      msg: "{{ '123456' | password_hash('sha256') }}"
  # 使用 sha256 算法对字符串进行哈希,并使用指定的字符串作为"盐"
  - debug:
      msg: "{{ '123456' | password_hash('sha256','mysalt') }}"
  # 使用 sha512 算法对字符串进行哈希,哈希过程中会生成随机"盐",以便无法直接对比出原值
  - debug:
      msg: "{{ '123123' | password_hash('sha512') }}"
  # 使用 sha512 算法对字符串进行哈希,并使用指定的字符串作为"盐"
  - debug:
      msg: "{{ '123123' | password_hash('sha512','ebzL.U5cjaHe55KK') }}"
  # 如下方法可以幂等的为每个主机的密码生成对应哈希串
  # 有了之前总结的过滤器用法作为基础，你一定已经看懂了
  - debug:
      msg: "{{ '123123' | password_hash('sha512', 65534|random(seed=inventory_hostname)|string) }}"
```

## include

### include

```yaml
---
- hosts: A
  remote_user: root
  gather_facts: no
  tasks:
    - name: msg 1
      debug: 
        msg: "msg 1"
    - name: touch /tmp/test
      file: 
        path: /tmp/test 
        state: touch
      notify: touch /tmp/test
    - name: mkdir /tmp/test
      file: 
        path: /tmp/test
        state: directory
      notify: mkdir /tmp/test

  handlers:
    - name: touch /tmp/test
      # 引入另一个 playbook
      include: include.yaml
      # 判断是否执行 playbook
      when: 2 < 1
      # 传递变量
      vars: 
        var:
          var1: var1
          var2: var2
          var3: var3

    - name: mkdir /tmp/test
      include: include2.yaml
      loop: 
        - "1"
        - "2"
      # loop_control 不设置，include 的 playbook 的 item 使用内层循环
      loop_control:
        loop_var: outer_item

# include.yaml
- name: msg 2
  debug:
    msg: "msg 2"
- name: msg 3
  debug:
    msg: "{{ vars.var.var3 }}"
- name: msg 4
  debug:
    msg: "{{ item }}"
  with_items: "{{ var }}"
 
# include2.yaml
- name: debug 
  debug:  
    # outer_item 外层变量【1，2】，item 内层变量【a，b】
    msg: "{{ outer_item }} -- {{ item }} include2.yaml"
  loop: 
    - a
    - b
```

### include_tasks

`include_tasks`和`include`基本相同，但是涉及到 `tag`标签，有所不同。详情见[ansible笔记（37）：include（二）](<http://www.zsythink.net/archives/2977>)。

### import_tasks

> "import_tasks" 是静态的，"include_tasks" 是动态的。
> "静态"的意思就是被 include 的文件在 playbook 被加载时就展开了（是预处理的）。
> "动态"的意思就是被 include 的文件在 playbook 运行时才会被展开（是实时处理的）。
> 由于"include_tasks"是动态的，所以，被 include 的文件的文件名可以使用任何变量替换。
> 由于"import_tasks"是静态的，所以，被 include 的文件的文件名不能使用动态的变量替换。
>
> 1. 循环
>    使用"loop"关键字或"with_items"关键字对 include 文件进行循环操作时，只能配合"include_tasks"才能正常运行。
>
> 2. when判断
>    当对"include_tasks"使用 when 进行条件判断时，when 对应的条件只会应用于"include_tasks"任务本身，当执行被包含的任务时，不会对这些被包含的任务重新进行条件判断。
>    当对"import_tasks"使用when进行条件判断时，when 对应的条件会应用于被 include 的文件中的每一个任务，当执行被包含的任务时，会对每一个被包含的任务进行同样的条件判断。
>
> 3. tag
>    与"include_tasks"不同，当为"import_tasks"添加标签时，tags 是针对被包含文件中的所有任务生效的，与"include"关键字的效果相同。
>
> 4. handers
>    "include_tasks"与"import_tasks"都可以在 handlers 中使用，并没有什么不同

### include_playbook

> 使用"include"引用整个playbook，在之后的版本中，如果想要引入整个 playbook，则需要使用"import_playbook"模块代替"include"模块，因为在 2.8 版本以后，使用"include"关键字引用整个 playbook 的特性将会被弃用。

## Template

### template

```bash
ansible-doc -s template

# dest：复制到被控主机的目的地
# owner：复制到被控主机的属主
# group：复制到被控主机的属组
# mode：权限，如 mode=0644
# force：强制复制到被控主机，覆盖同名文件
# backup：备份被控主机的同名文件
```

### jinja

```bash
{{   }}：用来装载表达式，比如变量、运算表达式、比较表达式等。
# {{ ansible.host }} 172.16.0.1

# {{ 1 == 1 }}  True
# {{ 2 != 2 }}  False
# {{ 2 > 1 }}   True
# {{ (2 > 1) or (1 > 2) }} True

# {{ 3 + 2 }}    5
# {{ 3 - 4 }}    -1
# {{ 3 * 5 }}    15
# {{ 2 ** 3 }}   8
# {{ 7 / 5 }}    1.4
# {{ 7 // 5 }}   1
# {{ 17 % 5 }}   2
# {{ 1 in [1,2,3,4] }}  True

### str
{{ 'testString' }}   testString
{{ "testString" }}   testString
### num
{{ 15 }}     15
{{ 18.8 }}   18.8
### list
{{ ['Aa','Bb','Cc','Dd'] }}      ['Aa','Bb','Cc','Dd']
{{ ['Aa','Bb','Cc','Dd'].1 }}     Bb
{{ ['Aa','Bb','Cc','Dd'][1] }}    Bb
### tuple
{{ ('Aa','Bb','Cc','Dd') }}      ('Aa','Bb','Cc','Dd')
{{ ('Aa','Bb','Cc','Dd').0 }}     Aa
{{ ('Aa','Bb','Cc','Dd')[0] }}    Aa
### dic
{{ {'name':'bob','age':18} }}           {'name':'bob','age':18}
{{ {'name':'bob','age':18}.name }}       bob
{{ {'name':'bob','age':18}['name'] }}    bob

# {{ 'abc' | upper }}            ABC
# {{ testvar1 is defined }}      True
# {{ testvar1 is undefined }}    False
# {{ '/opt' is exists }}         True
# {{ '/opt' is file }}           False
# {{ '/opt' is directory }}      True

# {{ lookup('env','PATH') }}    /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

{#   #}：用来装载注释，模板文件被渲染后，注释不会包含在最终生成的文件中。
```

```bash
{%   %}：用来装载控制语句，比如 if 控制结构，for 循环控制结构。

# {% if 条件 %}
# ...
# {% elif %}
# ...
# {% else %}
# ...
# {% endif %}

# <do something> if <something is true> else <do something else>
{{ 'a' if 2>1 else 'b' }}   a

# 设置变量
# {% set teststr='abc' %}
# {{ teststr }}

# {% for 迭代变量 in 可迭代对象 %}
# {{ 迭代变量 }}
# {% endfor %}
# 每次循环后都会自动换行，如果不想要换行，在 for 的结束控制符"%}"之前添加了减号"-",在endfor的开始控制符"{%"之后添加到了减号"-"
{% for i in [3,1,7,8,2] -%}
{{ i }}{{' '}}{{ loop.index }}  #或{{i~' '~loop.index}}表示join
{%- endfor %}
3 1 7 8 2 

loop.index     当前循环操作为整个循环的第几次循环，序号从 1 开始
loop.index0    当前循环操作为整个循环的第几次循环，序号从 0 开始
loop.revindex  当前循环操作距离整个循环结束还有几次，序号到 1 结束
loop.revindex0 当前循环操作距离整个循环结束还有几次，序号到 0 结束
loop.first     当操作可迭代对象中的第一个元素时，此变量的值为 true
loop.last      当操作可迭代对象中的最后一个元素时，此变量的值为 true
loop.length    可迭代对象的长度
loop.depth     当使用递归的循环时，当前迭代所在的递归中的层级，层级序号从 1 开始
loop.depth0    当使用递归的循环时，当前迭代所在的递归中的层级，层级序号从 0 开始
loop.cycle()   这是一个辅助函数，通过这个函数我们可以在指定的一些值中进行轮询取值

# 1,3,5,7，但不包括 9
{% for i in range(1,9,2) if i > 3 %}
  {{ i }}
{%else%}
  {{ i }}
{% endfor %}

### loop.cycle()
{% set userlist=['Naruto','Kakashi','Sasuke','Sakura','Lee','Gaara','Itachi']  %}
{% for u in userlist %}
  {{ u ~'----'~ loop.cycle('team1','team2','team3')}}
{%endfor%}
Naruto----team1
Kakashi----team2
Sasuke----team3
Sakura----team1
Lee----team2
Gaara----team3
Itachi----team1

# include，默认引入上下文环境
# 引入另一个模板，without context：不引入对应的上下文
{% include 'test1.j2' without context %}
# 在指定包含的文件不存在时，自动忽略包含对应的文件
{% include 'test2.j2' ignore missing with context %}

# import，默认不引入上下文环境
# 引入另一个模板的所有宏，**with context同时引入上下文**
{% import 'function_lib.j2' as funclib with context %}
# 使用宏函数
{{ funclib.testfunc(1,2,3) }}
# 引入另一个模板的特定宏
{% from 'function_lib.j2' import testfunc as tf, testfunc1 as tf1  %}
{{ tf(1,2) }}
{{ tf1('a') }}
```

### 转义

```bash
# 置于''中
{{  '{{' }}
{{  '}}' }}
{{ '{{ test string }}' }}
{{ '{% test string %}' }}
{{ '{# test string #}' }}

# 置于 {{raw}} 中
{% raw %}
  {{ test }}
  {% test %}
  {# test #}
  {% if %}
  {% for %}
{% endraw %}
```

### 宏

```bash
# 定义
{% macro testfunc() %}
  test string
{% endmacro %}
# 使用
{{ testfunc() }}

# varargs
{% macro testfunc(testarg1=1,testarg2=2) %}
  test string
  {{testarg1}}
  {{testarg2}}
  # varargs 接受多传入的参数
  {{varargs}}
{% endmacro %}
 
{{ testfunc('a','b','c','d','e') }} 
# test string
# a
# b
# ('c', 'd', 'e')

# kwargs
{% macro testfunc(tv1='tv1') %}
  test string
  {{varargs}}
  # 构成字典
  {{kwargs}}
{% endmacro %}
 
{{ testfunc('a',2,'test',testkeyvar='abc') }}
# test string
# (2, 'test')
# {'testkeyvar': 'abc'}

# caller()
{% macro testfunc() %}
  test string
  {{caller()}}
{% endmacro %}
 
{%call testfunc()%}
something~~~~~
something else~~~~~
{%endcall%}

# test string
# something~~~~~
# something else~~~~~

name属性：宏的名称。
arguments属性：宏中定义的所有参数的参数名，这些参数名组成了一个元组存放在 arguments 中。
defaults属性：宏中定义的参数如果有默认值，这些默认值组成了一个元组存放在 defaults 中。
catch_varargs属性：如果宏中使用了 varargs 变量，此属性的值为 true。
catch_kwargs属性： 如果宏中使用了 kwargs 变量，此属性的值为 true。
caller属性：如果宏中使用了 caller 变量，此属性值为 true。

# **私有宏，不能被引入到其他的模板中**
{% macro _test() %}
something in test macro
{% endmacro %}
 
{{_test()}}
```

## Galaxy

### 安装

```bash
# 修改安装路径，指定版本
ansible-galaxy install [--roles-path ~/.ansible/roles] username.rolename[, v1.0.0]
# 通过 git 方式
ansible-galaxy install git+https://github.com/geerlingguy/ansible-role-apache.git,0b7cd353c0250e87a26e0499e59e7fd265cc2f25
# 通过文件方式
ansible-galaxy install -r requirements.yml

# 默认路径,可通过 ansible.cfg 修改
# /etc/ansible/roles:~/.ansible/roles
```

### requirements

```yaml
# from galaxy
- src: yatesr.timezone

# from GitHub
- src: https://github.com/bennojoy/nginx

# from GitHub, overriding the name and specifying a specific tag
- src: https://github.com/bennojoy/nginx
  version: master
  name: nginx_role

# from a webserver, where the role is packaged in a tar.gz
- src: https://some.webserver.example.com/files/master.tar.gz
  name: http-role

# from Bitbucket
- src: git+http://bitbucket.org/willthames/git-ansible-galaxy
  version: v1.4

# from Bitbucket, alternative syntax and caveats
- src: http://bitbucket.org/willthames/hg-ansible-galaxy
  scm: hg

# from GitLab or other git-based scm
- src: git@gitlab.company.com:mygroup/ansible-base.git
  scm: git
  version: "0.1"  # quoted, so YAML doesn't parse this as a floating-point value
 
# 依赖于其他角色
dependencies:
 - src: geerlingguy.ansible
 - src: git+https://github.com/geerlingguy/ansible-role-composer.git
   version: 775396299f2da1f519f0d8885022ca2d6ee80ee8
   name: composer
```

### 创建 Role

```bash
# force:如果当前工作目录中存在与该角色名称相匹配的目录，则 init 命令将忽略该错误.
# force将创建上述子目录和文件，替换匹配的任何内容。
# container-enabled:创建目录结构，但使用适用于启用 Container 的默认文件填充它。 例如，README.md 具有稍微不同的结构， .travis.yml 文件使用 Ansible Container 来测试角色，而 meta 目录包含一个 container.yml 文件。
ansible-galaxy init role_name

# 默认目录结构
  .
  ├── README.md
  ├── defaults
  │   └── main.yml
  ├── files
  ├── handlers
  │   └── main.yml
  ├── meta
  │   └── main.yml
  ├── tasks
  │   └── main.yml
  ├── templates
  ├── tests
  │   ├── inventory
  │   └── test.yml
  └── vars
      └── main.yml
```

### 操作Role

```bash
# 搜索 role
ansible-galaxy search role_name --author author_name
# 显示 role 详细信息
ansible-galaxy info username.role_name
# 显示安装的 role 及版本
ansible-galaxy list
# 删除 role
ansible-galaxy remove username.rolename
```

<br/>

> [初识 playbook](http://www.zsythink.net/archives/2602)
>
> [handler 详解](<http://www.zsythink.net/archives/2624>)
>
> [变量](http://www.zsythink.net/archives/2671)
>
> [循环](http://www.zsythink.net/archives/2728)
>
> [判断](<http://www.zsythink.net/archives/2846>)
>
> [ansible过滤器](http://www.zsythink.net/archives/2862)
>
> [include](http://www.zsythink.net/archives/2962)
>
> [jinja2 模板](https://www.zsythink.net/archives/2999)
>
> [ansible-galaxy 官网](<https://galaxy.ansible.com/>)
>
> [Ansible Galaxy 使用小记](https://segmentfault.com/a/1190000004419028)
>
> [ANSIBLE GALAXY](https://www.cnblogs.com/mhc-fly/p/7119832.html)