```yaml
# handler只有在任务'changed'后执行
# 关联同一个handler的tasks都已被执行，才会执行此handler
# 这段只有handler1会执行，因为“mkdir /root/test 2”不会有‘changed’，因为ansible的幂等性
---
- hosts: A
  remote_user: root
  tasks:
    - name: mkdir /root/test 1
      file:
        path: /root/test
        state: directory
      notify: handler1
      
# **执行以上任务需要调用的‘handler’，而不是等待所有任务完成后才执行‘handler’** 
    - meta: flush_handlers
      
    - name: mkdir /root/test 2
      file: 
        path: /root/test
        state: directory
      notify: handler2

# handler中也可以使用‘notify’，调用指定的handler
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

```yaml
---
- hosts: A
  remote_user: root
  tasks:
    - name: mkdir /root/test 1
      file:
        path: /root/test
        state: directory
# 调用handler组
      notify: handler group
    - name: mkdir /root/test 2
      file: 
        path: /root/test
        state: directory
      notify: handler3

# 利用‘listen’，设置handler组
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



> [handler详解](<http://www.zsythink.net/archives/2624>)
