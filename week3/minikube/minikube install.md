## minikube를 통해, 빠르게 kubernetes cluster를 구성하는 방법에 대해 알아보겠습니다.

### node spec
> virtualbox
> 
> Core: 4
> 
> RAM: 8GB
> 
> OS: Ubuntu 20.04
> 
> Storage: 48GB
> 
> 2 Core, 2GB, free storage : 20GB 가 최소 사양이기 때문에 spec은 상황에 맞게 설정하시면 됩니다.
> 
### node 구성 방법
>
> virtualbox와, Ubuntu 20.04 iso는 아래 링크에서 구할 수 있습니다.
>
> ( https://www.virtualbox.org/ , https://releases.ubuntu.com/20.04/ )
>
> <img src="/images/minikube/5.JPG" width="300" height="300"><img src="/images/minikube/6.JPG" width="300" height="300"><img src="/images/minikube/7.JPG" width="300" height="300">
> 
> <img src="/images/minikube/8.JPG" width="300" height="300"><img src="/images/minikube/9.JPG" width="300" height="300"><img src="/images/minikube/10.JPG" width="300" height="300">
> 
> <img src="/images/minikube/11.JPG" width="300" height="300"> <img src="/images/minikube/12.JPG" width="300" height="300"> <img src="/images/minikube/13.JPG" width="300" height="300">
> 
> <img src="/images/minikube/14.JPG" width="300" height="300">
> 
> 계정, 시간, password 설정에 대한 설명은 생략하겠습니다.
>

### minikube, kubectl 설치
> 현재 디렉토리에, install.sh파일에 설치할 때 필요한 명령어들이 정리되어있습니다.
>
> 이후 과정은 root 계정으로 진행하는 것이 좋습니다.
>
> // root 계정 초기 비밀번호 설정
```  bash
 sudo passwd root
```
> 
> //root계정으로 전환
```  bash
 su
``` 
> 
> // git 설치
```  bash
 apt-get install git -y
 
 git clone https://github.com/wotkddl21/kubernetes.git
 
 cd ./kubernetes/week3/minikube
``` 
> // install.sh에 실행권한 부여
```  bash
 chmod +x install.sh
``` 
> //minikube 설치 시작
```  bash
 ./install.sh
``` 
>
> <img src="/images/minikube/24.JPG" >
> 
> 위와 같은 출력이 나온다면 minikube와 그에 필요한 것들을 성공적으로 설치한 것입니다.
>
> 이제, kubectl을 설치해야합니다.
```  bash
 curl -LO "https://storage.googleapis.com/kubernetes-release/release/" 원하는 버전 "/bin/linux/amd64/kubectl"

 ex) curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl"
``` 
> kubectl binary를 download했다면, 실행권한을 주고 어느 위치에서나 사용할 수 있도록 /usr/local/bin의 위치로 옮겨야합니다.
```  bash
 chmod +x ./kubectl

 mv ./kubectl /usr/local/bin/kubectl

 kubectl version
``` 
> <img src="/images/minikube/15.JPG" >
>
> 위와 같은 출력이 나온다면 성공적으로 kubectl을 설치한 것입니다.
>
### kubernetes cluster 구성하기
>
> 이제 kubernetes cluster를 v1.17.0으로 구성해보겠습니다.
> 
> 버전은 자유롭게 선택하시되, 앞서 설치한 kubectl과 동일하게 하시면 됩니다.
```  bash
 minikube start --driver=none --kubernetes-version=v1.17.0
``` 
```  bash
 kubectl get node
``` 
> <img src="/images/minikube/16.JPG" >
>
> 위와 같은 출력이 나온다면 성공적으로 minikube로 kubernetes cluster를 구성한 것입니다.
> 




