# Shell 字符

Bash 的字符、变量操作。

[TOC]

## 转义字符

| 字符 | 意义       |
| ---- | ---------- |
| \\\\ | 显示反斜杠 |
| \a   | 警报       |
| \b   | 退格       |
| \f   | 换页       |
| \n   | 换行       |
| \r   | 回车       |
| \t   | 水平制表符 |
| \v   | 垂直制表符 |

`echo -e`： 对转义字符进行替换 ，显示。

## 字符长度

```bash
a="abc"
echo ${#a}
```

## 操作字符

### 顺序提取

```bash
a="0123456789"
echo ${a:3}
# 3456789
# ${变量名:起始下标}
# 下标从 0 开始
```

### 尾部提取

```bash
echo ${a:0-3}
# 或（注意空格）
echo ${a: -3}
# 789
```

### 指定长度

#### 长度为正数

```bash
echo ${a:3:3}
# 345
# ${变量名:起始下标:长度}
```

#### 长度为负数

如果 `${a:3:-3}`，长度为负数，则表示从 [3,-3) 的所有字符

```bash
# 0    1  2  3  4  5  6  7  8  9
# 0    1  2  3  4  5  6  7  8  9  正数
# -10 -9 -8 -7 -6 -5 -4 -3 -2 -1  倒序
echo ${a:3:-3}
# 3456
```

### 掐头（保留尾巴）

```bash
a="abc.tar.gz"
echo ${a#*.}
# ${变量名#*分割符}
# tar.gz

echo ${a##*.}
# 最大匹配：两个 # 号
# ${变量名##*分割符}
# gz
```

### 去尾（保留头部）

```bash
echo ${a%.*}
# ${变量名%分割符*}
# abc.tar

echo ${a%%.*}
# 最大匹配：两个 % 号
# ${变量名%%分割符*}
# abc
```

### 字符替换

```bash
a="abcABCabc"

# 替换一次
echo ${a/a/A}
# AbcABCabc

# 全部替换
echo ${a//a/A}
# AbcABCAbc
```

### 字符删除

```bash
a="abcABCabc"

# 删除一次
${变量名/删除的字符}
echo ${a/b}
# acABCabc

# 全部删除
echo ${a//b}
# acABCac
```

### 大小写转换

```bash
a="abcABCabc"

# 全部转为小写
echo ${a,,}
# abcabcabc

# 全部转为大写
echo ${a^^}
# ABCABCABC
```

## 变量替换

| 形式             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| ${var}           | 变量本来的值                                                 |
| ${var:-word}     | 如果变量 var 为空或已被删除（unset），那么返回 word，但不改变 var 的值。 |
| ${var:=word}     | 如果变量 var 为空或已被删除（unset），那么返回 word，并将 var 的值设置为 word。 |
| ${var:？message} | 如果变量 var 为空或已被删除（unset），那么将消息 message 送到标准错误输出，可以用来检测变量 var 是否可以被正常赋值。 若此替换出现在 Shell 脚本中，那么脚本将停止运行。 |
| ${var:+word}     | 如果变量 var 被定义，那么返回 word，但不改变 var 的值。      |

> [Shell变量](http://c.biancheng.net/cpp/view/6999.html)
>
> [Shell字符串](http://c.biancheng.net/cpp/view/7001.html)
>
> [字符串处理(一)](http://www.zsythink.net/archives/2276)
>
> [字符串处理(二)](http://www.zsythink.net/archives/2296)
>
> [字符串处理(三)](http://www.zsythink.net/archives/2311)
