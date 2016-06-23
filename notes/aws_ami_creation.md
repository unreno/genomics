#### AMI Creation Notes

Initial AMI image id : ami-f303fb93
Region : us-west-2 (Oregon)


##### Initial settings check (minimize changes)

```BASH
echo $PS1
[\u@\h \W]\$
```

Input:
```BASH
PS1="\n> "
ls /usr/bin/env	#	many of my scripts use this
echo $PATH
bash --version
env --version
uname -a
df -h
python --version
pip --version
python -m site --user-site
awk --version
gawk --version
git --version
aws --version
lsof -v
ulimit
ulimit -a
ls -la ~/
env
set
```

```BASH
#	requires bash >= 4.0
#	${VARIABLE^^} converts to uppercase
#	${VARIABLE,,} converts to lowercase
#	[[ ${ext,,} =~ sam ]] && flag='-S' || flag=''
```

```BASH
#	Also NEED gawk, not just awk for a couple scripts.
#
#	The bitwise command "and" is used when evaluating some sam files.
#		( and( $2 , 64 ) ){ 
#
#	In one case, control chars found on EVERY line if this were awk instead of gawk
#		(/[[:cntrl:]]/)
#
#	Lastly, older versions did not support "interval expressions"
#		ie ({4}, {4,}, {4,6})
```


Output:
```BASH
> ls /usr/bin/env
/usr/bin/env

> echo $PATH
/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/.local/bin:/home/ec2-user/bin

> bash --version
GNU bash, version 4.2.46(1)-release (x86_64-redhat-linux-gnu)
Copyright (C) 2011 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

> env --version
env (GNU coreutils) 8.22
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Richard Mlynarik and David MacKenzie.

> uname -a
Linux ip-172-31-0-147 4.4.11-23.53.amzn1.x86_64 #1 SMP Wed Jun 1 22:22:50 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

> df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      7.8G  1.2G  6.6G  15% /
devtmpfs        490M   56K  490M   1% /dev
tmpfs           498M     0  498M   0% /dev/shm

> python --version
Python 2.7.10

> pip --version
pip 6.1.1 from /usr/lib/python2.7/dist-packages (python 2.7)

> python -m site --user-site
/home/ec2-user/.local/lib/python2.7/site-packages

> awk --version
GNU Awk 3.1.7
Copyright (C) 1989, 1991-2009 Free Software Foundation.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

> gawk --version
GNU Awk 3.1.7
Copyright (C) 1989, 1991-2009 Free Software Foundation.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

> git --version
-bash: git: command not found

> aws --version
aws-cli/1.10.33 Python/2.7.10 Linux/4.4.11-23.53.amzn1.x86_64 botocore/1.4.23

> lsof -v
lsof version information:
    revision: 4.82
    latest revision: ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/
    latest FAQ: ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/FAQ
    latest man page: ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/lsof_man
    constructed: Sat Jul 7 07:45:06 UTC 2012
    constructed by and on: mockbuild@gobi-build-31006.sea31.amazon.com
    compiler: cc
    compiler version: 4.4.6 20110731 (Red Hat 4.4.6-3) (GCC) 
    compiler flags: -DLINUXV=26016 -DGLIBCV=212 -DHASIPv6 -DHASSELINUX -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -DHAS_STRFTIME -DLSOF_VSTR="2.6.16" -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic -fno-strict-aliasing
    loader flags: -L./lib -llsof  -lselinux
    system info: Linux gobi-build-31006.sea31.amazon.com 2.6.18-164.el5az00 #1 SMP Tue Sep 15 14:19:07 EDT 2009 x86_64 x86_64 x86_64 GNU/Linux
    Anyone can list all files.
    /dev warnings are disabled.
    Kernel ID check is disabled.

> ulimit
unlimited

> ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 3914
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 3914
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

> ls -la ~/
total 28
drwx------ 3 ec2-user ec2-user 4096 Jun 22 21:35 .
drwxr-xr-x 3 root     root     4096 Jun 22 21:26 ..
-rw------- 1 ec2-user ec2-user    5 Jun 22 21:35 .bash_history
-rw-r--r-- 1 ec2-user ec2-user   18 Feb 19 20:05 .bash_logout
-rw-r--r-- 1 ec2-user ec2-user  193 Feb 19 20:05 .bash_profile
-rw-r--r-- 1 ec2-user ec2-user  124 Feb 19 20:05 .bashrc
drwx------ 2 ec2-user ec2-user 4096 Jun 22 21:26 .ssh

> env
LESS_TERMCAP_mb=
HOSTNAME=ip-172-31-0-147
LESS_TERMCAP_md=
LESS_TERMCAP_me=
TERM=xterm-256color
SHELL=/bin/bash
HISTSIZE=1000
EC2_AMITOOL_HOME=/opt/aws/amitools/ec2
SSH_CLIENT=134.197.29.93 57387 22
LESS_TERMCAP_ue=
SSH_TTY=/dev/pts/0
USER=ec2-user
LS_COLORS=rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:
EC2_HOME=/opt/aws/apitools/ec2
LESS_TERMCAP_us=
MAIL=/var/spool/mail/ec2-user
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/.local/bin:/home/ec2-user/bin
PWD=/home/ec2-user
JAVA_HOME=/usr/lib/jvm/jre
AWS_CLOUDWATCH_HOME=/opt/aws/apitools/mon
LANG=en_US.UTF-8
HISTCONTROL=ignoredups
SHLVL=1
HOME=/home/ec2-user
AWS_PATH=/opt/aws
AWS_AUTO_SCALING_HOME=/opt/aws/apitools/as
LOGNAME=ec2-user
AWS_ELB_HOME=/opt/aws/apitools/elb
SSH_CONNECTION=134.197.29.93 57387 172.31.0.147 22
LESSOPEN=||/usr/bin/lesspipe.sh %s
LESS_TERMCAP_se=
_=/bin/env

> set
AWS_AUTO_SCALING_HOME=/opt/aws/apitools/as
AWS_CLOUDWATCH_HOME=/opt/aws/apitools/mon
AWS_ELB_HOME=/opt/aws/apitools/elb
AWS_PATH=/opt/aws
BASH=/bin/bash
BASHOPTS=checkwinsize:cmdhist:expand_aliases:extquote:force_fignore:hostcomplete:interactive_comments:login_shell:progcomp:promptvars:sourcepath
BASH_ALIASES=()
BASH_ARGC=()
BASH_ARGV=()
BASH_CMDS=()
BASH_LINENO=()
BASH_SOURCE=()
BASH_VERSINFO=([0]="4" [1]="2" [2]="46" [3]="1" [4]="release" [5]="x86_64-redhat-linux-gnu")
BASH_VERSION='4.2.46(1)-release'
COLUMNS=109
DIRSTACK=()
EC2_AMITOOL_HOME=/opt/aws/amitools/ec2
EC2_HOME=/opt/aws/apitools/ec2
EUID=500
GROUPS=()
HISTCONTROL=ignoredups
HISTFILE=/home/ec2-user/.bash_history
HISTFILESIZE=1000
HISTSIZE=1000
HOME=/home/ec2-user
HOSTNAME=ip-172-31-0-147
HOSTTYPE=x86_64
ID=500
IFS=$' \t\n'
JAVA_HOME=/usr/lib/jvm/jre
LANG=en_US.UTF-8
LESSOPEN='||/usr/bin/lesspipe.sh %s'
LESS_TERMCAP_mb=$'\E[01;31m'
LESS_TERMCAP_md=$'\E[01;38;5;208m'
LESS_TERMCAP_me=$'\E[0m'
LESS_TERMCAP_se=$'\E[0m'
LESS_TERMCAP_ue=$'\E[0m'
LESS_TERMCAP_us=$'\E[04;38;5;111m'
LINES=32
LOGNAME=ec2-user
LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'
MACHTYPE=x86_64-redhat-linux-gnu
MAIL=/var/spool/mail/ec2-user
MAILCHECK=60
OPTERR=1
OPTIND=1
OSTYPE=linux-gnu
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/.local/bin:/home/ec2-user/bin
PIPESTATUS=([0]="0")
PPID=2561
PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
PS1='\n> '
PS2='> '
PS4='+ '
PWD=/home/ec2-user
SHELL=/bin/bash
SHELLOPTS=braceexpand:emacs:hashall:histexpand:history:interactive-comments:monitor
SHLVL=1
SSH_CLIENT='134.197.29.93 57387 22'
SSH_CONNECTION='134.197.29.93 57387 172.31.0.147 22'
SSH_TTY=/dev/pts/0
TERM=xterm-256color
UID=500
USER=ec2-user
_=env
colors=/home/ec2-user/.dircolors
```



##### Environment Changes


```BASH
cat <<HERE >> ~/.bashrc
PS1='\[\e[1;1m\][\u@\h \w]\$\[\e[0m\] '
export PYTHONUSERBASE=$HOME/.python
export PATH=\${HOME}/.local/bin:\${HOME}/.python/bin:\${HOME}/.kentUtils/bin:\${HOME}/.blat:\${HOME}/.trinity:\${HOME}/.blast/bin:\${PATH}
export BOWTIE2_INDEXES=\${HOME}/BOWTIE2_INDEXES
alias gzip="gzip --best"
alias grep="grep -is"
alias ..="cd .."
alias cd..="cd .."
alias la="\ls -al --color=auto"
alias ll="\ls -lG --color=auto"
alias ln="ln -s"
alias more="less"
alias rm="rm -i"
alias h=history
alias c="for i in {1..50}; do echo; done"
alias psme="ps -fU \$USER"
alias awsq="mysql_queue.bash --defaults_file ~/awsqueue.cnf"
HERE

ln -s .bashrc BASHRC
```


```BASH
cat <<HERE >> ~/.inputrc
set editing-mode vi
"\e[A": history-search-backward
"\e[B": history-search-forward
set completion-ignore-case on
HERE

ln -s .inputrc INPUTRC
```


##### Software Updates and Additions

Add mysql/mariadb settings to access the current queue, although will likely change.

```BASH
vi ~/awsqueue.cnf	

chmod 400 ~/awsqueue.cnf
```

Make instance suicidable (comment out "Defaults requiretty" and "Defaults !visiblepw")
"Defaults requiretty" did not exist this time. Deprecated?
```BASH
sudo visudo 
```


```BASH
cat <<HERE >> ~/.vimrc
"	shebang line for /bin/sh has this trailing . which makes it ignored when
" using some of vims word based movement keys
"	    *.sh      call SetFileTypeSH(getline(1))
":set iskeyword=@,48-57,_,192-255,.
":set iskeyword=@,48-57,_,192-255
" can't figure out how to override this behaviour
"au BufNewFile,BufRead *.sh
"  \ set iskeyword=@,48-57,_,192-255
"	/opt/local/share/vim/vim74/filetype.vim
"	/opt/local/share/vim/vim74/scripts.vim
" /opt/local/share/vim/vim74/syntax/sh.vim
"
"	show current file type with ...
"	:set ft?
":set g:sh_noisk
"	whooo.  found some code in syntax/sh.vim to checks the existance
" of g:sh_noisk before adding the "." to iskeyword
:let g:sh_noisk = 'something'

:set nobomb

"	link this file as ~/.vimrc

" kind of annoying
":set foldmethod=syntax

"	show special characters
":set invlist (what's the difference between list and invlist?)
":set list

:syntax enable
:set number

":set softtabstop=0
:set ts=2
":set expandtab

" ~/.vim/colors/wendt.vim
:colorscheme wendt

" map movement keys to "Escape" before moving
"	Rather than typing Ctrl-V then Up-Arrow, <up> (and other macros) works
:map! <up>    <esc>k
:map! <down>  <esc>j
:map! <right> <esc>l
:map! <left>  <esc>h

" Jump to last position (set cursor position to the line last at on close)
autocmd BufReadPost *
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\   exe "normal g'\"" |
\ endif

"	As of my recent upgrade to Mountain Lion, vim clears the screen on exit
"	This stops that clearing.  Don't know exactly how though.
:set t_ti= t_te=

"	Just in case some file type specific format options
"	Disable the autocomment marker insertion....
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
HERE

ln -s .vimrc VIMRC
```

```BASH
mkdir -p ~/.vim/colors/

cat <<HERE >> ~/.vim/colors/wendt.vim
" Vim color file

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "wendt"

"
"       term and cterm attributes don't seem to work
"               bold, underline, reverse, standout, italic
"
"       ctermfg
"       ctermbg
"                   *cterm-colors*
"            NR-16   NR-8    COLOR NAME ~
"            0       0       Black
"            1       4       DarkBlue
"            2       2       DarkGreen
"            3       6       DarkCyan
"            4       1       DarkRed
"            5       5       DarkMagenta
"            6       3       Brown, DarkYellow
"            7       7       LightGray, LightGrey, Gray, Grey
"            8       0*      DarkGray, DarkGrey
"            9       4*      Blue, LightBlue
"            10      2*      Green, LightGreen
"            11      6*      Cyan, LightCyan
"            12      1*      Red, LightRed
"            13      5*      Magenta, LightMagenta
"            14      3*      Yellow, LightYellow
"            15      7*      White
"

hi Comment      ctermfg=Black
hi! link MoreMsg  Comment
hi! link Question Comment

hi Constant     ctermfg=DarkGrey
hi link String    Constant
hi link Character Constant
hi link Boolean   Constant
hi link Number    Constant
hi link Float     Number

hi Special      ctermfg=Magenta
hi link SpecialChar    Special
hi link Delimiter      Special
hi link SpecialComment Special
hi link Debug          Special

hi Identifier   ctermfg=DarkBlue
hi link Function Identifier

hi Statement    ctermfg=DarkRed
hi link Conditional Statement
hi link Repeat      Statement
hi link Label       Statement
hi link Operator    Statement
hi link Keyword     Statement
hi link Exception   Statement

hi PreProc      ctermfg=Magenta
hi link Include   PreProc
hi link Define    PreProc
hi link Macro     PreProc
hi link PreCondit PreProc

hi Type         ctermfg=Blue
hi link StorageClass Type
hi link Structure    Type
hi link Typedef      Type

hi Visual       ctermfg=Yellow
hi Visual       ctermbg=Red
hi! link ErrorMsg   Visual
hi! link WarningMsg ErrorMsg

hi Search       ctermfg=Black
hi Search       ctermbg=Cyan

hi Tag          ctermfg=DarkGreen

hi Error        ctermfg=White
hi Error        ctermbg=Blue

hi Todo         ctermbg=Yellow
hi Todo         ctermfg=Black

hi StatusLine   ctermfg=Yellow
hi StatusLine   ctermbg=DarkGray
HERE

ln -s .vim/colors/wendt.vim VIMCOLORS
```




Update the basic yum installed packages and add a few needed for compiling samtools.

```BASH
sudo yum update
sudo yum install gcc ncurses-devel zlib-devel	git mysql
```

MAY need to install the aws client package.
I think this is preinstalled, but will need to be able to update anyway, so...

```BASH
sudo pip install --upgrade pip
pip install --user --upgrade awscli pip
```


###### plink
```BASH
mkdir -p ~/.local/bin
mkdir ~/plink
cd ~/plink
wget http://www.cog-genomics.org/static/bin/plink160607/plink_linux_x86_64.zip
unzip plink_linux_x86_64.zip
mv plink ~/.local/bin
cd ~
/bin/rm -rf ~/plink
```

###### bowtie2
```BASH
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.9/bowtie2-2.2.9-linux-x86_64.zip/download -O bowtie2-2.2.9-linux-x86_64.zip
unzip bowtie2-2.2.9-linux-x86_64.zip
mv bowtie2-2.2.9/bowtie* ~/.local/bin/
/bin/rm -rf ~/bowtie2-2.2.9
/bin/rm -rf ~/bowtie2-2.2.9-linux-x86_64.zip
```

###### samtools
```BASH
wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
bunzip2 samtools-1.3.1.tar.bz2
tar xfv samtools-1.3.1.tar
cd samtools-1.3.1
make prefix=~/.local install
cd ~
/bin/rm -rf samtools-1.3.1
/bin/rm -rf samtools-1.3.1.tar
```


###### clone my github repo

```BASH
mkdir -p ~/github/unreno
cp ~/github/unreno
git clone https://github.com/unreno/genomics.git
cd genomics
ln -s Makefile.example Makefile
make install
```


##### Via AWS Web Console create AMI from running instance.

From AWS EC2 Dashboard,
* select the running instance,
* then click Actions -> Image -> Create Image
* and give it a name.
* The running instance will shutdown
* a snapshot and image will be created
* and the instance rebooted (unless No Reboot was selected from Create Image page)






##### Still ToDo

Previously, I noticed that using SQS as a processing queue would crash after running about 1000 jobs.
I believe that this has something to do with limits on process ids.
I should investigate this, perhaps by creating a bunch of quick jobs in a queue and running it.

Given our previous usage, we will likely need to upgrade our limits on volume size from 20TB to 1000TB and instance limit from 20 to 1000?
Just arbitrary guesses at the moment, but 20 will not be enough.


Probably should `yum install gawk env bash vim` to get the latest versions.

