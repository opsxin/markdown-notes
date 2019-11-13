# Ansible 常用模块

[TOC]

## 文件管理模块

### copy 模块

```bash
# 强制覆盖（默认），备份源文件，更改用户为 tomcat，组为tomcat，属性为 0644
ansible A -m copy -a 'src=/root/test.txt dest=/root force=yes backup=yes owner=tomcat group=tomcat mode=0644'
# 生成文件
ansible A -m copy -a 'content="aaa\bbb\t" dest=/root/test.txt2'
```

### file 模块

```bash
# 创建目录时，将 state 的值设置为 directory
# 创建文件时，将 state 的值设置为 touch
# 创建软链接时，将 state 设置为 link
# 创建硬链接时，将 state 设置为 hard 
# 删除文件时（不用区分目标是文件、目录、链接），将 state 设置为 absent

# 创建目录
ansible A -m file -a 'path=/root/test state=directory owner=nobody group=nogroup recurse=yes'
# 创建软连接
ansible A -m file -a 'path=/root/soft-link state=link src=/bin/bash'
# 删除文件
ansible A -m file -a 'path=/root/test state=absent'
```

### blockinfile 模块

```bash
# 插入 block 内容
ansible A -m blockinfile -a 'dest=/root/test block="test-01"'
# 删除文本
ansible A -m blockinfile -a 'dest=/root/test state=absent'
# 设置自定义标记
ansible A -m blockinfile -a 'dest=/root/test block="test-02" marker="#{mark} test-02"'
# 通过 insertafter，insertbefore 参数设置插入位置
# 通过 creat，文件不存在则创建文件
# 通过 backup 备份源文件
```

### lineinfile 模块

```bash
# 添加一行内容，如果文件中任意一行有相同内容，则不添加
ansible A -m lineinfile -a "dest=/root/test line="test-02"
# 正则匹配，如果不止一行匹配，则替换最后匹配的行
# 如果没有匹配，则添加到未行，如果 backrefs=yes，则文件保持不变。
ansible A -m lineinfile -a 'dest=/root/test regexp="t$" line="asdf"'
# 删除行
ansible A -m lineinfile -a 'dest=/root/test regexp="^a" state=absent'
# 正则替换，如果需要引用匹配出来的内容，backrefs 一定要为 yes；\1 不能加 "" 号
ansible A -m lineinfile -a 'dest=/root/test regexp="\(test\)-\(02\)" line=\1 backrefs=yes' 
```

### find 模块

```bash
# 查找 containers 的文件及子目录内的文件，包括隐藏文件
ansible A -m find -a 'paths=/root contains=".*test.*" recurse=yes hidden=yes'
# 查找文件，类型为文件(file)或路径(directory)
ansible A -m find -a 'paths=/root patterns="test*" file_type=file'
# 查找文件，两周内，大于 1K，使用正则匹配
ansible A -m find -a 'paths=/root patterns="test.*" use_regex=yes age=-2w size=1K'
```

### replace 模块

```bash
# 替换 END 为 end，设置 backup=yes 可备份原文件
ansible A -m replace -a 'dest=/root/test.txt regexp="END" replace=end'
```

## 命令模块

### command 模块

```bash
# 在 /root 执行一条命令
ansible A -m command -a 'ls chdir="/root"'
# 如果文件存在就不执行命令(不会删除 test.txt)
ansible A -m command -a 'rm test.txt creates="test.txt"'
# 如果文件存在才执行命令
ansible A -m command -a 'cat test.txt chdir="/root" removes="test.txt"'
```

### shell 模块

```bash
# 与 command 命令基本一致
# 但支持像 '$HOME' 等环境变量和 '"<", ">", "|", ";", "&"'
ansible A -m shell -a 'cat test.txt > test.txt.2 chdir="/root" removes="test.txt"'
```

### script 模块

```bash
# 在远程主机执行本地脚本
ansible C -m script -a 'chdir="/root" removes="test.txt" /root/test.sh(本地的脚本)'
```

## 系统模块

### cron 模块

```bash
# 0 1 */2 * * cat /root/test.txt
ansible A -m cron -a 'name="echo test.txt file" minute=0 hour=1 day=*/2 job="cat /root/test.txt"'
# 删除 name="echo test.txt file" 的定时任务
ansible A -m cron -a 'name="echo test.txt file" state=absent'
# special_time：reboot, yearly, annually, monthly, weekly, daily, hourly
# backup 备份，user 执行命令的用户
ansible A -m cron -a 'name="echo test.txt file" user=tomcat special_time=monthly jobs="cat /root/test.txt" backup=yes'
# 注释任务,原有时间等设置要在命令中完整写出
ansible A -m cron -a 'name="echo test.txt file" user=tomcat special_time=monthly jobs="cat /root/test.txt" disabled=yes backup=yes'
```

### service 模块

```bash
# 启动 nginx.service, 并设置开机启动。
#状 态只有 started,stopped,restarted,reloaded
ansible A -m service -a 'name="nginx" state=start enabled=yes'
```

### user 模块

```bash
# 新建用户 test01，组为 nogroup，附加组为 root，append 表示不覆盖原附加组
# 过期时间 date -s @1556640000 +%Y-%m-%d，注释为 test-01
# password 设置密码，需要填写 crypt 后的密码
ansible A -m user -a 'name="test01" group=nogroup groups=root append=yes shell=/bin/bash uid=2000 expires=1556640000 comment="test-01"'
# 删除用户，remove 家目录
ansible A -m user -a 'name=test01 remove=yes state=absent'
```

### group 模块

```bash
# 添加一个组
ansible A -m group -a 'name=test01 gid=2000'
# 删除一个组
ansible A -m group -a 'name=test01 state=absent'
```

## 包管理模块

### yum_repository 模块

```bash
# 添加阿里源，文件名为 alibaba.repo,启用，不校验 key
ansible A -m yum_repository -a 'name=aliEpel description="alibaba EPEL" baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/ file=alibaba gpgcheck=no enabled=yes'
# 删除阿里源
ansible A -m yum_reposity -a 'file=alibaba name=aliEpel state=absent'
```

### apt_repository 模块

```bash
# 添加 google-chrome 源
ansible A -m apt_pository -a 'repo="deb http://dl.google.com/linux/chrome/deb/ stable main" filename="google-chrome"'
# 删除源
andible A -m apt_pository -a 'repo="deb http://dl.google.com/linux/chrome/deb/ stable main" filename="google-chrome" state=absent'
```

### yum 模块

```bash
# 安装最新的 nginx
# latest 最新
# installed==present 如果已安装的话，不会更新,可设置安装版本号
ansible A -m yum -a 'name=nginx state=latest'
# absent==removed 移除
ansible A -m yum -a 'name=nginx state=absent'
```

### apt 模块

```bash
# 安装 nginx:1.12,不安装推荐软件，
ansible A -m apt -a 'name=nginx=1.12 install_recommends=no'
# 安装 deb 包
ansible A -m apt -a 'deb=/tmp/test.deb'
ansible A -m apt -a 'deb=https://example.com/test.deb'
# 移除包,通过 purge=yes 完全移除包
ansible A -m apt -a 'name=nginx state=absent'
# 更新本地所有包
ansible A -m apt -a 'upgrade=dist update_cache=yes'
```

<br/>

> [文件操作](http://www.zsythink.net/archives/2542)
>
> [命令模块](http://www.zsythink.net/archives/2557)
>
> [系统模块](http://www.zsythink.net/archives/2580)
>
> [包管理模块](http://www.zsythink.net/archives/2592)