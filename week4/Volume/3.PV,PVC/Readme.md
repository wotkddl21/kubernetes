# PV, PVc

앞서 emptydir과 hostpath에 대해 알아보았습니다.

이때 사용되는 volume을 container에 mount 할 때 spec.volumes에서 emptydir과 hostpath를 정의했습니다.

kubernetes에서는 이 volume을 좀 더 추상화하는 기능을 제공합니다.

그것이 바로 PV ( Persistent Volume )와 PVC ( Persistent Volume Claim )입니다.

Volume관리자는 PV라는 resource를 통해 volume을 제공하고, 사용자는 PVC를 통해 원하는 volume을 사용할 수 있습니다.

전체적인 구조는 volume관리자가 provisioning한 volume에 대한 PV가 먼저 생성되고 사용자가 원하는 PVC가 적절한 PV에 Bound되는 형태입니다.

POD에서 사용하고자 하는 volume에 대한 pvc를 선언하면 cluster 내부에 해당 pvc가 mount되는 구조입니다.

yaml파일을 예시로 살펴보겠습니다.

``` yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
spec:
  selector:
    matchLabels:
      app: mongo
  serviceName: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - image: mongo
        name: mongo
        ports:
        - containerPort: 27017
          name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: "/data/db"
      volumes:
      - name: mongo-persistent-storage
        persistentVolumeClaim:
          claimName: mongo-pv-claim
```
위 statefulset의 POD는, mongo-pv-claim이라는 pvc를 mongo-persistent-storage라는 이름으로 mongo container의 "/data/db"로 mount합니다.

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongo-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
   path: /0325/db/pv
```
위는 PV에 대한 yaml파일입니다.

이 PV의 이름은 mongo-pv-volume이고 host node의 /0325/db/pv의 volume을 ReadWriteOnce방식으로 1Gi만큼 provisioning합니다.

``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

위는 PVC에 대한 yaml파일입니다.

이 PVC는, ReadWriteOnce type의 volume을 1Gi만큼 요구합니다.

``` bash
cd week4/Volume/3.PV,PVC
kubectl apply -f mongo-pv.yaml

```
<img src="/images/volume/37.JPG">
mongo-pv-volume이라는 pv가 만들어지고 Available인 상태입니다.

``` bash

kubectl apply -f mongo-pvc.yaml

```
<img src="/images/volume/38.JPG">

mongo-pv-claim이라는 pvc가 만들어지고 mongo-pv-volume에 Bound된 상태입니다.

이제 이 pvc를 사용하는 POD를 생성해보겠습니다.


``` bash

kubectl apply -f mongo.yaml

```

<img src="/images/volume/39.JPG">

``` bash

kubectl describe pod mongo-0

```

<img src="/images/volume/40.JPG">

성공적으로 volume이 mount된 것을 확인할 수 있습니다.






그렇다면 "여러 PV가 존재할 때, PVC는 어느 PV에 Bound되는가"에 대한 의문이 있을 수 있습니다.

PVC를 원하는 PV에 Bound시키기 위해 사용하는 것이 selector입니다.

PV의 metadata.label에 key:value를 정의해서 labeling을 한 뒤, PVC에서 해당 label이 붙은 PV에 bound되도록 설정할 수 있습니다.

2개의 PV를 추가적으로 생성해보겠습니다.

``` bash

kubectl apply -f PV1.yaml
kubectl apply -f PV2.yaml
kubectl get pv -o wide

```
<img src="/images/volume/41.JPG">

2개의 PV가 생성되었습니다.

``` bash
kubectl describe pv pv1
kubectl describe pv pv2
```
<img src="/images/volume/42.JPG">

PV1은 app:pv1, PV2는 app:pv2라는 label을 가지고 있습니다.

PVC1은 PV1에, PVC2는 PV2에 Bound되도록 PVC1은 app:pv1을, PVC2는 app:pv2를 matchLabel로 설정했습니다.

``` bash
kubectl apply -f PVC1.yaml
kubectl apply -f PVC2.yaml

```
<img src="/images/volume/43.JPG">

PVC1 --> PV1, PVC2 --> PV2 로 잘 Bound되었습니다.







