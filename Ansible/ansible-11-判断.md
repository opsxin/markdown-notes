1. ##### when

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
         #when相当于if
         when: return_result.rc == 0
   ```

2. ##### test

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
         #文件存在执行
         when: dir is exists 
       - name: debug msg 2
         debug: 
           msg: "NO"
         #文件不存在执行
         when: not dir is exists  
   ```

   ```bash
   #测试test变量
   defined(已定义)
   undefined(未定义)
   null（空值）
   
   #执行结果
   success或succeeded（执行成功）
   failure或failed（执行失败）
   change或chenged（执行返回changed）
   skip或skipped（跳过的任务）
   
   #路径
   file（是否为文件）
   directory（是否为目录）
   link（是否为连接）
   mount（是否为挂载点）
   is_exists或exists（是否存在）
   
   #字符串
   lower（是否全为小写）
   upper（是否全为大写）
   
   #数字类型
   even（是否为偶数）
   odd（是否为奇数）
   divisibleby(num)（是否可以整数，如果返回0，则为真）
   
   #其他
   #比较操作符 := gt, ge, lt, le, eq, ne
   version('版本号', '比较操作符')
   version("7", 'gt')
   
   a is subset(b)(a是否为b子集)
   a is superset(b)(a是否为b超集)
   
   string（是否为字符串）
   number（是否为数字）
   ```

3. ##### block

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
   #输出
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
         #shell执行失败
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
         #如果上述任务有错误，就会执行rescue中代码
         #**block中，错误task后的task不会执行**
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
         #无论失败还是成功，always都会执行
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
         #fail模块相当于exit
         - name: fail
           fail:
             msg: "fail text"
           #"string" in "string"
           #in判断是否在字符串内
           when: '"error" in return_values.stdout'
         - name: debug msg 1
           debug:  
             msg: "debug msg 1"
   ```

   ```bash
   #failed_when
   #failed_when条件成立时，对应的任务状态就为失败
   #任务会执行，只是影响返回的状态
   #changed_when
   #对应的任务状态为changed
   #当将'changed_when'直接设置为false时，对应任务的状态将不会被设置为'changed'，如果任务原本的执行状态为'changed'，最终则会被设置为'ok'，所以，上例playbook执行后，shell模块的执行状态最终为'ok'
   ```



> [ansible笔记](<http://www.zsythink.net/archives/2846>)

