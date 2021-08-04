# 실습용 k8s cluster 구축하기

master 1대, worker 1대로 구성된 cluster를 kubespray를 이용해 구축할 예정이다.

필요한 package 설치

``` bash
apt-get update -y && apt-get upgrade -y && apt-get install vim curl net-tools conntrack openssh-server git && apt-get install python3 -y && apt-get install python3-pip -y 
```

master1 : 192.168.0.23

worker1 : 192.168.0.24

## ssh 연결

각 node에 ssh key를 생성하고, ssh-copy-id를 통해 root권한으로 서로 접속할 수 있도록 설정한다.

``` bash
ssh-keygen -t rsa
ssh-copy-id root@<node ip>
```

## kubespray clone
master1 노드에서 진행한다.

``` bash
git clone https://github.com/kubernetes-sigs/kubespray.git
cd /kubespray
cp -rfp inventory/sample inventory/mycluster

```

## inveitory.ini 수정 및 ansible 설치

``` bash
pip3 install -r requirements.txt

vi inventory/mycluster/inventory.ini

[all]
master1 ansible_host=192.168.0.23 ip=192.168.0.23 etcd_member_name=etcd1
worker1 ansible_host=192.168.0.24 ip=192.168.0.24
[kube_control_plane]
master1

[etcd]
master1

[kube_node]
worker1

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr

```

## kubernetes 설치

ansible-playbook -i ./inventory/mycluster/inventory.ini cluster.yml

<img src="/images/kubespray/cluster/1.jpg">