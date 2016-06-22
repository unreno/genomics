#### AIM Creation Notes

Initial AIM image id : ami-f303fb93


##### Initial settings check (minimize changes)

Input:
```BASH
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


Output:
```BASH


```



##### Environment Changes


```BASH
cat <<HERE ~/.bashrc
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
```


```BASH
>cat <<HERE >> ~/.inputrc
set editing-mode vi
"\e[A": history-search-backward
"\e[B": history-search-forward
set completion-ignore-case on
HERE
```


##### Software Updates and Additions

Add mysql/mariadb settings to access the current queue, although will likely change.

```BASH
vi ~/awsqueue.cnf	
chmod 400 ~/awsqueue.cnf
```

Make instance suicidable (comment out "Defaults requiretty" and "Defaults !visiblepw")
```BASH
sudo visudo 
```

Update the basic yum installed packages and add a few needed for compiling samtools.

```BASH
sudo yum update
sudo yum install gcc ncurses-devel zlib-devel	
```

MAY need to install the aws client package.
I think this is preinstalled, but will need to be able to update anyway, so...

```BASH
pip install --user --upgrade awscli
```


###### plink
mkdir -p ~/.local/bin
mkdir ~/plink
cd ~/plink
wget http://www.cog-genomics.org/static/bin/plink160607/plink_linux_x86_64.zip
unzip plink_linux_x86_64.zip
mv plink ~/.local/bin
cd ~

###### bowtie2
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.9/bowtie2-2.2.9-linux-x86_64.zip/download -O bowtie2-2.2.9-linux-x86_64.zip
unzip bowtie2-2.2.9-linux-x86_64.zip
mv bowtie2-2.2.9-linux-x86_64/bowtie* ~/.local/bin/


###### samtools
wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
bunzip samtools-1.3.1.tar.bz2
tar xfv samtools-1.3.1.tar
cd samtools-1.3.1
make prefix=~/.local install
















##### Via AWS Web Console create AIM from running instance.



