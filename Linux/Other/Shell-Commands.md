# Shell Commands

[TOC]

## 合并行

```bash
$ cat test.txt
1 2
3 4
5 6
7 8
```

### 奇偶行合并

```bash
$ sed "N;s/\n/ /" test.txt
1 2 3 4
5 6 7 8
```

### 指定行合并

第三，四行合并

```bash
$ sed "3N;s/\n/ /" test.txt
1 2
3 4
5 6 7 8
```

### 所有行合并

```bash
$ sed ':a;N;$!ba;s/\n/ /g' test.txt
1 2 3 4 5 6 7 8
```

> `:a`：label
>
> `$!`：尾行不执行
>
> `ba`：无条件跳转到 label a
>
> [Branching-and-flow-control]( https://www.gnu.org/software/sed/manual/html_node/Branching-and-flow-control.html )

## 删除行

```bash
$ cat test.txt
1 2 3
3 4 5
5 6 7
7 8 9
```

### 删除含有 3 的行

```bash
$ sed "/3/d" test.txt
5 6 7
7 8 9
```

### 删除含有 3，4 的行

```bash
#sed "1,${/3/{/4/d}}" test.txt
$ sed "{/3/{/4/d}}" test.txt
1 2 3
5 6 7
7 8 9
```

## 插入行

### 插入第一行

```bash
$ sed "1i 10 11 12" test.txt
10 11 12
1 2 3
3 4 5
5 6 7
7 8 9
```

### 追加尾行

```bash
$ sed "$ a 10 11 12" test.txt
1 2 3
3 4 5
5 6 7
7 8 9
10 11 12
```

## 跳过行

```bash
$ sed "s/ /,/g;n" test.txt
1,2,3
3 4 5
5,6,7
7 8 9
```

跳过第三行（2+1）

```bash
$ sed "s/ /,/g;2n" test.txt
1,2,3
3,4,5
5 6 7
7,8,9
```

## 重复行

### 只保留第一次出现的行

```bash
$ cat test.txt
1 2 1
1 2 2
1 2 3
1 2 4
1 2 5
2 3 1
2 3 2
2 3 3
2 3 4
2 3 5
```

按第 1 列

```bash
$ awk '!a[$1]++ {print}' test.txt
1 2 1
2 3 1
```

按第 2 列

```bash
$ awk '!a[$2]++ {print}' test.txt
1 2 1
2 3 1
```

## 显示行数

```bash
$ awk 'END {print NR}' test.txt
10
```

```bash
$ wc -l test.txt
10
```

## 删除 RC 状态的包（Debian）

> r: the package is marked for removal.
>
> c: the configuration files are currently present in the system.

```bash
dpkg -l | grep ^rc | cut -d' ' -f3| sudo xargs dpkg -P
```

## 显示根的磁盘信息

```bash
df -h | awk '/\/$/ {print "disk total:" $2 " free:" $4}'
```

## CPU 最近 5 次 id 信息

```bash
vmstat 1 5 | awk 'NR>=3 {id += $15} END {print "cpu id:" id/5}'
```

## 显示特定 app 内存

```bash
ps -e -o 'pid,args,user,pmem' | grep "${APP_NAME}" | grep -v 'grep' | awk '{print "app use mem:" 0.15*$4 "G"}'
```
