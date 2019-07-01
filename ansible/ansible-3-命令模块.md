1. ###### command模块

   ```bash
   #在/root执行一条命令
   ansible A -m command -a 'ls chdir="/root"'
   #如果文件存在就不执行命令(不会删除test.txt)
   ansible A -m command -a 'rm test.txt creates="test.txt"'
   #如果文件存在才执行命令
   ansible A -m command -a 'cat test.txt chdir="/root" removes="test.txt"'
   ```

2. ##### shell模块

   ```bash
   #与command命令基本一致，但支持像'$HOME'等环境变量和'"<", ">", "|", ";", "&"'
   ansible A -m shell -a 'cat test.txt > test.txt.2 chdir="/root" removes="test.txt"'
   ```

3. ###### script模块

   ```bash
   #在远程主机执行本地脚本
   ansible C -m script -a 'chdir="/root" removes="test.txt" /root/test.sh(本地的脚本)'
   ```



>  [常用模块之命令类模块](<http://www.zsythink.net/archives/2557>)