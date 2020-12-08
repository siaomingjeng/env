#!/usr/bin/env bash
# Written by Dr. Raymond on 7 Dec 2020
# Prepare a minikube env on CentOS 8

LOG(){ echo -e "\e[38;5;40m`date`: $@ \e[39m";}
LOG "Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

LOG "Disable firewalld . . . "
systemctl stop firewalld.service 
systemctl disable firewalld.service 

LOG "Set python reminder . . . "
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
egrep -q "^(\s*)TCPKeepAlive .*$" /etc/ssh/sshd_config && sed -i 's/^TCPKeepAlive.*/TCPKeepAlive yes/g' /etc/ssh/sshd_config || sed -i '$a TCPKeepAlive yes' /etc/ssh/sshd_config
egrep -q "^(\s*)ClientAliveInterval .*$" /etc/ssh/sshd_config && sed -i 's/^ClientAliveInterval.*/ClientAliveInterval 30/g' /etc/ssh/sshd_config || sed -i '$a ClientAliveInterval 30' /etc/ssh/sshd_config
egrep -q "^(\s*)ClientAliveCountMax .*$" /etc/ssh/sshd_config && sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 288/g' /etc/ssh/sshd_config || sed -i '$a ClientAliveCountMax 288' /etc/ssh/sshd_config

LOG "Install Docker CE . . . "
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker
systemctl enable docker
systemctl start docker

LOG "Install jq, net-tools, wget . . . "
dnf install jq net-tools python3 -y

LOG "Install Helm V3 . . . "
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

LOG "Install Pre-requisets . . . "
dnf install conntrack socat -y

LOG "Install kubectl . . . "
curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x /usr/local/bin/kubectl
/usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl

LOG "link kubectl to k . . . "
ln -sf /usr/local/bin/kubectl /usr/local/bin/k
/usr/local/bin/kubectl completion bash > /etc/bash_completion.d/k
sed -i 's/-F __start_kubectl kubectl/-F __start_kubectl k/g' /etc/bash_completion.d/k

LOG "Instal kubectx and kubens from own repo siaomingjeng"
curl -Lo /usr/local/bin/kubens https://raw.githubusercontent.com/siaomingjeng/kubectx/master/kubens
curl -Lo /usr/local/bin/kubectx https://raw.githubusercontent.com/siaomingjeng/kubectx/master/kubectx
chmod +x /usr/local/bin/kubens /usr/local/bin/kubectx
curl -Lo /etc/bash_completion.d/kubens https://raw.githubusercontent.com/siaomingjeng/kubectx/master/completion/kubens.bash
curl -Lo /etc/bash_completion.d/kubectx https://raw.githubusercontent.com/siaomingjeng/kubectx/master/completion/kubectx.bash

LOG "Install minikube . . . "
curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x /usr/local/bin/minikube

LOG "Install completion . . . "
minikube completion bash > /etc/bash_completion.d/minikube


LOG "Start minikube on local host: minikube start --vm-driver=none"
minikube start --vm-driver=none

LOG "Stop minikube: minikube start --vm-driver=none"
minikube stop


# Enable load balancer
# metalLB DOC: https://medium.com/faun/metallb-configuration-in-minikube-to-enable-kubernetes-service-of-type-loadbalancer-9559739787df


#firewall-cmd --zone=public --add-port=8443/tcp --permanent
#firewall-cmd --zone=public --add-port=10250/tcp --permanent
#firewall-cmd --reload