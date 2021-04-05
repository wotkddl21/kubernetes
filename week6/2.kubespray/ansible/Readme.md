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


### cluster node

기본적으로 설치해야할 것들을 설치하겠습니다.



### admin node

모든 설치과정은 admin node에서 진행됩니다.

우선, kubespray를 다운로드 해보겠습니다.

wget https://github.com/kubernetes-sigs/kubespray/archive/release-2.8.zip

