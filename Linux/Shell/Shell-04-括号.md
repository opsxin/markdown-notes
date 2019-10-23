# Shell 括号

这篇包含中括号`[]`及尖括号`<`，大括号 `{}` 请看 *Shell-03-字符*。

[TOC]

## 中括号

### `[]` 和 `[[]]` 区别

1. 当使用 `-n` 或者 `-z` 判断变量是否为空时，`[]` 需要在变量的外侧加上双引号，`[[]]` 则不用。

   ```bash
   [ -n "${a}" ]
   [[ -n ${a} ]]
   ```

   原因可参考：[Linux shell if [ -n ] 正确使用方法]( https://blog.csdn.net/ciky2011/article/details/37876119 )

2. 使用 `[[]]` 时，不能使用 `-a` 或者 `-o` 对多个条件进行连接。

3. 使用`[]` 时，使用`-a`或者`-o`对多个条件进行连接，`-a`或者`-o`必须被包含在`[]`之内。

4. 使用`[]`时，如果使用`&&`或者`||`对多个条件进行连接，`&&`或者`||`必须在`[]`之外。

   ```bash
   [[ $a -ge 3 && $b -ge 4 ]]
   [ $a -ge 3 -a $b -ge 4 ]
   [$a -ge 3] && [$b -ge 4]
   ```

5. 使用符号`=~`匹配正则表达式时，只能使用`[[]]`。

6. 使用`>`或者`<`判断字符串的 ASCII 值大小时，如果结合`[]`使用，则必须对`>`或者`<`进行转义。

   ```bash
   [[ $a =~ [0-9]{11} ]]
   ```

   ![panduan](1571808935909.png)

7. `[[]]`更适合逻辑运算，`(())`更适合数值运算。

## 尖括号

### `<`

#### 将文件的内容作为标准输入

```bash
# cat < /etc/os-release 
NAME="CentOS Linux"
VERSION="8 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="8"
PLATFORM_ID="platform:el8"
PRETTY_NAME="CentOS Linux 8 (Core)"
...
```

#### `cat FILENAME` 和 `cat < FILENAME` 区别

`cat FILENAME`：打开一个文件，并标准输出。

`cat < FILENAME`：Shell 打开文件，并作为 `cat` 的标准输入。

文件权限不同，可能造成不同的结果。

```bash
# 可以正常显示文件
sudo cat myfile.txt 
# 可能显示权限不足
sudo cat < myfile.txt 
```

### `<<`

#### here document

```bash
cat > myfile.txt << EOF
num 1
num 2
EOF
```

#### `EOF` 和 `'EOF'` 区别

如果没有引号，文档中的任何变量，转义等都将正常显示。

```bash
a="1"
cat << EOF
$a
num 1
EOF
# 注意和后面的区别
# 1
# num 1

cat << 'EOF'
$a
num 1
EOF
# $a
# num 1
```

### `<<<`

#### here string

将 `<<<` 之后的字符串传递给命令，作为命令的标准输入。

```bash
echo "here String" | md5sum
# 9ba29404848a21242c538d9d521bf753  -

md5sum <<< "here String"
# 9ba29404848a21242c538d9d521bf753  -

md5sum << EOF
here String
EOF
# 9ba29404848a21242c538d9d521bf753  -
```

### `<()`

传递需要打开和读取的文件的名称。

```bash
cat <(date)
# Wed Oct 23 05:49:49 UTC 2019

echo <(date)
# /proc/self/fd/11
```

### `< <()`

将`<()`产生的文件输入重定向到命令中。

管道和输入重定向将内容推送到 `STDIN` 流。进程替换运行命令，将其输出保存到特殊的临时文件，然后传递该文件名代替命令。无论您使用什么命令，都将其视为文件名。**请注意，创建的文件不是常规文件，而是在不再需要时自动删除的命名管道**。

```bash
wc -l < <(cat /etc/os-release) 
# 17
wc -l <(cat /etc/os-release) 
# 17 /dev/fd/63
wc -l /etc/os-release 
# 17 /etc/os-release

cat < <(date)
# Wed Oct 23 05:53:40 UTC 2019
echo < <(date)
# <Blank> 
# 由于 echo 不读取 STDIN 并且没有传递任何参数，因此什么也没有。
```

<br/>

>1. [difference-between-cat-and-cat](<https://unix.stackexchange.com/questions/258931/difference-between-cat-and-cat>)
>2. [Here document](<https://en.wikipedia.org/wiki/Here_document>)
>3. [command-line-instead-of](<https://unix.stackexchange.com/questions/76402/command-line-instead-of>)
>4. [Here Strings](<http://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Here-Strings>)
>5. [Process substitution and pipe](https://unix.stackexchange.com/questions/17107/process-substitution-and-pipe)
>6. [whats-the-difference-between-and-in-bash](<https://askubuntu.com/questions/678915/whats-the-difference-between-and-in-bash>)







   

   

   

