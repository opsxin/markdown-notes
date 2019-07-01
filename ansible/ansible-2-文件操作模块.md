1. ###### 模块基本使用^1^

   ```bash
   #查看已有模块
   ansible-doc -l
   #查询模块Help
   ansible-doc -s ping
   #使用模块
   ansible A(主机) -m fetch(模块名) -a 'src=/etc/hosts dest=/root'(参数)
   ```

2. ###### copy模块

   ```bash
   #拷贝文件，强制覆盖（默认），设置备份，用户为tomcat，组为tomcat，模式为0644
   ansible A -m copy -a 'src=/root/test.txt dest=/root force=yes backup=yes owner=tomcat group=tomcat mode=0644'
   #生成文件
   ansible A -m copy -a 'content="aaa\bbb\t" dest=/root/test.txt2'
   ```

3. ###### file模块

   ```bash
   #state参数：创建目录时，将state的值设置为directory；操作文件时，将state的值设置为touch；创建软链接文件时，需将state设置为link；创建硬链接文件时，需要将state设置为hard；删除一个文件时（删除时不用区分目标是文件、目录、还是链接），需要将state的值设置为absent。
   #创建目录
   ansible A -m file -a 'path=/root/test state=directory owner=nobody group=nogroup recurse=yes'
   #创建软连接
   ansible A -m file -a 'path=/root/soft-link state=link src=/bin/bash'
   #删除文件
   ansible A -m file -a 'path=/root/test state=absent'
   ```

4. ###### blockinfile模块

   ```bash
   #插入文本
   ansible A -m blockinfile -a 'dest=/root/test block="test-01"'
   #删除文本
   ansible A -m blockinfile -a 'dest=/root/test state=absent'
   #设置自定义标记
   ansible A -m blockinfile -a 'dest=/root/test block="test-02" marker="#{mark} test-02"'
   #可通过insertafter参数设置插入位置，creat文件不存在则创建，backup备份
   insertafter=(BOF,EOF,正则)
   ```

5. ###### lineinfile模块

   ```bash
   #添加一行内容，如果文件中任意一行有相同内容，则不添加
   ansible A -m lineinfile -a "dest=/root/test line="test-02"
   #正则，如果不止一行匹配，则最后匹配的替换；如果没有匹配，则添加到未行。如果backrefs参数为yes，则未匹配到也不会添加。
   ansible A -m lineinfile -a 'dest=/root/test regexp="t$" line="asdf"'
   #删除行
   ansible A -m lineinfile -a 'dest=/root/test regexp="^a" state=absent'
   #正则替换,如果需要引用匹配出来的内容，backrefs一定要为yes；\1不能加""号
   ansible A -m lineinfile -a 'dest=/root/test regexp="\(test\)-\(02\)" line=\1 backrefs=yes' 
   ```

6. ###### find模块

   ```bash
   #查找**包含字符串**的文件及子目录内的文件,包括隐藏文件
   ansible A -m find -a 'paths=/root contains=".*test.*" recurse=yes hidden=yes'
   #查找文件名，类型为文件(file)或路径(directory)
   ansible A -m find -a 'paths=/root patterns="test*" file_type=file'
   #查找文件，两周内，大于1K，使用正则匹配
   ansible A -m find -a 'paths=/root patterns="test.*" use_regex=yes age=-2w size=1K'
   ```

7. ###### replace模块

   ```bash
   #替换END为end，设置backup为yes可备份原文件
   ansible A -m replace -a 'dest=/root/test.txt regexp="END" replace=end'
   ```

   

> 1. [ansible模块的基本使用](<http://www.zsythink.net/archives/2523>)
> 2. [模块文件操作](<http://www.zsythink.net/archives/2542>)