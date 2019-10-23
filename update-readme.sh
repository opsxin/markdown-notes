#!/bin/bash

# 不显示 PNG、GIF、WEBP、PDF 格式的文件，最大深度为 3 层
#tree -I "*.png|*.gif|*.webp|*.pdf" -v -L 3 --ignore-case \
#    | awk 'BEGIN{print "```bash"} {print} END{print "```"}' > README.md

# 能正确显示根目录的连接
# 子目录因为连接不包含父目录，所以会造成连接的 404
#tree -I "*.png|*.gif|*.webp|*.pdf" -v --ignore-case \
#    | sed "/md/s|─\ \(.*\)|[\1](https://github.com/opsxin/markdown-notes/blob/master/\1)|" \
#    | sed "s/$/\ \ /" > README.md

# 不能树形显示
#find . -type f -name "*.md" \
#    | sed "s|.|https://github.com/opsxin/markdown-notes/blob/master|" \
#    | sed "s|.*/\(.*\)|[\1](\0)|" | sed "s/$/\ \ /" > README.md

# URL 正确，但是 PC 端显示会有些变形，Mobile 端正常
tree -I "*.png|*.gif|*.webp|*.pdf" -v -L 3 --ignore-case \
    -H 'https://github.com/opsxin/markdown-notes/blob/master' \
    | awk 'BEGIN{print "Markdown-Notes<br/>"} /─/{print} /directories/{print "<br/>" $0}' \
    > README.md
