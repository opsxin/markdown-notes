#### bash中<、<<、<<<和<()的区别

1. ##### < ^1^

   1. 作用：将文件的内容传递给命令的标准输入。

      ```bash
      # cat < /etc/os-release 
      PRETTY_NAME="Debian GNU/Linux 9 (stretch)"
      NAME="Debian GNU/Linux"
      VERSION_ID="9"
      VERSION="9 (stretch)"
      ID=debian
      HOME_URL="https://www.debian.org/"
      SUPPORT_URL="https://www.debian.org/support"
      BUG_REPORT_URL="https://bugs.debian.org/"
      ```

   2. cat FILENAME 和 cat < FILENAME 的区别

      cat FILENAME：打开一个文件，并标准输出。

      cat < FILENAME：Shell打开文件，作为**cat**的标准输入。

      ```bash
      #文件权限不同，可能造成不同的结果
      $ sudo cat myfile.txt #可以正常显示文件
      $ sudo cat < myfile.txt #可能显示权限不足
      ```
   
2. ##### <<
   
   1. **<<**：表示here document^2^。
   
      ```bash
      cat > myfile.txt << EOF
      heredoc> num 1
      heredoc> num 2
      heredoc> EOF
      ```
   
   2. EOF 和 ’EOF‘ 的区别^3^
   
      如果没有引号，文档中的任何变量，转义等都将正常显示。
   
      ```bash
      $ a="1"
      $ cat << EOF
      heredoc> $a
      heredoc> num 1
      heredoc> num 2
      heredoc> EOF
      1 #注意和后面的区别
      num 1
      num 2
      
      $ cat << 'EOF'
      heredoc> $a
      heredoc> num 1
      heredoc> num 2
      heredoc> EOF
      $a #
      num 1
      num 2
      ```
   
3. ##### <<<
   
   **<<<**：表示here string^4^。
   
   将*<<<*之后的字符串传递给命令，作为命令的标准输入。
   
   ```bash
   $ echo "here String" | md5sum
   9ba29404848a21242c538d9d521bf753  -
   
   $ md5sum <<< "here String"
   9ba29404848a21242c538d9d521bf753  -
   
   $ md5sum << EOF
   heredoc> here String
   heredoc> EOF
   9ba29404848a21242c538d9d521bf753  -
   ```
   
4. ##### <()^5^

   1. <()：传递了需要打开和读取的文件的名称。

      ```bash
      $ cat <(date)
      Fri May 24 12:53:32 CST 2019
      Fri May 24 12:53:32 CST 2019
      
      $ echo <(date)
      /proc/self/fd/11 /proc/self/fd/12
      ```

   2. < <()：将<()产生的文件输入重定向到命令中。

      ​		管道和输入重定向将内容推送到STDIN流。进程替换运行命令，将其输出保存到特殊的临时文件，然后传递该文件名代替命令。无论您使用什么命令，都将其视为文件名。**请注意，创建的文件不是常规文件，而是在不再需要时自动删除的命名管道**。

      ```bash
      $ wc -l < <(cat /etc/os-release) 
      8
      $ wc -l <(cat /etc/os-release) 
      8 /proc/self/fd/11
      $ wc -l /etc/os-release 
      8 /etc/os-release
      
      $ cat < <(date)
      Fri May 24 12:59:58 CST 2019
      $ echo < <(date)
      <Blank> #由于echo不读取STDIN并且没有传递任何参数，因此我们什么也得不到.
      ```

      

> 1. [difference-between-cat-and-cat](<https://unix.stackexchange.com/questions/258931/difference-between-cat-and-cat>)
> 2. [Here document](<https://en.wikipedia.org/wiki/Here_document>)
> 3. [command-line-instead-of](<https://unix.stackexchange.com/questions/76402/command-line-instead-of>)
> 4. [Here Strings](<http://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Here-Strings>)
> 5. [Process substitution and pipe](https://unix.stackexchange.com/questions/17107/process-substitution-and-pipe)
> 6. [whats-the-difference-between-and-in-bash](<https://askubuntu.com/questions/678915/whats-the-difference-between-and-in-bash>)

