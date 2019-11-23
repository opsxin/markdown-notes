# Python 读取文件

- 推荐写法

```python
 with open('file_name', 'r') as file:
   for line in file:
       print(line)
```

- 第二种写法

   ```python
   try:
       file = open('file_name', 'r')
       print file.read()
   finally:
       if file:
           file.close()
   ```

- read方法
  - read（）：每次读取整个文件，它通常将读取的文件内容放到一个字符串变量中，也就是生成一个字符串变量。
适合文件内容少，占用内存小。
  - readline() ：每次读取文件的一行，通常是读取到一行放到一个字符串的变量中，返回字符串类型。
  - readlines()：每次读取整个文件的内容，将读取到的内容放到一个列表中，返回列表类型。
  - readable（）：判断文件是否可读，如果可读则返回True。

- 打开文件的方式
  - r：只读
  - w：只写
  - r+：读写，如文件不存在，则报错。==如果先读取了内容，再写入的话就变成了追加的模式，如果直接写入内容，就是覆盖==
  - w+：读写，如果文件不存在，则创建文件
  - a：追加写
  - a+：追加读写
  - b：二进制读
