1. ##### include

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
         #引入另一个playbook
         include: include.yaml
         #判断是否执行playbook
         when: 2 < 1
         #传递变量
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
         #loop_control不设置，include的playbook的item使用内层循环
         loop_control:
           loop_var: outer_item
   
   #include.yaml
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
    
   #include2.yaml
   - name: debug 
     debug:  
       #outer_item外层变量【1，2】，item内层变量【a，b】
       msg: "{{ outer_item }} -- {{ item }} include2.yaml"
     loop: 
       - a
       - b
   ```

2. ##### include_tasks

   ​	include_tasks和include基本相同，但是涉及到**tag**标签，有所不同。详情见[ansible笔记（37）：include（二）](<http://www.zsythink.net/archives/2977>)。

3. ##### import_tasks

   ```bash
   "import_tasks"是静态的，"include_tasks"是动态的。
   "静态"的意思就是被include的文件在playbook被加载时就展开了（是预处理的）。
   "动态"的意思就是被include的文件在playbook运行时才会被展开（是实时处理的）。
   由于"include_tasks"是动态的，所以，被include的文件的文件名可以使用任何变量替换。
   由于"import_tasks"是静态的，所以，被include的文件的文件名不能使用动态的变量替换。
   
   #循环
   使用"loop"关键字或"with_items"关键字对include文件进行循环操作时，只能配合"include_tasks"才能正常运行。
   
   #when判断
   当对"include_tasks"使用when进行条件判断时，when对应的条件只会应用于"include_tasks"任务本身，当执行被包含的任务时，不会对这些被包含的任务重新进行条件判断。
   当对"import_tasks"使用when进行条件判断时，when对应的条件会应用于被include的文件中的每一个任务，当执行被包含的任务时，会对每一个被包含的任务进行同样的条件判断。
   
   #tag
   与"include_tasks"不同，当为"import_tasks"添加标签时，tags是针对被包含文件中的所有任务生效的，与"include"关键字的效果相同。
   
   #handers
   "include_tasks"与"import_tasks"都可以在handlers中使用，并没有什么不同
   ```

4. ##### include_playbook

   ```bash
   使用"include"引用整个playbook，在之后的版本中，如果想要引入整个playbook，则需要使用"import_playbook"模块代替"include"模块，因为在2.8版本以后，使用"include"关键字引用整个playbook的特性将会被弃用。
   ```

   

> [ansible笔记：include](<http://www.zsythink.net/archives/2962>)