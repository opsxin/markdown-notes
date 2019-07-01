1. ###### cron模块

   ```bash
   #0 1 */2 * * cat /root/test.txt
   ansible A -m cron -a 'name="echo test.txt file" minute=0 hour=1 day=*/2 job="cat /root/test.txt"'
   #删除name="echo test.txt file"的定时任务
   ansible A -m cron -a 'name="echo test.txt file" state=absent'
   #special_time：reboot, yearly, annually, monthly, weekly, daily, hourly
   #backup备份，user执行命令的用户
   ansible A -m cron -a 'name="echo test.txt file" user=tomcat special_time=monthly jobs="cat /root/test.txt" backup=yes'
   #注释任务,原有时间等设置要在命令中完整写出
   ansible A -m cron -a 'name="echo test.txt file" user=tomcat special_time=monthly jobs="cat /root/test.txt" disabled=yes backup=yes'
   ```

2. ###### service模块

   ```bash
   #启动nginx.service, 并设置开机启动。
   #状态只有started,stopped,restarted,reloaded
   ansible A -m service -a 'name="nginx" state=start enabled=yes'
   ```

3. ###### user模块

   ```bash
   #新建用户test01，组为nogroup，附加组为root，append表示不覆盖原附加组
   #过期时间date -s @1556640000 +%Y-%m-%d，注释为test-01
   #password设置密码，需要填写crypt后的密码
   ansible A -m user -a 'name="test01" group=nogroup groups=root append=yes shell=/bin/bash uid=2000 expires=1556640000 comment="test-01"'
   #删除用户，remove家目录
   ansible A -m user -a 'name=test01 remove=yes state=absent'
   ```

4. ###### group模块

   ```bash
   #添加一个组
   ansible A -m group -a 'name=test01 gid=2000'
   #删除一个组
   ansible A -m group -a 'name=test01 state=absent'
   ```



> [系统模块](<http://www.zsythink.net/archives/2580>)