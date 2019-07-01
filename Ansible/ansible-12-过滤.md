1. #### 字符相关

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

2. #### 数字相关

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

3. #### 列表相关

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

4. #### 默认值

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
           #通过default，设置默认值
           #omit代表省略
           mode: "{{ item.mode|default(omit) }}"
         with_items: "{{ paths }}"
   ```

5. #### 分析json

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
           #item.0是test_log.logs中的元素
           #item.1是test_log.logs.files中的元素
           msg: "{{item.0.domainName}} logUrl is {{item.1.logUrl}}"
         with_subelements:
           - "{{test_log.logs}}"
           #相当与过滤
           - files
       - name: 直接使用json_query显示logUrl
         debug: 
           msg: "{{item}}"
         with_items: "{{ test_log | json_query('logs[*].files[*].logUrl')}}"
       
       # ansible主机需要python-jmespath包支持
       - name: json_query domainName
         debug:
           msg: "{{test_log | json_query('logs[*].domainName')}}"
       - name: 将domainName在msg中显示dn
      debug:  
           msg: "{{ test_log | json_query('logs[*].{dn:domainName}') }}"
   ```
   
6. #### 常用

   ```yaml
   ---
   - hosts: test70
     remote_user: root
     gather_facts: no
     tasks:
     ######################################################################
     #在调用shell模块时，如果引用某些变量时需要添加引号，则可以使用quote过滤器代替引号
     #示例如下，先看示例，后面会有注解
     - shell: "echo {{teststr | quote}} > /testdir/testfile"
       vars:
         teststr: "a\nb\nc"
     #上例中shell模块的写法与如下写法完全等效
     #shell: "echo '{{teststr}}' > /testdir/testfile"
     #没错，如你所见，quote过滤器能够代替引号
     #上例中，如果不对{{teststr}}添加引号，则会报错，因为teststr变量中包含"\n"转义符
     ######################################################################
     #ternary过滤器可以实现三元运算的效果 示例如下
     #如下示例表示如果name变量的值是John，那么对应的值则为Mr,否则则为Ms
     #简便的实现类似if else对变量赋值的效果
     - debug: 
         msg: "{{ (name == 'John') | ternary('Mr','Ms') }}"
       vars:
         name: "John"
     ######################################################################
     #basename过滤器可以获取到一个路径字符串中的文件名
     - debug:
         msg: "{{teststr | basename}}"
       vars:
         teststr: "/testdir/ansible/testfile"
     ######################################################################
     #获取到一个windows路径字符串中的文件名,2.0版本以后的ansible可用
     - debug:
         msg: "{{teststr | win_basename}}"
       vars:
         teststr: 'D:\study\zsythink'
     ######################################################################
     #dirname过滤器可以获取到一个路径字符串中的路径名
     - debug:
         msg: "{{teststr | dirname}}"
       vars:
         teststr: "/testdir/ansible/testfile"
     ######################################################################
     #获取到一个windows路径字符串中的文件名,2.0版本以后的ansible可用
     - debug:
         msg: "{{teststr | win_dirname}}"
       vars:
         teststr: 'D:\study\zsythink'
     ######################################################################
     #将一个windows路径字符串中的盘符和路径分开,2.0版本以后的ansible可用
     - debug:
         msg: "{{teststr | win_splitdrive}}"
       vars:
         teststr: 'D:\study\zsythink'
     #可以配合之前总结的过滤器一起使用，比如只获取到盘符，示例如下
     #msg: "{{teststr | win_splitdrive | first}}"
     #可以配合之前总结的过滤器一起使用，比如只获取到路径，示例如下
     #msg: "{{teststr | win_splitdrive | last}}"
     ######################################################################
     #realpath过滤器可以获取软链接文件所指向的真正文件
     - debug:
         msg: "{{ path | realpath }}"
       vars:
         path: "/testdir/ansible/testsoft"
     ######################################################################
     #relpath过滤器可以获取到path对于“指定路径”来说的“相对路径”
     - debug:
         msg: "{{ path | relpath('/testdir/testdir') }}"
       vars:
         path: "/testdir/ansible"
     ######################################################################
     #splitext过滤器可以将带有文件名后缀的路径从“.后缀”部分分开
     - debug:
         msg: "{{ path | splitext }}"
       vars:
         path: "/etc/nginx/conf.d/test.conf"
     #可以配置之前总结的过滤器，获取到文件后缀
     #msg: "{{ path | splitext | last}}"
     #可以配置之前总结的过滤器，获取到文件前缀名
     #msg: "{{ path | splitext | first | basename}}"
     ######################################################################
     #to_uuid过滤器能够为对应的字符串生成uuid
     - debug:
         msg: "{{ teststr | to_uuid }}"
       vars:
         teststr: "This is a test statement" 
     ######################################################################
     #bool过滤器可以根据字符串的内容返回bool值true或者false
     #字符串的内容为yes、1、True、true则返回布尔值true，字符串内容为其他内容则返回false
     - debug:
         msg: "{{ teststr | bool }}"
       vars:
         teststr: "1"
     #当和用户交互时，有可能需要用户从两个选项中选择一个，比如是否继续，
     #这时，将用户输入的字符串通过bool过滤器处理后得出布尔值，从而进行判断，比如如下用法
     #- debug:
     #    msg: "output when bool is true"
     #  when: some_string_user_input | bool
     ######################################################################
     #map过滤器可以从列表中获取到每个元素所共有的某个属性的值，并将这些值组成一个列表
     #当列表中嵌套了列表，不能越级获取属性的值，也就是说只能获取直接子元素的共有属性值。
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
     #也可以组成一个字符串，用指定的字符隔开，比如分号
     #msg: "{{ users | map(attribute='name') | join(';') }}"
     ######################################################################
     #与python中的用法相同，两个日期类型相减能够算出两个日期间的时间差
     #下例中，我们使用to_datatime过滤器将字符串类型转换成了日期了类型，并且算出了时间差
     - debug:
         msg: '{{ ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 19:00:00" | to_datetime) }}'
     #默认情况下，to_datatime转换的字符串的格式必须是“%Y-%m-%d %H:%M:%S”
     #如果对应的字符串不是这种格式，则需要在to_datetime中指定与字符串相同的时间格式，才能正确的转换为时间类型
     - debug:
         msg: '{{ ("20160814"| to_datetime("%Y%m%d")) - ("2012-12-25 19:00:00" | to_datetime) }}'
     #如下方法可以获取到两个日期之间一共相差多少秒
     - debug:
         msg: '{{ ( ("20160814"| to_datetime("%Y%m%d")) - ("20121225" | to_datetime("%Y%m%d")) ).total_seconds() }}'
     #如下方法可以获取到两个日期“时间位”相差多少秒，注意：日期位不会纳入对比计算范围
     #也就是说，下例中的2016-08-14和2012-12-25不会纳入计算范围
     #只是计算20:00:12与08:30:00相差多少秒
     #如果想要算出连带日期的秒数差则使用total_seconds()
     - debug:
         msg: '{{ ( ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 08:30:00" | to_datetime) ).seconds }}'
     #如下方法可以获取到两个日期“日期位”相差多少天，注意：时间位不会纳入对比计算范围
     - debug:
         msg: '{{ ( ("2016-08-14 20:00:12"| to_datetime) - ("2012-12-25 08:30:00" | to_datetime) ).days }}'
     ######################################################################
     #使用base64编码方式对字符串进行编码
     - debug:
         msg: "{{ 'hello' | b64encode }}"
     #使用base64编码方式对字符串进行解码
     - debug:
         msg: "{{ 'aGVsbG8=' | b64decode }}"
     #######################################################################
     #使用sha1算法对字符串进行哈希
     - debug:
         msg: "{{ '123456' | hash('sha1') }}"
     #使用md5算法对字符串进行哈希
     - debug:
         msg: "{{ '123456' | hash('md5') }}"
     #获取到字符串的校验和,与md5哈希值一致
     - debug:
         msg: "{{ '123456' | checksum }}"
     #使用blowfish算法对字符串进行哈希，注:部分系统支持
     - debug:
         msg: "{{ '123456' | hash('blowfish') }}"
     #使用sha256算法对字符串进行哈希,哈希过程中会生成随机"盐",以便无法直接对比出原值
     - debug:
         msg: "{{ '123456' | password_hash('sha256') }}"
     #使用sha256算法对字符串进行哈希,并使用指定的字符串作为"盐"
     - debug:
         msg: "{{ '123456' | password_hash('sha256','mysalt') }}"
     #使用sha512算法对字符串进行哈希,哈希过程中会生成随机"盐",以便无法直接对比出原值
     - debug:
         msg: "{{ '123123' | password_hash('sha512') }}"
     #使用sha512算法对字符串进行哈希,并使用指定的字符串作为"盐"
     - debug:
         msg: "{{ '123123' | password_hash('sha512','ebzL.U5cjaHe55KK') }}"
     #如下方法可以幂等的为每个主机的密码生成对应哈希串
     #有了之前总结的过滤器用法作为基础，你一定已经看懂了
     - debug:
         msg: "{{ '123123' | password_hash('sha512', 65534|random(seed=inventory_hostname)|string) }}"
   ```

   



> [ansible过滤器](<http://www.zsythink.net/archives/2862>)