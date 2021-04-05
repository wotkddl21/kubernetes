# kubespray

kubespray는 ansible기반으로, 원하는 설정값들을 입력하면 알아서 설치해주는 tool입니다.

전체적인 구조는 외부 admin node에서 cluster를 구성할 node들을 관리합니다.

각 node에 ssh를 통해 root로 접근하여 필요 리소스들을 설치합니다.

screen shot양이 많은 관계로 Readme.md 에서는 VM 설정과정만을 다루겠습니다.

실제 kubespray를 이용한 kubernetes 설치과정은 ansible 폴더에서 다루겠습니다.

### 구축 환경

Admin node : 
 
 OS : ubuntu 16.04

 4 Core 4GB

cluster node:
  
 OS : centOS 7

 4 Core, 4GB

spec의 경우, 본인 환경에 따라 다르게 설정하시면 됩니다. ( 최소 스펙 : 2Core 2GB )

저는 Oracle의 VirtualBox를 이용해서 각 node들을 사용했습니다.

우선 필요한 os image를 가져오겠습니다.

ubuntu 16.04와 centos 7은 open source로, 무료로 이용이 가능합니다.

https://releases.ubuntu.com/16.04/

<img src="/images/kubespray/0.jpg">

https://www.centos.org/download/

<img src="/images/kubespray/-1.jpg">

<img src="/images/kubespray/b.jpg">

<img src="/images/kubespray/b1.jpg">

호스트키를 ctrl+alt로 지정했습니다.

처음 부팅한 뒤, 게스트 CD를 삽입하지 않으면 마우스가 VM 영역 밖으로 빠져나올 수 없습니다.

이 때, ctrl+alt키를 누르면 빠져나올 수 있습니다.

#### cluster node

cluster node부터 진행하겠습니다. VirtualBox의 복제 기능을 이용해서, 하나의 node에 대해 설치과정을 진행하고 복제하는 방식으로 진행하는 것이 시간절약에 도움이 됩니다.

메모리는 4GB로 설정하겠습니다.

<img src="/images/kubespray/1.jpg">

<img src="/images/kubespray/2.jpg">

<img src="/images/kubespray/3.jpg">

<img src="/images/kubespray/4.jpg">

<img src="/images/kubespray/5.jpg">

Core개수를 4개로 설정합니다.

<img src="/images/kubespray/a1.jpg">

마우스 사용과 복사 붙여넣기를 용이하게 하기 위해 clipboard를 공유하도록 합니다.

<img src="/images/kubespray/a.jpg">

Network는 bridge형태로 만들어서 외부와 통신이 용이하도록 합니다.

<img src="/images/kubespray/a2.jpg">

<img src="/images/kubespray/6.jpg">

<img src="/images/kubespray/7.jpg">

부팅 이미지는 centos 7으로 설정합니다.

<img src="/images/kubespray/8.jpg">

<img src="/images/kubespray/9.jpg">



편리한 사용을 위해 GUI와 development tool을 기본 설치파일로 지정합니다.

<img src="/images/kubespray/11.jpg">

<img src="/images/kubespray/10.jpg">

os가 설치될 disk를 아까 virtualbox에서 지정한 32GB 디스크로 지정합니다.

<img src="/images/kubespray/12.jpg">

<img src="/images/kubespray/13.jpg">

기본 network interface를 지정해야합니다.

<img src="/images/kubespray/14.jpg">

OFF를 ON으로 변경하면 현재 hostnode의 network를 사용합니다.

<img src="/images/kubespray/15.jpg">

설치를 시작하겠습니다.

<img src="/images/kubespray/16.jpg">

설치를 진행하는 동안 root password를 설정합니다.

<img src="/images/kubespray/17.jpg">

<img src="/images/kubespray/18.jpg">

설치가 완료되면 재부팅을 해줍니다.

<img src="/images/kubespray/19.jpg">

license를 동의 해줍니다.

<img src="/images/kubespray/20.jpg">

<img src="/images/kubespray/21.jpg">

<img src="/images/kubespray/22.jpg">

<img src="/images/kubespray/23.jpg">

<img src="/images/kubespray/24.jpg">

<img src="/images/kubespray/25.jpg">

<img src="/images/kubespray/26.jpg">

<img src="/images/kubespray/27.jpg">

<img src="/images/kubespray/28.jpg">

<img src="/images/kubespray/29.jpg">

<img src="/images/kubespray/30.jpg">

<img src="/images/kubespray/31.jpg">

설치가 완료되었습니다.

ctrl+alt키를 눌러 마우스를 VM에서 빠져나오게 한 뒤, 장치 -> 게스트 확장 CD 삽입을 진행합니다.

<img src="/images/kubespray/32.jpg">

<img src="/images/kubespray/33.jpg">

<img src="/images/kubespray/34.jpg">

삽입한 CD를 실행시켜줍니다.

<img src="/images/kubespray/35.jpg">

이제 마우스가 VM 내부와 host를 자유자재로 움직일 수 있습니다.

<img src="/images/kubespray/36.jpg">

Applications -> System tools -> Terminal

``` shell
sudo -i

```

<img src="/images/kubespray/37.jpg">



기존 설치과정에서 설정한 root 비밀번호를 입력해서 root로 전환합니다.

``` shell
ifconfig
```

<img src="/images/kubespray/38.jpg">

현재 node의 ip는 130.1.3.136입니다.

이제 필요한 리소스를 설치하겠습니다.

<img src="/images/kubespray/39.jpg">

``` shell
vi install.sh

```
install.sh를 열고, 아래 명령들을 드래그 한 뒤 ctrl+insert로 복사해서 VM에 shift+insert키로 붙여넣기를 합니다.

``` shell
#!/bin/bash

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

```

<img src="/images/kubespray/40.jpg">

``` shell
chmod +x install.sh
./install.sh
```

<img src="/images/kubespray/41.jpg">

중략

```shell
python
exit()
```
python을 실행시켰을 때, 2.7.5가 설치되면 성공한 것입니다.

<img src="/images/kubespray/42.jpg">

``` shell
vi /etc/ssh/sshd_config
```

Port 22와 PermitRootLogin의 주석을 해제합니다.

<img src="/images/kubespray/49.jpg">

``` shell

systemctl restart sshd

```

<img src="/images/kubespray/50.jpg">

이 VM을 종료시킨 뒤, 복제를 해보겠습니다.

<img src="/images/kubespray/43.jpg">

<img src="/images/kubespray/44.jpg">

새로운 MAC주소를 생성하면서 복제를 합니다. ( kubernetes cluster의 node가 되려면 unique MAC 주소를 가져야합니다. )

<img src="/images/kubespray/45.jpg">

완전한 복제로 진행합니다.

<img src="/images/kubespray/46.jpg">

복제본이 만들어졌습니다.

<img src="/images/kubespray/47.jpg">

이름을 각각 sk-master1, sk-master3, sk-worker1, sk-worker2로 만들어 줍니다.

<img src="/images/kubespray/48.jpg">

복제 과정을 4번 반복하면 저처럼 sk-master1, sk-master2, sk-master3, sk-worker1, sk-worker2 총 5개의 vm을 생성할 수 있습니다.

각 vm을 실행시켜 ip주소를 정리해야합니다.

아래는 저의 정보입니다.

master 3대 정보

130.1.3.117 sk-master1

130.1.3.136 sk-master2

130.1.3.119 sk-master3

worker 2대 정보

130.1.3.118 sk-worker1

130.1.3.120 sk-worker2 

#### admin node

admin node는 ubuntu 16.04를 사용하겠습니다.

예전 버전을 사용하는 이유는, 제가 담당한 서버가 이전 버전을 사용중이기 때문입니다.

<img src="/images/kubespray/admin1.jpg">

<img src="/images/kubespray/admin2.jpg">

<img src="/images/kubespray/admin3.jpg">

<img src="/images/kubespray/admin4.jpg">

<img src="/images/kubespray/admin5.jpg">

<img src="/images/kubespray/admin6.jpg">

<img src="/images/kubespray/admin7.jpg">

<img src="/images/kubespray/admin8.jpg">

<img src="/images/kubespray/admin9.jpg">

<img src="/images/kubespray/admin10.jpg">

<img src="/images/kubespray/admin12.jpg">

<img src="/images/kubespray/admin13.jpg">

<img src="/images/kubespray/admin14.jpg">

<img src="/images/kubespray/admin15.jpg">

<img src="/images/kubespray/admin16.jpg">

<img src="/images/kubespray/admin17.jpg">

<img src="/images/kubespray/admin18.jpg">

<img src="/images/kubespray/admin19.jpg">

ubuntu 16.04 설치가 완료되었습니다.

이 또한 게스트 확장 CD를 통해 복사 붙여넣기를 쉽게할 수 있도록 만들겠습니다.

<img src="/images/kubespray/admin20.jpg">

<img src="/images/kubespray/admin21.jpg">

<img src="/images/kubespray/admin22.jpg">

<img src="/images/kubespray/admin23.jpg">

필요한 사항들을 설치하기 위해 terminal을 실행합니다.

<img src="/images/kubespray/admin24.jpg">

root 계정으로 전환합니다.

<img src="/images/kubespray/admin25.jpg">

``` shell
apt-get update && apt-get install vim git openssh-server -y

```

<img src="/images/kubespray/admin26.jpg">

``` shell
vim /etc/hosts
```

아까 정리한 cluster node의 ip를 정리합니다.

<img src="/images/kubespray/admin27.jpg">

``` shell
ssh-keygen -t rsa
```
별 다른 값을 입력하지 않고 Enter키를 눌러 스킵합니다.

<img src="/images/kubespray/admin28.jpg">

``` shell
ssh-copy-id root@sk-master1
yes
ssh root@sk-master1
exit
```
fingerprint를 등록한 뒤 , ssh root@sk-master1을 실행했을 때 비밀번호를 따로 입력하지 않으면 ssh연결 성공입니다.

<img src="/images/kubespray/admin29.jpg">

모든 cluster node에 대해 반복합니다.

``` shell
ssh-copy-id root@sk-master2
ssh-copy-id root@sk-master3
ssh-copy-id root@sk-worker1
ssh-copy-id root@sk-worker2
```

``` shell

mkdir temp
cd temp
wget https://github.com/kubernetes-sigs/kubespray/archive/release-2.8.zip
unzip release-2.8.zip
cd kubespray-release-2.8
apt-get install curl -y
curl -O https://bootstrap.pypa.io/pip/2.7/get-pip.py
python get-pip.py
```
<img src="/images/kubespray/admin30.jpg">

<img src="/images/kubespray/admin31.jpg">

<img src="/images/kubespray/admin32.jpg">

``` shell
python
exit()
```
python 2.7 버전이 설치되면 성공입니다.

<img src="/images/kubespray/admin33.jpg">

``` shell
pip install -r requirements.txt
```
<img src="/images/kubespray/admin34.jpg">

<img src="/images/kubespray/admin35.jpg">

필요한 사항들을 모두 설치했습니다.

이후에 진행될 cluster 설치는 ansible 폴더에서 진행하겠습니다.

긴 글 따라오시느라 수고하셨습니다.







