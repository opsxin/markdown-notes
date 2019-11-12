# Templating(Jinja2)

正如变量部分中已经提到的，Ansible 使用 Jinja2 模板来使用动态表达式和访问变量。Ansible 大大扩展了可用的过滤器，并添加了新的插件类型：查找（lookups）。

请注意，在 Ansible 控制器上进行所有模板替换。这样做是为了最大程度地减少对目标主机的要求（仅在控制器上需要 jinja2），并且能够传递任务所需的最少信息，因此目标主机不需要控制器具有的所有数据的副本。

[TOC]

## 格式化数据的过滤器

### 以不同格式显示

```jinja2
{{ some_variable | to_json }}
{{ some_variable | to_yaml }}
```

人类可读：

```jinja2
{{ some_variable | to_nice_json }}
{{ some_variable | to_nice_yaml }}
```

更改缩进：

```jinja2
{{ some_variable | to_nice_json(indent=2) }}
{{ some_variable | to_nice_yaml(indent=8) }}
```

### 阅读已经格式化的数据

```jinja2
{{ some_variable | from_json }}
{{ some_variable | from_yaml }}
```

例如：

```yaml
tasks:
  - shell: cat /some/path/to/file.json
    register: result

  - set_fact:
      myvar: "{{ result.stdout | from_json }}"
```

解析多文档 yaml 字符串，使用`from_yaml_all`过滤器：

```yaml
tasks:
  - shell: cat /some/path/to/multidoc-file.yaml
    register: result
 - debug:
     msg: '{{ item }}'
  loop: '{{ result.stdout | from_yaml_all | list }}'
```

## 未定义变量默认值（default）

```jinja2
{{ some_variable | default(5) }}
```

如果未定义变量`some_variable`，则使用的值为 5，而不是抛出错误。

如果要在变量评估为 false 或为空字符串时使用默认值，则必须将第二个参数设置为 true：

```jinja2
{{ lookup('env', 'MY_USER') | default('admin', true) }}
```

## 省略参数（omit）

```yaml
- name: touch files with an optional mode
  file: dest={{ item.path }} state=touch mode={{ item.mode | default(omit) }}
  loop:
    - path: /tmp/foo
    - path: /tmp/bar
    - path: /tmp/baz
      mode: "0444"
```

对于列表中的前两个文件，默认 mode 将由系统的 umask 决定。

## 列表过滤

### 最小数

```jinja2
{{ list1 | min }}
```

### 最大数

```jinja2
{{ [3, 4, 2] | max }}
```

### 展开列表

```jinja2
{{ [3, [4, 2] ] | flatten }}
```

只展开一级列表：

```jinja2
{{ [3, [4, [2]] ] | flatten(levels=1) }}
```

## 集合过滤

### 列表中唯一值

```jinja2
{{ list1 | unique }}
```

### 两个列表并集

```jinja2
{{ list1 | union(list2) }}
```

### 两个列表交集

```jinja2
{{ list1 | intersect(list2) }}
```

### 两个列表的差异

1 中存在，2 中没有：

```jinja2
{{ list1 | difference(list2) }}
```

### 两个列表的对称差异

每个列表的独特项：

```jinja2
{{ list1 | symmetric_difference(list2) }}
```

## 字典过滤

### 字典到项目元素

```jinja2
{{ dict | dict2items }}
```

从：

```yaml
tags:
  Application: payment
  Environment: dev
```

到：

```yaml
- key: Application
  value: payment
- key: Environment
  value: dev
```

### 项目元素到字典

```jinja2
{{ tags | items2dict }}
```

从：

```yaml
tags:
  - key: Application
    value: payment
  - key: Environment
    value: dev
```

到：

```yaml
Application: payment
Environment: dev
```

 `items2dict`  支持参数：

```jinja2
{{ tags | items2dict(key_name='key', value_name='value') }}
```

## 打包过滤（zip）

### 打包

```yaml
- name: give me list combo of two lists
  debug:
   msg: "{{ [1,2,3,4,5] | zip(['a','b','c','d','e','f']) | list }}"

- name: give me shortest combo of two lists
  debug:
    msg: "{{ [1,2,3] | zip(['a','b','c','d','e','f']) | list }}"
```

### 用尽所有元素

其他列表不够，使用 `fillvalue`填充：

```yaml
- name: give me longest combo of three lists , fill with X
  debug:
    msg: "{{ [1,2,3] | zip_longest(['a','b','c','d','e','f'], [21, 22, 23], fillvalue='X') | list }}"
```

### 快速生成字典

`items2dict` 和 `dict`：

```jinja2
{{ dict(keys_list | zip(values_list)) }}
```

从：

```yaml
list_one:
  - one
  - two
list_two:
  - apple
  - orange
```

到：

```yaml
one: apple
two: orange
```

## 子元素过滤

生成一个对象的乘积和该对象的子元素值：

```jinja2
{{ users | subelements('groups', skip_missing=True) }}
```

从：

```yaml
users:
  - name: alice
    authorized:
      - /tmp/alice/onekey.pub
      - /tmp/alice/twokey.pub
    groups:
      - wheel
      - docker
  - name: bob
    authorized:
      - /tmp/bob/id_rsa.pub
    groups:
      - docker
```

到：

```yaml
-
  - name: alice
    groups:
      - wheel
      - docker
    authorized:
      - /tmp/alice/onekey.pub
  - wheel
-
  - name: alice
    groups:
      - wheel
      - docker
    authorized:
      - /tmp/alice/onekey.pub
  - docker
-
  - name: bob
    authorized:
      - /tmp/bob/id_rsa.pub
    groups:
      - docker
  - docker
```

使用 `loop`过滤：

```yaml
- name: Set authorized ssh key, extracting just that data from 'users'
  authorized_key:
    user: "{{ item.0.name }}"
    key: "{{ lookup('file', item.1) }}"
  loop: "{{ users | subelements('authorized') }}"
```

## 随机 Mac 地址

```jinja2
"{{ '52:54:00' | random_mac }}"
# => '52:54:00:ef:1c:03'
```

## 随机数

```jinja2
"{{ ['a','b','c'] | random }}"
# => 'c'
```

```jinja2
{{ 101 | random(step=10) }}
# => 70
```

```jinja2
{{ 101 | random(1, 10) }}
# => 31
{{ 101 | random(start=1, step=10) }}
# => 51
```

```jinja2
"{{ 60 | random(seed=inventory_hostname) }} * * * * root /script/from/cron"
```

从种子中初始化随机数生成器。这样，您可以创建**随机但幂等**的数字。

## 随机过滤

```jinja2
{{ ['a','b','c'] | shuffle }}
# => ['c','a','b']
{{ ['a','b','c'] | shuffle }}
# => ['b','c','a']
```

```jinja2
{{ ['a','b','c'] | shuffle(seed=inventory_hostname) }}
# => ['b','a','c']
```

## 数字

### 对数（log）

默认为 e：

```jinja2
{{ myvar | log }}
```

以 10 为底的对数：

```jinja2
{{ myvar | log(10) }}
```

### 幂（pow）

```jinja2
{{ myvar | pow(2) }}
{{ myvar | pow(5) }}
```

### 根（root）

```jinja2
{{ myvar | root }} # 平方根
{{ myvar | root(3) }} # 立方根
```

## JSON 过滤

```json
domain_definition:
    domain:
        cluster:
            - name: "cluster1"
            - name: "cluster2"
        server:
            - name: "server11"
              cluster: "cluster1"
              port: "8080"
            - name: "server12"
              cluster: "cluster1"
              port: "8090"
            - name: "server21"
              cluster: "cluster2"
              port: "9080"
            - name: "server22"
              cluster: "cluster2"
              port: "9090"
        library:
            - name: "lib1"
              target: "cluster1"
            - name: "lib2"
              target: "cluster2"
```

### 集群名

```yaml
- name: "Display all cluster names"
  debug:
    var: item
  loop: "{{ domain_definition | json_query('domain.cluster[*].name') }}"
```

### 服务名

```yaml
- name: "Display all server names"
  debug:
    var: item
  loop: "{{ domain_definition | json_query('domain.server[*].name') }}"
```

### 展示端口：

```yaml
- name: "Display all ports from cluster1"
  debug:
    var: item
  loop: "{{ domain_definition | json_query(server_name_cluster1_query) }}"
  vars:
    server_name_cluster1_query: "domain.server[?cluster=='cluster1'].port"
```

使用 `,`号分割：

```yaml
- name: "Display all ports from cluster1 as a string"
  debug:
    msg: "{{ domain_definition | json_query('domain.server[?cluster==`cluster1`].port') | join(', ') }}"
```

注意反引号，或者：

```yaml
- name: "Display all ports from cluster1"
  debug:
    var: item
  loop: "{{ domain_definition | json_query('domain.server[?cluster==''cluster1''].port') }}"
```

通过将单引号加倍，可以在 YAML 中将单引号转义。 

### hash 映射

```yaml
- name: "Display all server ports and names from cluster1"
  debug:
    var: item
  loop: "{{ domain_definition | json_query(server_name_cluster1_query) }}"
  vars:
    server_name_cluster1_query: "domain.server[?cluster=='cluster2'].{name: name, port: port}"
```

## IP 过滤

测试字符串是否为 IP：

```jinja2
{{ myvar | ipaddr }}
```

特定 IP 版本：

```jinja2
{{ myvar | ipv4 }}
{{ myvar | ipv6 }}
```

IP 地址过滤器也可以用来从 IP 地址中提取特定的信息。例如，要从 CIDR 获取 IP 地址本身：

```jinja2
{{ '192.0.2.1/24' | ipaddr('address') }}
```

## 网络 CLI 过滤

使用`parse_cli`过滤 JSON 输出：

```jinja2
{{ output | parse_cli('path/to/spec') }}
```

spec 文件应为有效格式的 YAML。它定义了如何解析 CLI 输出并返回 JSON 数据。

下面是一个有效的 spec 文件示例，该文件将解析 `show vlan `命令的输出。

```yaml
---
vars:
  vlan:
    vlan_id: "{{ item.vlan_id }}"
    name: "{{ item.name }}"
    enabled: "{{ item.state != 'act/lshut' }}"
    state: "{{ item.state }}"

keys:
  vlans:
    value: "{{ vlan }}"
    items: "^(?P<vlan_id>\\d+)\\s+(?P<name>\\w+)\\s+(?P<state>active|act/lshut|suspended)"
  state_static:
    value: present
```

上面的 spec 文件将返回 JSON 数据结构，该数据结构是带有已解析的 VLAN 信息的哈希列表。

通过使用 key 和 values 指令，可以将同一命令解析为哈希。

```yaml
---
vars:
  vlan:
    key: "{{ item.vlan_id }}"
    values:
      vlan_id: "{{ item.vlan_id }}"
      name: "{{ item.name }}"
      enabled: "{{ item.state != 'act/lshut' }}"
      state: "{{ item.state }}"

keys:
  vlans:
    value: "{{ vlan }}"
    items: "^(?P<vlan_id>\\d+)\\s+(?P<name>\\w+)\\s+(?P<state>active|act/lshut|suspended)"
  state_static:
    value: present
```

解析 CLI 命令的另一个常见用例是将一个大命令分解为可以解析的块：

```yaml
---
vars:
  interface:
    name: "{{ item[0].match[0] }}"
    state: "{{ item[1].state }}"
    mode: "{{ item[2].match[0] }}"

keys:
  interfaces:
    value: "{{ interface }}"
    start_block: "^Ethernet.*$"
    end_block: "^$"
    items:
      - "^(?P<name>Ethernet\\d\\/\\d*)"
      - "admin state is (?P<state>.+),"
	  - "Port mode is (.+)"
```

上面的示例会将 `show interface `的输出解析为哈希列表。

## 网络 XML 过滤

```jinja2
{{ output | parse_xml('path/to/spec') }}
```

`show vlan | display xml`：

```yaml
---
vars:
  vlan:
    vlan_id: "{{ item.vlan_id }}"
    name: "{{ item.name }}"
    desc: "{{ item.desc }}"
    enabled: "{{ item.state.get('inactive') != 'inactive' }}"
    state: "{% if item.state.get('inactive') == 'inactive'%} inactive {% else %} active {% endif %}"

keys:
  vlans:
    value: "{{ vlan }}"
    top: configuration/vlans/vlan
    items:
      vlan_id: vlan-id
      name: name
      desc: description
      state: ".[@inactive='inactive']"
```

```yaml
---
vars:
  vlan:
    key: "{{ item.vlan_id }}"
    values:
        vlan_id: "{{ item.vlan_id }}"
        name: "{{ item.name }}"
        desc: "{{ item.desc }}"
        enabled: "{{ item.state.get('inactive') != 'inactive' }}"
        state: "{% if item.state.get('inactive') == 'inactive'%} inactive {% else %} active {% endif %}"

keys:
  vlans:
    value: "{{ vlan }}"
    top: configuration/vlans/vlan
    items:
      vlan_id: vlan-id
      name: name
      desc: description
      state: ".[@inactive='inactive']"
```

## Hashing 过滤

### 获取 sha1

```jinja2
{{ 'test1' | hash('sha1') }}
```

### 获取 md5 

```jinja2
{{ 'test1' | hash('md5') }}
```

### 获取 checksum

```jinja2
{{ 'test2' | checksum }}
```

### 密码 hash

```jinja2
{{ 'passwordsaresecret' | password_hash('sha512') }}
```

### 随机 hash

```jinja2
{{ 'secretpassword' | password_hash('sha512', 65534 | random(seed=inventory_hostname) | string) }}
```

## Hashes 字典组合(Combine)

```jinja2
{{ {'a':1, 'b':2} | combine({'b':3}) }}
```

结果：

```jinja2
{'a':1, 'b':3}
```

递归覆盖：

```jinja2
{{ {'a':{'foo':1, 'bar':2}, 'b':2} | combine({'a':{'bar':3, 'baz':4}}, recursive=True) }}
```

结果：

```jinja2
{'a':{'foo':1, 'bar':3, 'baz':4}, 'b':2}
```

多参数合并：

```jinja2
{{ a | combine(b, c, d) }}
```

在这种情况下，d 中的键将覆盖 c 中的键，后者将覆盖 b 中的键，依此类推。 

## 提取值 

将索引列表映射到容器（哈希或数组）中的值列表 

```jinja2
{{ [0,2] | map('extract', ['x','y','z']) | list }}
{{ ['x','y'] | map('extract', {'x': 42, 'y': 31}) | list }}
```

结果：

```jinja2
['x', 'z']
[42, 31]
```

过滤器可以带另一个参数：

```jinja2
{{ groups['x'] | map('extract', hostvars, 'ec2_ip_address') | list }}
```

这将获取“ x”组中的主机列表，在 hostvars 中查找它们，然后查找结果的 ec2_ip_address。最终结果是“ x”组中主机的 IP 地址列表。

过滤器的第三个参数也可以是列表，用于在容器内进行递归查找： 

```jinja2
{{ ['a'] | map('extract', b, ['x','y']) | list }}
```

## 注释过滤

使用选定的注释样式装饰文本。

```jinja2
{{ "Plain style (default)" | comment }}
```

结果：

```jinja2
#
# Plain style (default)
#
```

 C (`//...`), C block (`/*...*/`), Erlang (`%...`) and XML (``)：

```jinja2
{{ "C style" | comment('c') }}
{{ "C block style" | comment('cblock') }}
{{ "Erlang style" | comment('erlang') }}
{{ "XML style" | comment('xml') }}
```

指定字符：

```jinja2
{{ "My Special Case" | comment(decoration="! ") }}
```

结果：

```jinja2
!
! My Special Case
!
```

```jinja2
{{ "Custom style" | comment('plain', prefix='#######\n#', postfix='#\n#######\n   ###\n    #') }}
```

```jinja2
#######
#
# Custom style
#
#######
   ###
    #
```

## URL 分割过滤

`urlsplit`过滤器从 URL 中提取片段，主机名，netloc，密码，路径，端口，查询，方案和用户名。不带参数的情况下，返回所有字段的字典：

```jinja2
{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('hostname') }}
# => 'www.acme.com'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('netloc') }}
# => 'user:password@www.acme.com:9000'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('username') }}
# => 'user'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('password') }}
# => 'password'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('path') }}
# => '/dir/index.html'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('port') }}
# => '9000'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('scheme') }}
# => 'http'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('query') }}
# => 'query=term'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('fragment') }}
# => 'fragment'

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit }}
# =>
#   {
#       "fragment": "fragment",
#       "hostname": "www.acme.com",
#       "netloc": "user:password@www.acme.com:9000",
#       "password": "password",
#       "path": "/dir/index.html",
#       "port": 9000,
#       "query": "query=term",
#       "scheme": "http",
#       "username": "user"
#   }
```

## 正则过滤( regex_search )

### 查找

```jinja2
# search for "foo" in "foobar"
{{ 'foobar' | regex_search('(foo)') }}

# will return empty if it cannot find a match
{{ 'ansible' | regex_search('(foobar)') }}

# case insensitive search in multiline mode
{{ 'foo\nBAR' | regex_search("^bar", multiline=True, ignorecase=True) }}
```

### 匹配所有

```jinja2
# Return a list of all IPv4 addresses in the string
{{ 'Some DNS servers are 8.8.8.8 and 8.8.4.4' | regex_findall('\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b') }}
```

### 替换

```jinja2
# convert "ansible" to "able"
{{ 'ansible' | regex_replace('^a.*i(.*)$', 'a\\1') }}

# convert "foobar" to "bar"
{{ 'foobar' | regex_replace('^f.*o(.*)$', '\\1') }}

# convert "localhost:80" to "localhost, 80" using named groups
{{ 'localhost:80' | regex_replace('^(?P<host>.+):(?P<port>\\d+)$', '\\g<host>, \\g<port>') }}

# convert "localhost:80" to "localhost"
{{ 'localhost:80' | regex_replace(':80') }}

# add "https://" prefix to each item in a list
{{ hosts | map('regex_replace', '^(.*)$', 'https://\\1') | list }}
```

在正则表达式中转义特殊字符，请使用`regex_escape`过滤器： 

```jinja2
# convert '^f.*o(.*)$' to '\^f\.\*o\(\.\*\)\$'
{{ '^f.*o(.*)$' | regex_escape() }}
```

## 其他有用的过滤

### shell 添加引号

```jinja2
- shell: echo {{ string_value | quote }}
```

### 判断

如果相同，则返回`Mr`：

```jinja2
{{ (name == "John") | ternary('Mr','Ms') }}
```

### 列表组成字符串

```jinja2
{{ list | join(" ") }}
```

### basename

```jinja2
{{ path | basename }}
```

 `/etc/asdf/foo.txt`输出`foo.txt`。

### dirname

```jinja2
{{ path | dirname }}
```

### 展开`~`

```jinja2
{{ path | expanduser }}
```

###  展开环境变量路径 

```jinja2
{{ path | expandvars }}
```

### 获得 link 的真实路径

```jinja2
{{ path | realpath }}
```

### 计算相对路径

```jinja2
{{ path | relpath('/etc') }}
```

### 分割文件和扩展名

```jinja2
# with path == 'nginx.conf' the return would be ('nginx', '.conf')
{{ path | splitext }}
```

### Base64 编码

```jinja2
{{ encoded | b64decode }}
{{ decoded | b64encode(encoding='utf-16-le') }}
```

### UUID 

```jinja2
{{ hostname | to_uuid }}
```

### 转换类型

```yaml
- debug:
    msg: test
  when: some_string_value | bool
```

### 使用复杂变量列表中每个项目的属性

```jinja2
# get a comma-separated list of the mount points (e.g. "/,/mnt/stuff") on a host
{{ ansible_mounts | map(attribute='mount') | join(',') }}
```

### 从字符串获取日期

```jinja2
# Get total amount of seconds between two dates. Default date format is %Y-%m-%d %H:%M:%S but you can pass your own format
{{ (("2016-08-14 20:00:12" | to_datetime) - ("2015-12-25" | to_datetime('%Y-%m-%d'))).total_seconds()  }}

# Get remaining seconds after delta has been calculated. NOTE: This does NOT convert years, days, hours, etc to seconds. For that, use total_seconds()
{{ (("2016-08-14 20:00:12" | to_datetime) - ("2016-08-14 18:00:00" | to_datetime)).seconds  }}
# This expression evaluates to "12" and not "132". Delta is 2 hours, 12 seconds

# get amount of days between two dates. This returns only number of days and discards remaining hours, minutes, and seconds
{{ (("2016-08-14 20:00:12" | to_datetime) - ("2015-12-25" | to_datetime('%Y-%m-%d'))).days  }}
```

### 使用字符串格式化日期 

```jinja2
# Display year-month-day
{{ '%Y-%m-%d' | strftime }}

# Display hour:min:sec
{{ '%H:%M:%S' | strftime }}

# Use ansible_date_time.epoch fact
{{ '%Y-%m-%d %H:%M:%S' | strftime(ansible_date_time.epoch) }}

# Use arbitrary epoch value
{{ '%Y-%m-%d' | strftime(0) }}          # => 1970-01-01
{{ '%Y-%m-%d' | strftime(1441357287) }} # => 2015-09-04
```

### 组合过滤

 返回组合列表的列表：

```yaml
- name: give me largest permutations (order matters)
  debug:
    msg: "{{ [1,2,3,4,5] | permutations | list }}"

- name: give me permutations of sets of three
  debug:
    msg: "{{ [1,2,3,4,5] | permutations(3) | list }}"
```

```yaml
- name: give me combinations for sets of two
  debug:
    msg: "{{ [1,2,3,4,5] | combinations(2) | list }}"
```

### debugging 过滤

```jinja2
{{ myvar | type_debug }}
```

## Tests

### 测试语法

测试语法和过滤语法（variable | filte）不同。在 Ansible 2.5 之后，使用 jinja2 测试将会显示警告。

语法：

```jinja2
variable is test_name
```

或：

```jinja2
result is failed
```

### 测试字符串

匹配字符串：

```yaml
vars:
  url: "http://example.com/users/foo/resources/bar"

tasks:
    - debug:
        msg: "matched pattern 1"
      when: url is match("http://example.com/users/.*/resources/.*")

    - debug:
        msg: "matched pattern 2"
      when: url is search("/users/.*/resources/.*")

    - debug:
        msg: "matched pattern 3"
      when: url is search("/users/")
```

`match`要求完全匹配字符串，而`search`仅需要匹配字符串的子集。 

### 版本比较

```jinja2
{{ ansible_facts['distribution_version'] is version('12.04', '>=') }}
```

操作符：

```jinja2
<, lt, <=, le, >, gt, >=, ge, ==, =, eq, !=, <>, ne
```

严格版本解析：

```jinja2
{{ sample_version_var is version('1.0', operator='lt', strict=True) }}
```

### 集合测试

#### 子集和超集

```yaml
vars:
    a: [1,2,3,4,5]
    b: [2,3]
tasks:
    - debug:
        msg: "A includes B"
      when: a is superset(b)

    - debug:
        msg: "B is included in A"
      when: b is subset(a)
```

#### 全真或至少一个真

```yaml
vars:
  mylist:
      - 1
      - "{{ 3 == 3 }}"
      - True
  myotherlist:
      - False
      - True
tasks:

  - debug:
      msg: "all are true!"
    when: mylist is all

  - debug:
      msg: "at least one is true"
    when: myotherlist is any
```

### 路径测试

```yaml
- debug:
    msg: "path is a directory"
  when: mypath is directory

- debug:
    msg: "path is a file"
  when: mypath is file

- debug:
    msg: "path is a symlink"
  when: mypath is link

- debug:
    msg: "path already exists"
  when: mypath is exists

- debug:
    msg: "path is {{ (mypath is abs)|ternary('absolute','relative')}}"

- debug:
    msg: "path is the same file as path2"
  when: mypath is same_file(path2)

- debug:
    msg: "path is a mount"
  when: mypath is mount
```

### 任务结果测试

```yaml
tasks:

  - shell: /usr/bin/foo
    register: result
    ignore_errors: True

  - debug:
      msg: "it failed"
    when: result is failed

  # in most cases you'll want a handler, but if you want to do something right now, this is nice
  - debug:
      msg: "it changed"
    when: result is changed

  - debug:
      msg: "it succeeded in Ansible >= 2.1"
    when: result is succeeded

  - debug:
      msg: "it succeeded"
    when: result is success

  - debug:
      msg: "it was skipped"
    when: result is skipped
```

<br/>

> [Templating (Jinja2)](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_templating.html#id1)