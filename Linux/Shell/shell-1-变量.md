1. #### 变量创建与撤销

   ```bash
   #变量创建
   var="abc"
   #变量引用
   echo ${var}
   #变量撤销
   unset var
   ##函数撤销
   unset -f 函数名
   ```

2. #### 变量作用域

   1. ##### 本地变量

      作用域：只在当前的bash进程中有效，对当前shell之外的其他shell进程无效，包括当前shell的子进程。

      1. ###### 局部变量

         ```bash
         #定义局部变量
         local var="abc"
         ```

         作用域：只对当前函数或者代码段有效。

      2. ###### 全局变量

         ```bash
         #/bin/bash
         
         var="abc"
         
         function echo_local_var() {
             local var="123"
             echo ${var}
         }
         
         function echo_var() {
             var="098"
             echo ${var}
         }
         
         echo ${var}
         #local只影响函数内的变量
         echo_local_var
         echo ${var}
         #全局变量，相当与覆盖原值
         echo_var
         echo ${var}
         
         #########
         #echo 输出
         #abc
         #123
         #abc
         #098
         #098
         ##########
         ```

   2. ###### 环境变量

      ```bash
      #定义
      export var="abc"
      ```

      作用域：当前shell进程和其子进程。

   3. ###### 只读变量

      ```bash
      #定义
      readonly var="abc"
      ```

      只读变量设置后**不能修改，不可撤销**，如果想要变量失效，则需要退出当前shell。

      **子进程不能继承只读变量**，如果需要，可将变量定义为“环境只读变量”

      ```bash
      #定义环境只读变量
      export readonly var="abc"
      ```

   4. ###### 特殊变量

      - $?

        保存了上一条命令的状态返回值（0 - 255）。

        返回值0：上一条命令执行正确。

        返回值1-255：上一条命令执行错误。

      - $#

        传入脚本参数的个数。

      - $* $@
        $@参数列表，获取到所有参数
        ${@:起点}  表示由起点开始（包括起点），取得后面的所有的位置参数
        ${@:起点:个数} 表示由起点开始（包括起点），取得指定个数的位置参数

        $@ $* 只在被**双引号包起来的时候会有差异**
        "$*": 传递给脚本的所有参数，全部参数合为一个字符串
        "$@": 传递给脚本的所有参数，每个参数为独立字符串

      - $0,$1,$2...${10},${11}…

        $0：脚本本身

        $1：第一个参数

        $2：第二个参数

        **可用shift剔除参数**

        ```bash
        #剔除一个参数
        shift
        #剔除n个参数
        shift n 
        ```

   5. ###### 其他创建方式

         ```bash
         declare var="abc"
         #-i 表示为整形
         declare -i var=0
         #-x 表示为环境变量
         declare -x var="abc"
         #-r 表示为只读变量
         declare -r var="abc"
         ```

   

   > [bash变量详解](http://www.zsythink.net/archives/279)
