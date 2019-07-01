1. ###### yum_repository模块

   ```bash
   #添加阿里源，文件名为alibaba.repo,启用，不校验key
   ansible A -m yum_repository -a 'name=aliEpel description="alibaba EPEL" baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/ file=alibaba gpgcheck=no enabled=yes'
   #删除阿里源
   ansible A -m yum_reposity -a 'file=alibaba name=aliEpel state=absent'
   ```

2. ###### apt_repository模块

   ```bash
   #添加google-chrome源
   ansible A -m apt_pository -a 'repo="deb http://dl.google.com/linux/chrome/deb/ stable main" filename="google-chrome"'
   #删除源
   andible A -m apt_pository -a 'repo="deb http://dl.google.com/linux/chrome/deb/ stable main" filename="google-chrome" state=absent'
   ```

3. ###### yum模块

   ```bash
   #安装最新的nginx
   #latest==最新
   #installed==present如果已安装的话，不会更新,可设置安装版本号
   ansible A -m yum -a 'name=nginx state=latest'
   #absent==removed移除
   ansible A -m yum -a 'name=nginx state=absent'
   ```

4. ###### apt模块

   ```bash
   #安装nginx:1.12,不安装推荐软件，
   ansible A -m apt -a 'name=nginx=1.12 install_recommends=no'
   #安装deb包
   ansible A -m apt -a 'deb=/tmp/test.deb'
   ansible A -m apt -a 'deb=https://example.com/test.deb'
   #移除包,通过purge=yes完全移除包
   ansible A -m apt -a 'name=nginx state=absent'
   #更新本地所有包
   ansible A -m apt -a 'upgrade=dist update_cache=yes'
   ```

   



> [包管理模块](<http://www.zsythink.net/archives/2592>)