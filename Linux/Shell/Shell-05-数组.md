# Shell 数组

 Bash Shell 只支持一维数组（不支持多维数组），初始化时不需要定义数组大小，下标由 0 开始 。

[TOC]

## 定义

```bash
array_name=(value0 value1 value2 value3)
# 或
array_name=(
value0
value1
value2
value3
)
# 或
array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
# 或
array_name=([2]=value0 [3]=value1 [7]=value2)
```

**可以不使用连续的下标，而且下标的范围没有限制。**

## 读取

### 获取单个

```bash
# ${数组名[下标]}
echo ${array_name[2]}
```

### 获取所有

```bash
# ${数组名[*]}
# ${数组名[@]}
echo ${array_name[@]}
```

## 数组长度

```bash
# ${#数组名[@/*]}
echo ${#array_name[@]}
```

## 提取

和字符提取相似。

```bash
a=(1 2 3 4 5)

# ${变量[@]:起始下标:长度}
echo ${a[*]:2:2}
# 3 4
```

## 替换

和字符替换相似。

```bash
a=(1 2 3 4 5)

# ${变量名[@/*]/原始字符/替换字符}
echo ${a[@]/3/5}
# 1 2 5 4 5
```

> [Shell数组]( http://c.biancheng.net/cpp/view/7002.html )
>
> [Linux shell数组建立及使用]( https://www.jianshu.com/p/10359d0924cf )
