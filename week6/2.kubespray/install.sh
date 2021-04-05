
!#/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0
swapoff -a
yum update --exclude=tcsh-6.18.01-17.el7_9.1.x86_64 -y
yum install -y epel-release git
yum install -y python-pip
yum update --exclude=tcsh-6.18.01-17.el7_9.1.x86_64 -y
