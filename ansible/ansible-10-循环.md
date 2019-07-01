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
      
#output
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



```bash
#with_items同 with_flattened
- [1, 2, 3]
- [a, b]
#将会在item中循环显示每个元素
1
2
3
a
b

#whit_list
- [1, 2, 3]
- [a, b]
#将会显示列表
[1, 2, 3]
[a, b]

#with_together
- [1, 2, 3]
- [a, b]
#将会上下一起显示
[1, a]
[2, b]
[3, null]

#with_cartesian(笛卡尔)
- [1, 2, 3]
- [a, b]
#输出笛卡尔积
[1, a]
[1, b]
[2, a]
[2, b]
[3, a]
[3, b]

#with_indexed_items
- [1, 2, [3, 4]]
- [a, b]
#将会显示索引
[0, 1]
[1, 2]
[2, [3, 4]]
[3, a]
[4, b]

#with_sequence
with_sequence: start=2 end=10 stride=2
#将会从2（开始）到10（结束），每隔2（stride）
2
4
6
8
10
#生成连续数字
count=5
start=1 end=5 stride=1

#with_random_choice
- 1
- 2
- 3
- 4
- 5
#随机数字
#可能返回1，也可能3

#with_dict
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
#输出
"key": "a", 
"value": 1
#可使用item.key单独获取键
"key": "b", 
"value": 2

#with_subelements
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
#输出
"msg": "bob like videogame"
"msg": "bob like skateboade"
"msg": "alice like music"

#with_file(获取文件中的内容，文件在ansible机器中)
#with_fileglob(匹配文件，如/root/*，获取的是ansible机器)
```



> [各种循环的使用](<http://www.zsythink.net/archives/2728>)
