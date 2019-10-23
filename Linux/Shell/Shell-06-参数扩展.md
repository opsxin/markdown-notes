# Shell 参数扩展

Bash 中的一些参数扩展（Parameter Expansion）。

[TOC]

## 间接参数

 被引用的参数不是 PARAMETER 自身，而是 PARAMETER 的值。

```bash
a="123"
b="a"
echo ${!b}
# 123
```

## 大小写替换

```bash
a="abcABCabcABC"

# 替换一次
# 第一个字符变大写
echo ${a^}
# 第一个字符变小写
echo ${a,}
# 第一个字符变反转
echo ${a~}
# AbcABCabcABC abcABCabcABC AbcABCabcABC

# 全部替换
# 大写
echo ${a^^}
# 小写
echo ${a,,}
# 反转
echo ${a~}
# ABCABCABCABC abcabcabcabc ABCabcABCabc
```

## 查找变量

```bash
fo1="111"
fo2="111"
foo1="111"
foo2="111"

# ${!变量前缀@}
# ${!变量前缀*}
echo ${!fo@}
# fo1 fo2 foo1 foo2
echo ${!foo@}
# foo1 foo2
```

<br/>

> [Shell Bash 中的参数扩展]( https://www.jianshu.com/p/c623ef6f2342 )