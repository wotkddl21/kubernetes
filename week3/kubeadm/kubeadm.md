

## Node 구성
>
> ./minikube/minikube install.md에서 Node구성 방법을 참고해서 1개의 node를 준비합니다.
>
## Cluster 구성
>
> master 1, worker 2
>
## 제한사항
>
> kubernetes cluster를 구성하려면 다음의 조건을 만족해야합니다.
> 
> 1. 최소 하나 이상의 deb/rpm-compatible Linux OS node 필요
>
> 2. 모든 node는 2GB이상의 메모리를 가져야하고, master node는 2개 이상의 Core를 보유해야합니다.
>
> 3. 각 node는, 고유의 MAC주소를 가지면서, fully connected 상태여야합니다.
> 
> 4. 컨테이너의 CIDR이 정의되어야하고, 이를 위한 CNI가 구성되어야합니다.
> 
## 계획
>
> master가 될 node에, 필요한 요소들을 설치한 뒤, virtualbox의 복제기능을 통해 worker node 2개를 추가 생성해서 redundancy를 줄일 것입니다.
>

## 설치 시작 ( master node )
>
``` bash
 chmod +x install.sh
 ./install.sh
```

> 특정 version으로 kubernetes cluster를 구성하고 싶은 경우,
>
> ex) v1.18.0
``` bash
apt-get install kubectl=1.18.0-00 kubelet=1.18.0-00 kubeadm=1.18.0-00 -y
```
> 최신 버전으로 설치하고 싶은 경우
``` bash
apt-get install kubectl kubelet kubeadm -y
```
> <img src="/images/kubeadm/1.JPG">
> 
> 위와 같이 나온다면 설치 완료
> 
## Node 복제
> virtualbox에서 제공하는 machine clone 기능을 사용할 것입니다.
>  
> 
