1. ###### ssh使用密钥认证^1^

   ```bash
   #生成密钥对
   ssh-keygen
   #生成密钥对到指定目录
   ssh-keygen -f ${PATH}
   #使用指定密钥对连接远程主机
   ssh -i ${PATH} root@10.0.0.2
   #设置私钥密码
   ssh-keygen -p '123456' 
   #生成指定的加密类型的密钥对
   ssh-keygen -t ${type} 
   type=rsa, dsa, ecdsa, ed25519
   #生成指定位数的密钥
   ssh-keygen -b 2048 
   #将公钥添加到远程主机
   ssh-copy-id root@10.0.0.2 -p 22
   ```

2. ###### ansible清单配置^2^

   配置文件位于“/etc/ansible/hosts”

   ```bash
   [A]
   172.18.0.1
   
   [B]
   172.18.0.2
   
   [C]
   172.18.0.3
   172.18.0.4
   
   [D]
   172.18.0.[1:2]
   
   [E:children]
   C
   D
   
   172.18.0.5
   
   #或者使用ymal语言
   all:
     hosts:
       172.18.0.5:
     children:
       A:
         hosts:
           172.18.0.1:
       B:
         hosts:
           172.18.0.2:
       E:
         children:
           C:
             hosts:
               172.18.0.3:
               172.18.0.4:
           D:
             hosts:
               172.18.0.1:
               172.18.0.2:
   ```

   

> 1. [ssh使用密钥认证](<http://www.zsythink.net/archives/2375>)
> 2. [清单配置详解](<http://www.zsythink.net/archives/2509>)