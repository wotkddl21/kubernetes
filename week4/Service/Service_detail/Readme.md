# Service test
>
> Service.md에서 설명한 내용들을 실제 cluster에서 test 해보겠습니다.
>

## 환경구축
>
> 앞서 POD_test.md에서와 같은방식으로 cluster를 구성해줍니다. ( master 1, worker 1, kubernetes v1.20.4)
>

## Test
>
> > ### 1. Selector
> >
``` bash
cd week4/Service/Service_detail
kubectl apply -f ./pod_service.yaml

```
<img src="/images/Service/service1.JPG">

> > my-service라는 이름의 service가 만들어졌고, selector는 app=webpod입니다.
> >
> > app=webpod라는 label이 붙은 POD를 Endpoint로 설정한다는 뜻입니다.
> >
> > <img src="/images/Service/service2.JPG">
> >
> > 현재 아무 POD도 실행하지 않았으므로 Endpoints: <none>인 모습입니다.
> >
> > app=webpod인 POD를 배포해보겠습니다.
``` bash
kubectl apply -f ./pod.yaml
```
> >
> > 현재 POD가 Running 상태이고 IP는 10.244.1.5입니다.
``` bash
kubectl get pod -o wide
```

<img src="/images/Service/service3.JPG">

> >
> > service의 Endpoints도 다시 확인해보겠습니다.
> >

``` bash
kubectl describe service my-service
```

<img src="/images/Service/service4.JPG">

> > 
> > 현재 실행중인 POD로 Endpoint가 설정된 모습입니다.
> >
> > 우연일 수도 있으니, POD를 삭제한 뒤 다시 실행시켜보겠습니다.
> >
``` bash
kubectl delete pod webpod && kubectl apply -f ./pod.yaml
```

<img src="/images/Service/service5.JPG">

> >
> > 다시 실행하니, POD의 ip가 10.244.1.6으로 변경되었습니다.
> >
> > my-service의 Endpoints를 다시 확인해보겠습니다.
> >
``` bash
kubectl describe service my-service
```

<img src="/images/Service/service6.JPG">

> > 
> > Endpoints가 새로 실행된 POD로 설정된 모습입니다.
> >
> > selector를 이용하면, service의 Endpoints를 원하는 POD로 설정할 수 있습니다.
> >

> ### 2. Default dns ( POD to POD )
> >
> > service는, 영구적인 cluster ip를 가지지만 어떤 값을 할당받을 지는 미리 알 수 없습니다.
> >
> > webpod에서 dbpod로 연결하고자 할 때 hard coding으로 service로 연결하는 것은 무리가 있습니다.
> >
> > ./app.js의 connectDB()를 보면 databaseurl이 default dns형식으로 되어있습니다.
> >
> > mongodb를 사용한 dbpod의 service형식을 알고 있기 때문에 default dns로 연결을 시도하는 것이 현명한 방법입니다.
> >
> > 우선 mongodb pod를 실행해보겠습니다.
``` bash
kubectl apply -f mongo-pv.yaml
kubectl apply -f mongo.yaml
```

<img src="/images/Service/service7.JPG">

> >
> > 성공했다면, mongo-0라는 POD가 실행중일 것입니다.
> >
> > webpod에서 mongodb pod로 연결을 성공했는지 확인해보겠습니다.
> >
``` bash
kubectl exec -it webpod -- curl localhost:3000/connect
kubectl logs webpod
```
<img src="/images/Service/service8.JPG">

> >
> > webpod와 mongodbpod가 통신하는데 성공한 모습입니다.
> >

> >### 3. 외부 노출 (expose)
> >
> > cluster 내부에서 통신은 무리없이 이루어졌습니다.
> >
> > 허나 실제 application을 외부로 노출시켜 여러 user가 접근할 수 있도록 해야하는 경우가 많습니다.
> >
> > 이때 이용할 수 있는 service가 NodePort와 Loadbalancer입니다.
> >

> > ### 3.1 NodePort
> > 
> > Nodeport는 이름에서 알 수 있듯 node의 port를 이용한 것입니다.
> >
> > 30000~32767사이의 port를 할당해서 사용할 수 있습니다.
> >
> > Clusterip형태의 service의 경우 cluster 내부에 하나만 생기지만 Nodeport의 경우 각 node에 하나씩 생성됩니다.
> >
> > 그래서 cluster를 구성하는 임의의 node를 통해서도 접근이 가능합니다.
> >
> > 접근 방식은 {nodeip} : {nodeport} 입니다.
> >
> > 예제를 실행해보겠습니다. 이전에 실행한 webpod를 외부로 노출시켜보겠습니다.
> >
``` bash
kubectl apply -f ./nodeport.yaml
kubect describe service nodeport-service
```
<img src="/images/Service/service9.JPG">

> >
> > Endpoint가 webpod를 가리키고 있고 NodePort값은 30080입니다. (p.s. webpod의 ip가 10.244.1.21로 변경되어있습니다. )
> >
> > 이제 외부에서 nodeip:30080으로 접속을 시도해보겠습니다.
> >
``` bash
ifconfig
```
<img src="/images/Service/service10.JPG">

> >
> > 현재 master node의 ip는 130.1.3.68입니다.
> > 

<img src="/images/Service/service11.JPG">

> >
> > 외부 node에서 접속에 성공했습니다. ( 같은 130.1.3.x )
> >
> > 이번엔 worker node의 ip를 확인해보겠습니다.
> >
``` bash
// worker node에서 진행
ifconfig
```

<img src="/images/Service/service12.JPG">

> >
> > 130.1.3.78:30080 으로 접속을 시도해보겠습니다.
> >

<img src="/images/Service/service13.JPG">

> >
> > 외부에서 접속에 성공했습니다.
> >


> > ### 3.2 Loadbalancer
> >
> > Loadbalancer의 경우 cloud vendor에서 제공하는 loadbalancer를 사용해야합니다.
> >
> > 이론적으로 설명을 하자면, Loadbalancer는 cloud vendor에서 받은 공인 ip 뒤에 배치된다.
> >
> > 그리고, 내부 로직에 의해 적절한 backend target service를 선택하고 portforwarding을 통해 targetPort로 traffic을 보낸다.
> >
> >