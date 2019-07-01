1. 字符串

   ```python
   # 原始字符串,字符串前加'r'
   >>>print(r'C:\now')
   C:\now
   ```

2. 布尔类型

   ```python
   # 布尔值可计算，true=1，false=0
   >>>True + True
   2
   >>>True * False
   0
   ```

3. 类型转换

   ```python
   # str to int
   >>>a = "1234"
   >>>b = int(a)
   >>>b
   1234
   # float to int（截断）
   >>>a = 5.99
   >>>b = int(a)
   >>>b
   5
   
   # str to float
   >>>a = "520"
   >>>b = float(a)
   >>>b
   520.0
   # int to float
   >>>a = 520
   >>>b = float(a)
   >>>b
   520.0
   
   # int to str
   >>>a = 520
   >>>b = str(a)
   >>>b
   '520'
   # float to str
   >>>a = 520.0
   >>>b = str(a)
   >>>b
   '520.0'
   ```

4. 判断类型

   ```python
   >>>a = 520
   >>>isinstance(a, int)
   True
   ```

5. 幂操作

   ```python
   >>>-3 ** 2
   -9
   >>>3 ** -2
   0.11111111
   ```

6. 优先级

   ```python
   # 幂运算(**) > 正负号(+-) > 算数运算符(+-*/) > 比较运算符(><==!=) > 逻辑运算符(and or not)
   ```

7. 条件表达式

   ```python
   x, y = 4, 5
   if x < y:
       small = x
   else:
       small = y
       
   small = x if x < y else y
   ```

8. 列表

   ```python
   member = []
   
   # 添加一个元素
   >>>member.append(1)
   [1]
   # 添加多个元素(列表)
   >>>member.extend([2, 3])
   [1, 2, 3]
   # 添加元素(顺序)
   member.insert(0, 0)
   [0, 1, 2, 3]
   
   # 获取元素
   >>>member[2]
   2
   # 元素互换
   >>>member[0], member[2] = member[2], member[0]
   [2, 1, 0, 3]
   
   # 删除特定位置的元素
   >>>member.remove(0)
   [2, 1, 3]
   # 删除一个元素
   >>>del member[1]
   [2, 3]
   # 弹出最后的值
   >>>member.pop()
   3
   # 弹出特定位置的值
   >>>member.pop(0)
   2
   
   # 分片
   >>>member[1:3]
   [1, 2]
   ```

   ```python
   >>>a = [1]
   >>>b = [2]
   >>>a > b
   False
   
   # 顺序对比
   >>>a = [1,3]
   >>>b = [2,2]
   >>>a > b
   False
   ```

   ```python
   # 列表拷贝
   >>>list1 = [1, 2, 4, 3]
   >>>list2 = list1[:]
   >>>list3 = list1
   
   # 排序
   >>>list1.sort(reverse=True)
   >>>list1
   [4, 3, 2, 1]
   >>>list2**重点**
   [1, 2, 4, 3]
   >>>list3**重点**
   [4, 3, 2, 1]
   ```

9. 元组

   ```python
   # 创建一个元素的元组(注意,)
   >>> tuple1 = (1,)
   >>> tuple2 = 1,
   ```

10. 字符串格式化

    ```python
    >>>"{1} erer {2}".format("a", "b")
    a erer b
    >>>"{a} erer {b}".format(a="a", b="b")
    a erer b
    >>>"{0:.1f}{1}".format(27.658, 'GB')
    27.7GB
    ```

11. Python 里面如何拷贝一个对象？（赋值、浅拷贝、深拷贝的区别）

    ```python
    # 赋值是将一个对象的地址赋值给一个变量，让变量指向该地址（旧瓶装旧酒）
    # 浅拷贝就是对引用的拷贝
    # 深拷贝是对对象的资源的拷贝
    
    a = ['hello',[1,2,3]]
    b = a[:]
    print([id(x) for x in a])
    print([id(x) for x in b])
    a[0] = 'world'
    a[1].append(4)
    print(a)
    print(b)
    
    [34305224, 33841800]
    [34305224, 33841800]
    ['world', [1, 2, 3, 4]]
    ['hello', [1, 2, 3, 4]]
    # 浅拷贝是在另一块地址中创建一个新的变量或容器，但是容器内的元素的地址均是源对象的元素的地址的拷贝。也就是说新的容器中指向了旧的元素（新瓶装旧酒）。
    
    from copy import deepcopy
    a = ['hello',[1,2,3]]
    b = deepcopy(a)
    print([id(x) for x in a])
    print([id(x) for x in b])
    a[0] = 'world'
    a[1].append(4)
    print(a)
    print(b)
    
    [30766280, 30785352]
    [30766280, 31727688]
    ['world', [1, 2, 3, 4]]
    ['hello', [1, 2, 3]]
    # 深拷贝是在另一块地址中创建一个新的变量或容器，同时容器内的元素的地址也是新开辟的，仅仅是值相同而已，是完全的副本。也就是说（新瓶装新酒）。
    
    总 结：
    （1）当对象为不可变类型时，不论是赋值，浅拷贝还是深拷贝，那么改变其中一个值时，另一个都是不会跟着变化的。
    （2）当对象为可变对象时，如果是赋值和浅拷贝，那么改变其中任意一个值，那么另一个会跟着发生变化的；如果是深拷贝，是不会跟着发生改变的。
    ```
    
12. 函数闭包

    ```python
    >>>def Fun1(x):
    >>>    def Fun2(y):
    >>>        return x * y
    >>>    return Fun2
    
    >>>i = Fun1(5)
    >>>i(8)
    40
    
    # 函数全局变量(global)
    >>>a, b = 5, 8
    >>>def Fun3():
    >>>    a = 10
    >>>    global b
    >>>    b = 15  
    >>>>   print(a, b)
    >>>Fun3()
    >>>print(a, b)
    10, 15
    5, 15
    
    # 函数内部函数变量(nonlocal)
    >>>defFun4():
    >>>    	x = 5
    >>>        def Fun5():
    >>>            nonlocal x
    >>>            x *= 4
    >>>            return x 
    >>>        return Fun5()
    >>>Fun4()
    20
    ```

13. lambda表达式

    ```python
    >>>def add(x, y):
    >>>    return x + y
    >>>add(4, 5)
    9
    
    >>>g = lambda x, y : x + y
    >>>g(4, 5)
    9
    
    # 过滤函数（filter）
    >>>list(filter(lambda x : x % 2, range(10)))
    [1, 3, 5, 7,9]
    
    # 映射（map）
    >>>list(map(lambda x : x*2, range(10)))
    [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
    ```

14. with语句

    ```python
    # 可以用在for， while，try之中
    # 如果前方全部完成，则显示else中内容
    a = 3
    while a > 0:
        if a < 2:
            break
        a -= 1
    else:
        print(a)
    # 不会显示a的值
    # 如果if a < 2 修改为 if a > 4,则会显示a的值，因为while语句完整执行完了
    ```

    

> [[小甲鱼]零基础入门学习Python](https://www.bilibili.com/video/av4050443)

