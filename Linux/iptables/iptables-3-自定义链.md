```bash
#新建自定义链
iptables -t filter -N WEB-IN
#自定义链添加规则
iptables -I WEB-IN ... -j ACCEPT
#引用自定义链
iptables - I INPUT -p tcp --dport 80 -j WEB-IN
#重命名自定义链
iptables -E WEB-IN WEB
#删除自定义链
1. 删除INPUT中引用的链
iptables -D INPUT 1
2. 清空WEB链
iptables -F WEB
3. 删除自定义链
iptables -X WEB
```

