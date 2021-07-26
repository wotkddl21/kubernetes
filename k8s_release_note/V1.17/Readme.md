# 1. Beta로 승급  ( Graduate to Beta )


## 1.1. Volume snapshot

> volume snapshot의 경우 v1.12에서 alpha로 등장했다.
> 
> snapshot controller와 CSI (container storage interface) driver를 이용하면 volume snapshot기능을 이용할 수 있다.
>
> 간단하게 volume snapshot이 뭔지 알아보자.
>
> volume snapshot은 많은 벤더사에서 제공하는 기능으로 "특정시간의 volume copy"이다.
>
> 이는 두 가지 방법으로 활용할 수 있다.
>
> A. 새로운 volume을 provision
>
>    pod에 volume을 mount할 때, 기존에 사용하던 volume의 내용을 사용하고 싶다면 dump를 해도 되지만, volume snapshot을 provisioning하게 되면 좀 더 관리하기가 편하다.
>
> B. 현재 volume을 이전 상태로 복원
>
>   "특정 시간의 volume copy"니깐, 과거의 데이터로 돌아갈 수 있다.
>
### 의문점

> IaaS수준에서 volume snapshot을 제공하는 것은 이해가 가지만, k8s에서 이 기능을 추가한 이유는 무엇일까?
>
> k8s가 volume에 대해 이미 충분히 강력한 추상화 기능을 제공하고 있다.
>
> k8s는 cluster에 관한 지식 없이 platform에 application을 배포함에 할 수 있게 만드는 것을 목표로 하고 있다.
>
> 그래서 iaas 수준의 명령어를 사용하지 않고 snapshot을 사용하게끔 만들고 싶었던 것이다.
>
> 또한 DB같은 stateful workload의 경우 volume snapshot기능이 절실히 필요한 이유도 한 몫했다.
>

## 사용방법

> volume snapshot 기능을 사용하려면 3가지 요구사항이 있다.
>
> A. k8s VolumeSnapshot CRDS(CustomResourceDefinition)이 배포되어있어야한다.
>  
> https://github.com/kubernetes-csi/external-snapshotter/tree/53469c21962339229dd150cbba50c34359acec73/config/crd
>
> B. Volume snapshot controller 가 설치 되어 있어야한다.
>
> https://github.com/kubernetes-csi/external-snapshotter/tree/master/pkg/common-controller
>
> C. CSI Driver가 있어야한다.

## 1.2 CSI
>
> 각 클라우드 벤더사 혹은 third party에서 'in-tree' volume plugin에 대한 지원이 어렵다는 반응이 주류를 이룬다.
> 
> 새로운 storage system에 적용하기 어려운 이유인 것 같다.
> 
> 그래서 CSI가 beta로 넘어오면서 gce의 persistent disk, aws의 ebs를 사용할 수 있게 되었다.
> 
> kubernetes.io/gce-pd, kubernetes.io/aws-ebs
> 
## 1.3 node, volume labeling
> 
> node와 volume에 label을 붙이는 기능은 이미 있었지만, 여기서 언급하는 내용은 조금 다르다.
> 
> 각 벤더사의 topology를 반영한 label이 주어진다. ( region, zone, instance type 등등 )
> 
> ex) node.kubernetes.io/instance-type=m3.medium, topology.kubernetes.io/zone
> 
> 이 label을 이용하면 동일 region의 node들에 같은 pod가 실행되게 혹은 안되게 설정할 수 있다.
> 

# 2. Stable로 승급 ( Graduate to Stable )

> alpha와 beta를 거쳐 Stable이 된 친구들이다.
> 
> * V1.17에서 Stable의 경우, v1.17+에서 사용이 가능하고, 여기서 General Availability가 되면 앞으로 > 영원히 deprecated되지 않는 친구들이다.
> 
> Taint Node by Condition
> 
> Configurable Pod Process Namespace Sharing
> 
> Schedule DaemonSet Pods by kube-scheduler
> 
> Dynamic Maximum Volume Count
> 
> Kubernetes CSI Topology Support
> 
> Provide Environment Variables Expansion in SubPath Mount
> 
> Defaulting of Custom Resources
> 
> Move Frequent Kubelet Heartbeats To Lease Api
> 
> Break Apart The Kubernetes Test Tarball
> 
> Add Watch Bookmarks Support
> 
> Behavior-Driven Conformance Testing
> 
> Finalizer Protection For Service Loadbalancers
> 
> Avoid Serializing The Same Object Independently For Every Watcher
> 

## 2.1 Taint Node by Condition
> 
> node의 condition은 총 6개로 표현된다.
> 
> Ready  - 정상
> 
> OutOfDisk - 남은 Disk 용량 부족
> 
> MemoryPressure - 메모리 공간 부족
> 
> DiskPressure - Disk capacity 부족
> 
> NetworkAvailable - network 연결 안된 상태
> 
> PIDPressure - 너무 많은 process 실행중
> 
> 
> 그리고 각각의 condition에 대해,  True, False, Unknown 라는 3가지 Status가 존재한다.
> 
> 이 condition과 status를 활용한 Taint를 사용할 수 있다.
> 
> 예를 들면 node.kubernetes.io/network-unavailable=:NoSchedule 처럼 network환경이 좋지 않은 경우  스케줄링을 해제할 수 있다.
> 
> 

## 2.2 Configurable Pod Process Namespace Sharing
> 
> POD내 프로세스 namespace 공유 설정
> 
> 여러 container가 하나의 POD에서 실행되면 많은 사항을 공유하게 된다.
> 
> 기본적으로 container image로 실행된 process는 PID값이 1이다.
> 
> 그러나 여러 container가 실행되는 경우 그렇지 않다.
> 
> 즉, 한 container에서 실행되는 process를 같은 POD내 다른 container에서 확인할 수 있다. ( visible )
> 
> spec.shareProcessNamespace: True로 설정하면 process namsepace sharing이 가능하다.
> 
> 참고 : https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/
> 


## 2.3 Schedule DaemonSet Pods by kube-scheduler
> 
> Daemonset pod의 경우, 각 노드별로 하나씩 실행되어야하기에 노드가 추가 혹은 삭제될 때 pod가 추가적으로 실행, 삭제 되어야 한다.
> 
> 이에 대한 관리를 kube-scheduler가 아닌 damonset controller가 진행해왔다.
> 
> 그러다 보니, 4가지 정도의 문제가 생겼다.
> 
> A.	daemonset controller는 node의 리소스 정보를 알지 못한다.
> 
> B.	pod affinity, antiaffinity에 대한 정보도 없다.
> 
> C.	scheduler가 해야할 일을 또 daemonset이 하고 있다.
> 
> D.	daemonset pod가 실행되지 않는 경우, debuging하기가 어렵다.
> 
> 이러한 이유로, daemonset controller가 daemonset pod를 관리하기보단, kube scheduler가 관리하는 > 것이 더 적절하다고 판단해서 kubescheduler가 관리하게 되었다.
> 


## 2.4 Dynamic Maximum Volume Count
> 
> Amazon EBS, Google Persistent Disk, Azure Dis, CSI에 대해서, Dynamic volume limit이라는 기능을 사용할 수 있다. 
> 
> 각 벤더마다 노드에 붙일 수 있는 볼륨의 개수를 다르게 제한하다보니 필요해진 기능이다.
> 
> CSI 스토리지 드라이버가 NodeGetInfo 를 사용해서 노드에 대한 최대 볼륨 수를 kube-scheduler에게 알리고 kube-scheduler는  그 한도를 따라 pod를 할당한다.
> 
> 

## 2.5 Kubernetes CSI Topology Support
> 
> 
> 아직 잘 모르겠다.
> 


## 2.6 Provide Environment Variables Expansion in SubPath Mount
> 
> volume을 mount하는 위치를 지정할 때, 환경변수를 사용할 수 있다.
> 
> 백문이 불여일견 예제를 통해 알아보자.
> 
> ``` yaml
> containers:
> - env:
>   - name: MY_POD_NAME
>     valueFrom:
>       fieldRef:
>         fieldPath: metadata.name
>   volumeMounts:
>   - mountPath: /cache
>     name: shared-folder
>     subPathExpr: $(MY_POD_NAME)
> ```
> subPathExpr에 $(MY_POD_NAME)을 사용하면 실제 shared-folder가 mount되는 위치는 /cache/$(MY_POD_NAME)이 된다.



## 2.7	Defaulting of Custom Resources

