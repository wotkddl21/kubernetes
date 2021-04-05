# Kubespray

Node가 모두 준비된 이후에 진행되는 상황입니다.

저의 Node의 상황은 다음과 같습니다.

master 3대 정보

130.1.3.117 sk-master1

130.1.3.115 sk-master2

130.1.3.61 sk-master3

worker 2대 정보

130.1.3.118 sk-worker1

130.1.3.120 sk-worker2 

admin 정보

130.1.3.122 sk-admin


### admin node

모든 설치과정은 admin node에서 진행됩니다.

이전에 설치했던 kubespray 폴더로 이동하겠습니다.

``` shell
cd ~/temp/kubespray-release-2.8
cp -rfp ./inventory/sample ./inventory/first_cluster
vim ./inventory/first_cluster/temp.ini
```
``` shell
[all]
sk-master1 ansible_host=130.1.3.117 ip=130.1.3.117 etcd_member_name=etcd1
sk-master2 ansible_host=130.1.3.136 ip=130.1.3.136 etcd_member_name=etcd2
sk-master3 ansible_host=130.1.3.119 ip=130.1.3.119 etcd_member_name=etcd3
sk-worker1 ansible_host=130.1.3.118 ip=130.1.3.118
sk-worker2 ansible_host=130.1.3.120 ip=130.1.3.120
[kube-master]
sk-master1
sk-master2
sk-master3
[etcd]
sk-master1
sk-master2
sk-master3
[kube-node]
sk-worker1
sk-worker2
[calico-rr]
[k8s-cluster:children]
kube-master
kube-node
calico-rr
```

<img src="/images/kubespray/admin36.jpg">

default로 지정된 repo는, 2020년 3월에 사라졌습니다.

dockerproject repo를 최신 버전으로 변경해야합니다.

``` shell
vim ./roles/container-engine/docker/defaults/main.yml
```
<img src="/images/kubespray/admin37.jpg">

기존 dockerproject_rh_repo를 모두 주석처리하고 새로운 repo를 대입했습니다.

<img src="/images/kubespray/admin38.jpg">

``` shell
dockerproject_rh_repo_base_url: 'https://download.docker.com/linux/centos/7/x86_64/stable'
dockerproject_rh_repo_gpgkey: 'https://download.docker.com/linux/centos/gpg'
dockerproject_apt_repo_base_url: 'https://download.docker.com/linux/debian'
dockerproject_apt_repo_gpgkey: 'https://download.docker.com/linux/debian/gpg'
```

```shell
vi ./roles/etcd/tasks/configure.yml
```

71번째 줄의 ignore_errors를 true로 바꿔준다.  ( 2번째 Check if etcd cluster is healthy )

<img src="/images/kubespray/admin39.jpg">

``` shell
vi ./inventory/first_cluster/group_vars/k8s-cluster/k8s-cluster.yml 
```

kubernetes version을 1.12.3으로 변경하겠습니다.

<img src="/images/kubespray/admin40.jpg">

``` shell
ansible-playbook -i ./inventory/first_cluster/temp.ini cluster.yml
```

<img src="/images/kubespray/admin41.jpg">

이제 설치가 완료되었습니다. 이제 admin node에서는 진행할 내용이 없습니다.

<img src="/images/kubespray/admin42.jpg">


### master node

이제 master node ( sk-master1, sk-master2, sk-master3) 에서 진행할 내용이 남았습니다.

kubectl이 기본적으로 설치되는 위치가 /usr/local/bin인데, root 계정의 경우 기본 PATH에 이 디렉토리가 포함되어있지 않습니다.

```shell
sudo -i
echo $PATH
kubectl
```
<img src="/images/kubespray/admin43.jpg">

/usr/local/bin/kubectl 이라는 명령어로 사용해야하기에, PATH에 /usr/local/bin을 추가하겠습니다.

``` shell
PATH=$PATH:/usr/local/bin
echo $PATH
kubectl
```

<img src="/images/kubespray/admin44.jpg">

``` shell
kubectl get node
```

<img src="/images/kubespray/admin45.jpg">

성공적으로 kubernetes cluster 설치를 완료했습니다.



