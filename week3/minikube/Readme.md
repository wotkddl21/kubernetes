## 앞서 minikube로 구축한 kubernetes cluster에서 간단한 test를 진행하겠습니다.

### POD 예제
>
> 현재 디렉토리는 syds-paas1/week3 입니다.
>
> kubectl apply -f ./pod.yaml
>
> kubectl get pod
> 
> <img src="/images/minikube/17.JPG">
>
> 위와 같은 출력이 나오면, 성공적으로 POD를 실행한 것 입니다.
>
> 해당 POD에 직접 접근해보겠습니다.
``` bash
 kubectl exec -it $(kubectl get pod | grep -i pod1 | awk '{ print $1 }' ) -- bash
 
 curl localhost:3000
``` 
> <img src="/images/minikube/18.JPG">
> 
> 위와 같은 출력이 나온다면 POD를 생성하고, 접근하는데 성공한 것입니다.
> 
> 다음은, POD의 cluster ip를 통해 접근해보겠습니다.
> 
> POD의 cluster ip는, kubectl get pod -o wide 를 통해 알아낼 수 있습니다.
> 
> <img src="/images/minikube/20.JPG">
> 
> 이 경우, POD는 172.17.0.3의 ip를 가지고 있습니다.
>
> 이 ip를 통해 접근을 해보겠습니다.
```  bash
 curl $(kubectl get pod -o wide | grep -i pod1 | awk '{ print $6 }'):3000
``` 
> <img src="/images/minikube/19.JPG">
>
> 이 pod를 삭제 후 다시 실행시켜보겠습니다.
``` bash
 kubectl delete pod $(kubectl get pod | grep -i pod1 | awk '{ print $1}')
 
 kubectl get pod -o wide
```
> <img src="/images/minikube/21.JPG">
> 
> 다시 POD의 ip를 확인해보면, 이전과 달라진 것을 알 수 있습니다.
> 
> POD는 동적으로 clusterip를 할당받기 때문에 재실행되면 ip가 변경되는 issue가 있습니다.
>
> 이런 문제를 해결하기 위해 service가 등장했습니다.
>
### Service 예제
>
> POD의 ip는 수시로 바뀐다는 것을 알게 되었습니다.
> 
> 그래서 고정적인 ip를 갖는 Service를 POD의 앞단에 붙여서 사용합니다.
> 
> <img src="/images/minikube/22.jpg">
> 
> 다음 명령어를 실행하시면, 좀 전에 생성한 POD와 연결되는 service가 만들어집니다.
```  bash
 kubectl apply -f ./service.yaml

 kubectl get service -o wide
``` 
> <img src="/images/minikube/23.JPG">
> 
> 접근하고자 하는 service의 ip는 10.96.9.106입니다. 이는 POD가 새로 생성되어도 그대로 유지됩니다.
> 
> 다음을 입력하면, service를 통해 방금 생성한 POD로 접근할 수 있습니다.
```  bash
 curl $(kubectl get service -o wide | grep -i pod1 | awk '{ print $3 }'):3000
``` 
> <img src="/images/minikube/24.JPG">
> 
> service의 형태는 다양한데, 이번에 생성한 Nodeport의 경우, 외부에서 node의 ip와 30001번 port 통해서도 접근이 가능합니다.
> 
> 현재 node의 ip는 ifconfig를 통해 알 수 있습니다.
```  bash
 ifconfig | grep "inet "
``` 
> <img src="/images/minikube/25.JPG">
>
> 저의 경우, network interface가 enp0s3으로 설정되어 있고, 이 ip주소는 130.1.3.114입니다.
>
> minikube가 실행 중인 host 밖에서 접근해보겠습니다.
> 
> 130.1.3.114:30001
> 
> <img src="/images/minikube/26.JPG">
> 
> 외부에서도 접속이 가능합니다.
>
### 간단하게 minikube로 kubernetes cluster를 생성하고, POD와 service를 띄워보는 예제를 진행해봤습니다.

### POD와 service에 관한 더 자세한 예시는 다음 게시물에서 다루도록 하겠습니다.
