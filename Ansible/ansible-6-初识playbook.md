```yaml
#---表示yaml文档开始，不是必须
---
#第一个场景（PLAY）
#注意多种host的写法
- hosts: A,B
  remote_user: root
#需要执行的任务（TASK）
  tasks:
#为任务命名(可省略，但不建议)
  - name: Ping the host
#调用的ansible模块
    ping:
  - name: mkdir /root/test
    file:
#模块的参数
      path: /root/test
      state: directory

#第二个场景（PLAY）
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
#检查plsybook语法
ansible-playbook --syntax-check PLAYBOOK-FILE
#模拟执行
nasible-playbook --check PLAYBOOK-FILE
```



> [初识playbook](<http://www.zsythink.net/archives/2602>)

