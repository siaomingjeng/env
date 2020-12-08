#! /usr/bin/env bash

LOG(){ echo -e "\e[38;5;40m`date`: $@ \e[39m";}

LOG "Stop SSH Host Key Checking . . . "
sed -i 's/#.*StrictHostKeyChecking .*/StrictHostKeyChecking no/' /etc/ssh/ssh_config

LOG "Install EPEL Repo . . . "
dnf install epel-release -y

LOG "Update System . . . "
dnf update -y

LOG "Groupinstall Development Tools . . . "
dnf groupinstall 'Development Tools' -y

LOG "Install python3-pip python3-devel expect. . . "
dnf install python3-pip python3-devel expect -y

LOG "Update pip . . . "
pip3 install --upgrade pip

LOG "Install ansible[azure] . . . "
if [ "A$1" == "Alatest" -o "A$1" == "A" ]
then
    LOG "Install latest ansible[azure] . . . "
    pip3 install ansible[azure]==2.9.15 #2.10 has issues with resourse group creation
else
   LOG "Install ansible[azure]==$1 . . . "
   pip3 install ansible[azure]==$1
fi

LOG "Install virtualenv . . . "
pip3 install virtualenv

LOG "set python reminder . . . "
cat>~/.pystartup.py<<EOF
import readline
import rlcompleter

if 'libedit' in readline.__doc__:
    readline.parse_and_bind("bind ^I rl_complete")
else:
    readline.parse_and_bind("tab: complete")
EOF
PYTHONSTARTUP=$(cat ~/.bashrc|grep 'PYTHONSTARTUP')
if [ "A$PYTHONSTARTUP" = "A" ]
then
    sed -i '$aexport PYTHONSTARTUP=$HOME/.pystartup.py' ~/.bashrc
    source ~/.bashrc
fi

LOG "set VIM . . . "
cat>~/.vimrc<<EOF
syntax on
set tabstop=4
set expandtab
EOF

LOG "STOP AUTO-LOGOUT . . . "
if [ "$(cat /etc/ssh/sshd_config |grep '^TCPKeepAlive')x" == x ]
then
    sed -i '$a TCPKeepAlive yes' /etc/ssh/sshd_config
else
    sed -i 's/^TCPKeepAlive.*/TCPKeepAlive yes/g' /etc/ssh/sshd_config
fi

if [ "$(cat /etc/ssh/sshd_config |grep '^ClientAliveInterval')x" == x ]
then
    sed -i '$a ClientAliveInterval 30' /etc/ssh/sshd_config
else
    sed -i 's/^ClientAliveInterval.*/ClientAliveInterval 30/g' /etc/ssh/sshd_config
fi

if [ "$(cat /etc/ssh/sshd_config |grep '^ClientAliveCountMax')x" == x ]
then
    sed -i '$a ClientAliveCountMax 288' /etc/ssh/sshd_config
else
    sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 288/g' /etc/ssh/sshd_config
fi

# Redirect known host file to null.
if [ "$(cat /etc/ssh/ssh_config |grep '^UserKnownHostsFile')x" == x ]
then
    sed -i '$a UserKnownHostsFile \/dev\/null' /etc/ssh/ssh_config
else
    sed -i 's/^UserKnownHostsFile.*/UserKnownHostsFile \/dev\/null/g' /etc/ssh/ssh_config
fi
systemctl restart sshd

# Pre-requisites for Ansible PostgreSQL module
LOG " Ansible PostgreSQL dependencies . . . "
pip3 install psycopg2-binary
LOG " Install PostgreSQL10 client . . . "
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm # for all supported versions of PostgreSQL
dnf -qy module disable postgresql # Disable the built-in PostgreSQL module
dnf install -y postgresql10

LOG " Finished!!! "


