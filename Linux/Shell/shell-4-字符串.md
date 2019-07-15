1. ###### 获取字符串长度

   ```bash
   a="abc"
   echo ${#a}
   ```

2. ###### 截取变量

   ```bash
   a="1234567890"
   #从指定位置截取（下标从0开始）
   echo ${a:4}
   #567890
   
   #倒序截取
   echo ${a:0-3}
   echo ${a: -3}
   #890
   
   #指定长度
   echo ${a:3:3}
   #456
   
   #如果${a:3:-3},长度为负数，则表示从[3,-3)的所有字符
   #0    1  2  3  4  5  6  7  8  9
   #1    2  3  4  5  6  7  8  9  0
   #-10 -9 -8 -7 -6 -5 -4 -3 -2 -1
   echo ${a:3:-3}
   #4567
   ```

3. ###### **截取尾部**

   ```bash
   a="12321123"
   #第一个匹配
   echo ${a#*2}
   #321123
   #最大匹配
   echo ${a##*2}
   #3
   ```

4. ###### **截取首部**

   ```bash
   a="12321123"
   #第一个匹配
   echo ${a%2*}
   #123211
   #最大匹配
   echo ${a%%2*}
   #1
   ```

5. ###### **替换字符串**

   ```bash
   a="12321123"
   #替换一次
   echo ${a/3/a}
   #12a21123
   #全部替换
   echo ${a//3/a}
   12a2112a
   ```

6. ###### 删除字符串

   ```bash
   a="12321123"
   #删除一次
   echo ${a/3}
   #1221123
   #全部删除
   #122112
   ```

7. ###### 大小写转换

   ```bash
   a="abcABC"
   #全部转为大写
   echo #{a^^}
   #ABCABC
   #全部转成小写
   echo ${a,,}
   #abcabc
   ```

8. ###### **变量值判断**

   ```bash
   a=
   b="abc"
   #如果var为空，则返回value，并将value赋值给var；如果var不为空，则返回var本身的值。
   #var不为空时，var值不会被改变；var为空时，var的值会被设置成指定值。
   echo ${a:=123}
   #123
   echo ${a}
   #123
   echo ${b:=123}
   #abc
   echo ${b}
   #abc
   
   #如果var为空，则返回value；如果var不为空，则返回var的值。
   #无论var是否为空，var本身的值不会改变。
   echo ${a:-123}
   #123
   echo ${a}
   # 
   echo ${b:-123}
   #abc
   echo ${b}
   #abc
   
   #如果var不为空，则返回value；如果var为空，则返回空值。
   #无论var是否为空，var本身的值不会改变。
   echo ${a:+123}
   # 
   echo ${a}
   # 
   echo ${b:+123}
   #123
   echo ${b}
   #abc
   
   #如果var为空，那么在当前终端打印error_info；如果var的值不为空，则返回var的值。
   #无论var是否为空，var本身的值都不会改变。
   echo ${a:?123}
   # bash: a: 123
   echo ${a}
   # 
   echo ${b:?123}
   #abc
   echo ${b}
   #abc
   ```

| 形式            | 说明                                                         |
| :-------------- | ------------------------------------------------------------ |
| ${var}          | 变量本来的值                                                 |
| ${var:-word}    | 如果变量 var 为空或已被删除(unset)，那么返回 word，但不改变 var 的值 |
| ${var:=word}    | 如果变量 var 为空或已被删除(unset)，那么返回 word，并将 var 的值设置为 word |
| ${var:?message} | 如果变量 var 为空或已被删除(unset)，那么将消息 message 送到标 准错误输出，可以用来检测变量 var 是否可以被正常赋值。若此替换出现在 Shell 脚本中，那么脚本将停止运行 |
| ${var:+word}    | 如果变量 var 被定义，那么返回 word，但不改变 var 的值        |

```bash
${a:=123}
和
a=${a:-123}
等同
```

```bash
$ a="b"
$ b=2
$ echo ${!a}
2
# 将引入a的变量值再展开

$ foo1="foo1"
$ foo2="foo2"
$ echo ${!foo*}
foo1 foo2
# 显示存在的变量名

$ echo ${!foo1[@]}
0
# 如果变量存在就返回零
# 不存在无返回值
``` 

> [字符串处理(一)](http://www.zsythink.net/archives/2276)
>
> [字符串处理(二)](http://www.zsythink.net/archives/2296)
>
> [字符串处理(三)](http://www.zsythink.net/archives/2311)
