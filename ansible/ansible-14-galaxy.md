1. ##### 安装模块

   ```bash
   #修改安装路径，指定版本
   ansible-galaxy install [--roles-path ~/.ansible/roles] username.rolename[, v1.0.0]
   #通过git方式
   ansible-galaxy install git+https://github.com/geerlingguy/ansible-role-apache.git,0b7cd353c0250e87a26e0499e59e7fd265cc2f25
   #通过文件方式
   ansible-galaxy install -r requirements.yml
   
   #默认路径,可通过ansible.cfg修改
   #/etc/ansible/roles:~/.ansible/roles
   ```

2. ##### requirements

   ```yaml
   # from galaxy
   - src: yatesr.timezone
   
   # from GitHub
   - src: https://github.com/bennojoy/nginx
   
   # from GitHub, overriding the name and specifying a specific tag
   - src: https://github.com/bennojoy/nginx
     version: master
     name: nginx_role
   
   # from a webserver, where the role is packaged in a tar.gz
   - src: https://some.webserver.example.com/files/master.tar.gz
     name: http-role
   
   # from Bitbucket
   - src: git+http://bitbucket.org/willthames/git-ansible-galaxy
     version: v1.4
   
   # from Bitbucket, alternative syntax and caveats
   - src: http://bitbucket.org/willthames/hg-ansible-galaxy
     scm: hg
   
   # from GitLab or other git-based scm
   - src: git@gitlab.company.com:mygroup/ansible-base.git
     scm: git
     version: "0.1"  # quoted, so YAML doesn't parse this as a floating-point value
    
   #依赖于其他角色
   dependencies:
    - src: geerlingguy.ansible
    - src: git+https://github.com/geerlingguy/ansible-role-composer.git
      version: 775396299f2da1f519f0d8885022ca2d6ee80ee8
      name: composer
   ```

3. ##### 创建Role

   ```bash
   #force:如果当前工作目录中存在与该角色名称相匹配的目录，则init命令将忽略该错误.
   #force将创建上述子目录和文件，替换匹配的任何内容。
   #container-enabled:创建目录结构，但使用适用于启用Container的默认文件填充它。 例如，README.md具有稍微不同的结构， .travis.yml文件使用Ansible Container来测试角色，而meta目录包含一个container.yml文件。
   ansible-galaxy init role_name
   
   #默认目录结构
     .
     ├── README.md
     ├── defaults
     │   └── main.yml
     ├── files
     ├── handlers
     │   └── main.yml
     ├── meta
     │   └── main.yml
     ├── tasks
     │   └── main.yml
     ├── templates
     ├── tests
     │   ├── inventory
     │   └── test.yml
     └── vars
         └── main.yml
   ```

4. ##### 操作Role

   ```bash
   #搜索role
   ansible-galaxy search role_name --author author_name
   #显示role详细信息
   ansible-galaxy info username.role_name
   #显示安装的role及版本
   ansible-galaxy list
   #删除role
   ansible-galaxy remove username.rolename
   ```

   

> 1. [ansible-galaxy官网](<https://galaxy.ansible.com/>)
> 2. [Ansible Galaxy使用小记](https://segmentfault.com/a/1190000004419028)
> 3. [ANSIBLE GALAXY](https://www.cnblogs.com/mhc-fly/p/7119832.html)

