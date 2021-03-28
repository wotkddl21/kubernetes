# POD TEST

## 앞서 POD.md에서 알아본 POD의 특징들을 점검해보도록 하겠습니다.

### Cluster 생성
>
> POD에 대해 이것 저것 알아보기 위해 간단한 master 1, worker 1인 cluster를 생성하겠습니다.
> 
> master와 worker node에서 week3/kubeadm/install.sh 를 실행시켜 필요한 파일들을 설치합니다.
>
```
cd week3/kubeadm
chmod +x install.sh
./install.sh
```
> 
> master node에서 kubeadm을 통해 cluster를 만들겠습니다.
>
```
kubeadm init --pod-network-cidr=10.244.0.0/16

```
> <img src="/images/POD/1.JPG">
>
> <img src="/images/POD/2.JPG">
>
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
>
> worker node에서, 빨간 box에 해당하는 명령어를 통해 cluster로 join 하겠습니다.
>
```
kubeadm join 130.1.3.68:6443 --token 5lc4qq.1trdv4mmoqhsym3m \
    --discovery-token-ca-cert-hash sha256:13830002804e1fe84affb45c5617ac43350a8bf73587d50b2f0fc7d10f63f70a 
```
>
> <img src="/images/POD/3.JPG">
> 
> <img src="/images/POD/4.JPG">
> 


### The dynamic ip of POD
>
> 이제 master node에서, POD를 하나 실행시켜 보겠습니다.
>
```
cd ../../week4/POD/POD_detail
kubectl apply -f pod_test.yaml
```
>
> -o wide 옵션을 추가하면, cluster내부 ip와 실행중인 node 정보도 알 수 있습니다.
>
```
kubectl get pod -o wide
```
>
> <img src="/images/POD/5.JPG">
>
> 현재 POD에 할당된 ip는 10.244.1.2 입니다.
>
> POD는 ephemeral resource로, 영구적인 존재가 아닙니다.
>
> 앞서 설명했듯 동적으로 ip를 할당받기 때문에 새롭게 POD를 실행하면 다른 ip를 가지게 됩니다.
>
```
kubectl delete pod test
```
>
> <img src="/images/POD/6.JPG">
>
```
kubectl apply -f pod_test.yaml

kubectl get pod -o wide
```
> 
> <img src="/images/POD/7.JPG">
> 
> 이번POD의 ip는 10.244.1.3로, 이전과 달라진 모습입니다.
>
> 실제 solution을 이용하려면 container에서 실행중인 APP에 접근해야하는데, 그 주소가 가변적이기 때문에 hard coding으로 처리하기 어렵습니다.
> 
> 그래서, service라는 kubernetes object를 통해 POD에 접근하도록 권장합니다.
>
> 이번 글에서는 'POD의 ip는 가변적인 값이기 때문에 service를 사용해야한다' 정도만 언급하고 service는 이후에 다루도록 하겠습니다.
>
