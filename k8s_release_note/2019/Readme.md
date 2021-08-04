
# 1	2019

## 1.1	APIServer dry-run and kubectl diff

### 1.1.1	Challenges

k8s의 선언적인 특징을 위해 다음과 같은 문제를 해결하려한다.

> 1.	compiler와 linter 가 code에 대한 pull-request에러를 잘잡고 있지만 k8s config file에 대한 validation은 놓치는게 많다.
>
> 이때 활용하는 것이 kubectl apply dry-run 인데, 이는 실제 server와 통신하지 않기 때문에 server로 부터 validation을 받아오지 못한다. 
> 
> ( 특히 admission controller 를 거치지 않아서 실제 적용되는 값과 다를 수 있다.)
> 
> 그래서 custom resource가 server에만 존재한다면, dry-run으로는 validation을 확인할 수 없다.
> 
> 2.	아래와 같은 이유로 object가 api server를 통해 어떤 과정을 거칠 지 모른다.
> 
> 2.1	defaulting으로 인해 field에 예기치 못한 값이 설정될 수 있다.
> 
> 2.2	webhook을 변경하다가 field나 value들을 밀어버릴 수 있다.
> 
> 2.3	patch, merge작업이 예기치 못한 object들에게 영향을 줄 수있다.
> 
### 1.1.2	APIServer dry-run

APIServer dry-run은 다음과 같은 문제를 해결하기 위해 만들어졌다.

> 1.	각 request에 dry-run이라고 표시한다.

> 2.	dry-run을 실행한 request는 저장되지 않는다.

> 3.	일반적인 request와 같은 과정을 거친다. ( field가 default되고, object가 validated되고, validation admission chain을 거쳐 final object가 만들어진다.)

> 그런데 dynamic admission controller들이 dry-run에 대해 side-effect가 없다고는 하지만, 명시적으로 side-effect가 없는 admission controller에 대해서만 dry-run이 적용된다.

### 1.1.3	어찌 enabled하는가?

> dry-run은 kube-apiserver –feature-gates DryRun=true 와 같이 키고 끌 수 있다.

> 그래서 dry-run parameter를 webhook request에 사용하는 경우, side-effect를 없애야한다.
> 
> 혹은 sideEffects라는 field에서 해당 object에 대한 side-effect가 없다는 선언을 해줘야한다.
### 1.1.4	어찌 사용하는가?
> 
>  kubectl apply --server-dry-run을 통해 사용할 수 있다.  근데 이건 v1.18이후 사라졌다.
> 
> kubectl apply --dry-run=server를 통해 사용한다.
> 
### 1.1.5	kubectl diff
> 
> APIServer dry-run은 편리하긴하지만 object가 큰 경우 차이점을 확인하기 어렵다. 그래서 사용하는 것이 kubectl diff이다.
> 
> 1.1.6	어찌 사용하는가?
> 
> kubectl diff -f <some.yaml>
> 
> 새롭게 갱신되는 값들을 std로 알 수 있다.

## 1.2	Container Storage Interface – GA (CSI)

### 1.2.1	전반적인 내용

> 1.13부터 CSI 가 GA로 올라왔다.
> CSI는 1.9에 처음 alpha로 등장해서 1.10에 beta를 거쳐왔다.
### 1.2.2	왜 CSI인가?
> 
> 이전의 CSI가 충분히 강력한 volume plugin을 제공했지만, in-tree이기 때문에 (kubernetes code에 포함) 다양한 vendor들이 본인들 만의 storage system을 추가하려면 k8s release에 맞춰야하는 문제가 발생했다.
> 
> 거기에 third-party storage code가 reliability와 보안 문제를 일으키기도하고 code를 이해하는 것이 힘든 상황이었다.
> 
> CSI는 임의의 block 혹은 filestorage system을 containerized workloads에 할당할 수 있도록 설계되었다.
> 
>  이러한 CSI덕분에 k8s의 volume layer는 확장이 용이해졌다. third-party storage provider 가 CSI를 쓰면 k8s의 주요 code를 손보지 않고도 새로운 storage system을 제공할 수 있다.
> 

### 1.2.3	CSI가 GA로 올라오면서 추가된 점
> 
> 1.	k8s v1.13부터는 CSI v1.0,v0.3을 지원한다.
> 
> 2.	VolumeAttachment 라는 object가 v1.13에서 storage v1 group으로 추가되었다.
> 
> 3.	CSIPersistentVolumeSource가 k8s 1.13부터 GA로 올라왔다.
> 
> 4.	kubelet이 새로운 CSI driver를 찾을 때 사용하는 kubelet device plugin registration mechanism이 k8s 1.13부터 GA로 올라왔다.

### 1.2.4	CSI Driver 배포 방법
> 
> 각 CSI Driver의 document를 참고

### 1.2.5	CSI volume 사용법
> 
> CSI storage plugin이 배포되어있다는 가정하에, PVC, PV, StorageClass등을 통해 CSI volume을 사용할 수 있다.
> 비록 CSI가 k8s v1.13부터 GA이지만, 몇몇 flag들이 필요할 수도 있다.
> ( --allow-privileged=true )
> 
> 이유 : CSI의 bidirectional mount propagation기능은 privileged pod에서만 사용가능한데, 이와 같은 > pod는 위와 같은 flag가 있는 cluster에서만 사용이 가능하다.
> 
### 1.2.6	Dynamic Provisioning
> 
> CSI plugin을 지정하는 StorageClass를 생성하면, volume을 자동으로 생성, 삭제할 수 있다.
> 예시
``` yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast-storage
provisioner: csi-driver.example.com
parameters:
  type: pd-ssd
  csi.storage.k8s.io/provisioner-secret-name: mysecret
  csi.storage.k8s.io/provisioner-secret-namespace: mynamespace
```
>
> 이 storageclass는 csi-driver.example.com이라는 CSI plugin을 통해 volume을 생성, 삭제한다.
> 
> CSI v1.01+에서는 csi.storage.k8s.io라는 key를 지원한다.
> csiProvisionerSecretName, csiProvisionerSecretNamespace는 이후에 사라질 예정이다.
> 
### 1.2.7	Pre-Provisioned Volumes
> 
> persistentVolume을 생성해서 pre-existing volume을 사용할 수 있다.
``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-manually-created-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: csi-driver.example.com
    volumeHandle: existingVolumeName
    readOnly: false
    fsType: ext4
    volumeAttributes:
      foo: bar
    controllerPublishSecretRef:
      name: mysecret1
      namespace: mynamespace
    nodeStageSecretRef:
      name: mysecret2
      namespace: mynamespace
    nodePublishSecretRef
      name: mysecret3
      namespace: mynamespace
```
> 위와 같이 spec.csi.driver에 csi plugin 을 지정하고, spec.csi.volumeHandle에 existingVolumeName을 지정하면 기존에 떠있던 volume들을 csi에 포함되도록 할 수 있다.
### 1.2.8	Attaching and Mounting

> CSI volume에 bound된 pvc는 어느 POD에서나 참조할 수 있다.
> 
> 예시
> 
``` yaml
kind: Pod
apiVersion: v1
metadata:
  name: my-pod
spec:
  containers:
    - name: my-frontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: my-csi-volume
  volumes:
    - name: my-csi-volume
      persistentVolumeClaim:
        claimName: my-request-for-storage
```
> 
> CSI volume을 사용하는 POD가 스케줄링되면, k8s는 해당 POD가 volume을 사용할 수 있도록 외부 CSI plugin을 통해 적절한 operation을 진행한다.
> 
> 
### 1.2.9 How to write a CSI driver?

> 첫 번째 원칙은 CSI driver는 k8s에 대해 무관해야한다.
>
> 그래야 Storage vendor들이 k8s의 특징(버전별)에 상관없이 배포할 수 있기 때문이다.
>
> 다양한 side car와 함께 CSI driver를 만들게 되는데, 자세한 내용은
> https://kubernetes-csi.github.io/ 를 참고하자.

### 1.2.10 GA의 한계

> 현재 GA상태의 CSI를 사용하면, 임시 local volume은 PVC를 생성해야 사용할 수 있다.



## 1.3 Update on Volume Snapshot Alpha for k8s

