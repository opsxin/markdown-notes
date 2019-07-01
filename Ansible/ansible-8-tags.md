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
#设置tag，多个任务可以用同一个tag
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
#执行tag1,tag2的任务
ansible-playbook --tags tag1,tag2 TAGS-FILE.yaml
#跳过执行tag1的任务
ansible-playbook --skip-tags=tag1 TAG-FILE.yaml
#列出yaml中的tags
ansible-playbook --list-tags TAGS-FILE.yaml

#特殊tag：always，never，tagged，untagged，all
#always：无论是否指明，该任务都执行。通过“--skip-tags”可以取消执行
#？never：和always相反？
#tagged：执行有打tag的任务
#untagged：执行未打tag的任务
#all：所有任务都执行，默认tag
```

