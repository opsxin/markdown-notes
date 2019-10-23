自用的 vim 配置。

1. 行号显示
2. Tab 转 4 个空格
3. 语法高亮
4. 查找匹配高亮
5. 记录上次鼠标位置

```bash
cat >> ~/.vimrc << EOF
filetype on
filetype plugin on
filetype indent on 
set langmenu=none
set fileencodings=utf-8
set fileencoding=utf-8
set encoding=utf8
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set number
set hlsearch
set incsearch
set pastetoggle=<F9>
syntax on
syntax enable
colorscheme desert
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
EOF
```
