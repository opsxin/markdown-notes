# 适用于 **oh\~my\~zsh** 的主题

XShell 字体推荐使用 **Consolas，11号**
颜色模式使用 **Xterm**

```bash
cat > ~/.oh-my-zsh/themes/hsin.zsh-theme << EOF
# Copy and self modified from xxf.zsh-theme.
# It is recommended to use with a dark background and the font Consolas.
# Colors: black, red, green, yellow, blue, magenta, cyan, and white.

# 08 NOV 2017 - Hsin
# Change some color configurations.
# 07 DEC 2019
# Remove some code.

# Machine name.
local box_name='$([ -f ~/.box-name ] && cat ~/.box-name || echo $HOST)'

# Directory info.
local current_dir='${PWD/#$HOME/~}'

# VCS
YS_VCS_PROMPT_PREFIX1="%{$fg[white]%}on%{$reset_color%} "
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%} "
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}✗"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}✔ "

# Git info.
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# Prompt format: USER at MACHINE in [DIRECTORY] on git:BRANCH STATE \n TIME $
PROMPT="
%{$fg_bold[cyan]%}%n%{$reset_color%} \
%{$fg[white]%}at \
%{$fg_bold[green]%}${box_name}%{$reset_color%} \
%{$fg[white]%}in \
%{$terminfo[bold]$fg[yellow]%}[${current_dir}]%{$reset_color%} \
${git_info}
%{$fg_bold[red]%}%* \
%{$terminfo[bold]$fg[white]%}$ %{$reset_color%}"

if [[ "$USER" == "root" ]]; then
PROMPT="
%{$bg[yellow]%}%{$fg[cyan]%}%n%{$reset_color%} \
%{$fg[white]%}at \
%{$fg_bold[green]%}${box_name}%{$reset_color%} \
%{$fg[white]%}in \
%{$terminfo[bold]$fg[yellow]%}[${current_dir}]%{$reset_color%} \
${git_info}
%{$fg_bold[red]%}%*%{$reset_color%} \
%{$terminfo[bold]$fg[blue]%}# %{$reset_color%}"
fi
EOF
```
