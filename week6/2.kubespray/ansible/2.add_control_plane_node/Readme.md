# 기존 kubernetes cluster에 control plane node를 추가하는 방법 정리

참고 : https://github.com/kubernetes-sigs/kubespray/blob/master/docs/nodes.md

## 기존 cluster 정보

기존 cluster는 master 1대, worker 2대로 구성되어 있다.

master1 : 192.168.0.23 ubuntu 18.04

worker1 : 192.168.0.24 ubuntu 18.04

worker2 : 192.168.0.27


## 신규 node 정보

master 2대가 추가될 예정이다. ( cluster.yml을 수정하는 방식으로 진행해야한다. )

master2 : 192.168.0.25

master3 : 192.168.0.26

## 요구사항

새롭게 추가되는 node들에 대해서, 기존 node들과 ssh 연결이 가능해야한다.

### 신규노드

master2

``` bash
ssh-keygen -t rsa
ssh-copy-id root@192.168.0.23
ssh-copy-id root@192.168.0.24
ssh-copy-id root@192.168.0.27
```

master2

``` bash
ssh-keygen -t rsa
ssh-copy-id root@192.168.0.23
ssh-copy-id root@192.168.0.24
ssh-copy-id root@192.168.0.27
```

### 기존 노드

master1

``` bash
ssh-copy-id root@192.168.0.25
ssh-copy-id root@192.168.0.26
```

worker1

``` bash
ssh-copy-id root@192.168.0.25
ssh-copy-id root@192.168.0.26
```

worker2

``` bash
ssh-copy-id root@192.168.0.25
ssh-copy-id root@192.168.0.26
```


## inventory 수정

master에 있는 ~/kubespray/inventory/sample/inventory.ini 파일을 수정해야한다.

기존 


``` ini
[all]
master1 ansible_host=192.168.0.23 ip=192.168.0.23 etcd_member_name=etcd1
worker1 ansible_host=192.168.0.24 ip=192.168.0.24
worker2 ansible_host=192.168.0.27 ip=192.168.0.27

[kube_control_plane]
master

[etcd]
master

[kube_node]
worker1
worker2

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
```

수정 이후


``` ini
[all]
master1 ansible_host=192.168.0.23 ip=192.168.0.23 etcd_member_name=etcd1
master2 ansible_host=192.168.0.25 ip=192.168.0.25 etcd_member_name=etcd2
master3 ansible_host=192.168.0.26 ip=192.168.0.26 etcd_member_name=etcd3
worker1 ansible_host=192.168.0.24 ip=192.168.0.24
worker2 ansible_host=192.168.0.27 ip=192.168.0.27

[kube_control_plane]
master1
master2
master3

[etcd]
master1
master2
master3 

[kube_node]
worker1
worker2
[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
```
### ansible-playbook 실행

ansible-playbook -i ./inventory/mycluster/inventory.ini cluster.yml

<img src="/images/kubespray/add_control_plane_node/1.jpg">

### restart kube-system/nginx-proxy

worker node의 kube-system/nginx-proxy를 재실행 해줘야한다.

config값을 kubespray에서 수정해주지만, 재시작해야 반영된다.

``` bash
docker ps | grep k8s_nginx-proxy_nginx-proxy | awk '{print $1}' | xargs docker restart
```
<img src="/images/kubespray/add_control_plane_node/2.jpg">



