# Jenkins

앞서 구축한 gitlab과 Jenkins를 연동해서, gitlab으로 push가 발생하면 gitlab에서 Jenkins로 webhook을 전달하여 CI / CD pipeline이 실행되도록 만들겠습니다.

## 사전지식

### serviceaccount

kubernetes의 resource를 변경하려면 kube-apiserver와 통신해야합니다.

이때 kube-apiserver와 통신하는 방법은 2가지 입니다.

1. .kube/config

kubernetes cluster가 만들어지면, 모든 resource를 관리하는 kube-apiserver와 통신할 수 있는 key가 .kube/config에 저장됩니다.

이 파일을 KUBECONFIG의 환경변수로 추가하면 kubectl을 통해 kube-apiserver와 통신할 수 있습니다.

일반적인 사용자가 위와 같은 방식을 이용합니다.

2. serviceaccount

kubectl을 사용자가 아닌 POD도 사용할 수 있습니다.

정확하게 말하면 POD내에서 kubectl을 사용할 수 있습니다.

serviceaccount를 생성하고, resource에 대한 권한을 binding하면 이 serviceaccount를 통해 kube-apiserver와 통신할 수 있습니다.

Jenkins image가 실행될 POD에 위 serviceaccount를 붙여서 Jenkins POD내에서 kubectl을 통해 CD기능을 구현하고자 합니다.

### namespace

kubernetes cluster에서, namespace를 사용해서 논리적으로 공간을 분리할 수 있습니다.

jenkins POD를 jenkins라는 namespace를 만들어서 따로 관리하려고 합니다.

그 이유는 실제 서비스를 위한 공간과 분리하는 것이 운영적인 측면에서 편리하기 때문입니다.



## jenkins 실행

jenkins라는 namespace를 먼저 만들겠습니다.

``` shell
kubectl create namespace jenkins
```

<img src="/images/CICD/39.JPG">


code를 보며 jenkins POD에 대한 설명을 하겠습니다.

serviceaccount.yaml을 보면, jenkins라는 serviceaccount가 jenkins라는 namespace에 생성됩니다.

그리고 이 serviceaccount에게 cluster-admin이라는 cluster role이 bind됩니다.

cluster role은 모든 namespace를 포함하는 cluster level의 role로, 이 POD가 비록 jenkins namespace에 선언되어 있지만 다른 namespace의 resource에도 영향력을 행사할 수 있습니다.

이 권한을 통해서 전체 service의 CD를 담당합니다.

또한 nodeSelector로 worker1을 지정했는데, 이는 앞서 week4/Volume/2.hostpath를 참고하시면 알 수 있습니다.

기존 설정들을 저장하는 volume이기에 항상 같은 node에서 실행되어야 합니다.

worker1에서 /etc/jenkins 라는 디렉토리를 사용할 예정인데,  jenkins.yaml을 보시면 fsGroup이 1000으로 정의되어 있습니다.

/etc/jenkins 디렉토리에 대한 권한을 1000 user에게 열어줘야합니다.

``` shell
//worker1에서 root권한으로 진행

mkdir /etc/jenkins
chown 1000 /etc/jenkins

```

<img src="/images/CICD/42.JPG">


``` shell
//master에서 진행
cd week5/CI-CD/2.jenkins
kubectl apply -f serviceaccount.yaml
kubectl apply -f jenkins.yaml
```
<img src="/images/CICD/42.JPG">
<img src="/images/CICD/40.JPG">


``` shell
kubectl apply -f service.yaml
```

<img src="/images/CICD/41.JPG">


``` shell
kubectl get pod -n jenkins
kubectl get service -n jenkins
```

<img src="/images/CICD/44.JPG">

이제 localhost:30303을 통해 jenkins pod로 접속이 가능합니다.

<img src="/images/CICD/45.JPG">

초기 비밀번호는 아래 명령어를 통해 알 수 있습니다.

``` shell
kubectl exec -it -n jenkins $(kubectl get pod -n jenkins | awk '/[0-9]/{print $1}') -- bash
cat /var/jenkins_home/secrets/initialAdminPassword 
```

<img src="/images/CICD/46.JPG">

<img src="/images/CICD/47.JPG">

초기비밀번호를 입력하면 아래와 같은 화면이 나옵니다.

<img src="/images/CICD/48.JPG">

install suggested plugins을 눌러 plugin을 설치합니다.

<img src="/images/CICD/49.JPG">

<img src="/images/CICD/50.JPG">

설치가 완료되면 Admin user를 생성합니다.

저는 Username : jspark , Password: test1234, Full name: jaesangpark, E-mail address: wotkddl21@sogang.ac.kr 로 설정했습니다. 

<img src="/images/CICD/51.JPG">

<img src="/images/CICD/52.JPG">

Url은 따로 변경하지 않았습니다.

<img src="/images/CICD/53.JPG">

<img src="/images/CICD/54.JPG">

Manage Jenkins를 클릭합니다.

<img src="/images/CICD/55.JPG">

Configure Global Security를 클릭해서, 별 다른 설정을 바꾸지 않고 Save를 누릅니다.

<img src="/images/CICD/56.JPG">

이제 Manage Plugins를 통해 추가적인 plugin을 설치해야합니다.

<img src="/images/CICD/57.JPG">

Available tab에서 kubernetes, Gitlab, Gitlab Hook 3가지를 검색해서 설치합니다.

<img src="/images/CICD/58.JPG">

<img src="/images/CICD/59.JPG">

설치가 완료되면, master에서 jenkins POD를 재실행 시킵니다.

<img src="/images/CICD/60.JPG">

```shell
kubectl rollout restart deployment jenkins -n jenkins
```

<img src="/images/CICD/61.JPG">

jenkins를 실행중이던 web browser에서 다시 localhost:30303으로 접속합니다.

<img src="/images/CICD/62.JPG">

<img src="/images/CICD/63.JPG">

이제 필요한 plugin들을 모두 설치했으니 pipeline을 만들어보겠습니다.

<img src="/images/CICD/64.JPG">

<img src="/images/CICD/65.JPG">









