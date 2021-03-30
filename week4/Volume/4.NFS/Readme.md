# NFS ( Network File System )

앞서 emptydir과 hostpath에 대해 알아보았습니다.

emptydir은 데이터가 지속적으로 유지되지 않고 POD가 재실행되면 초기화되는 단점이 있습니다.

hostpath는 데이터는 유지되지만 POD가 실행되는 hostnode에 따라 volume이 달라지는 단점이 있습니다.

이러한 단점을 개선하기 위한 것이 NFS입니다.

NFS는 kubernetes에서 만들어진 것이 아닌, 이전부터 존재하던 개념입니다.

특정 node의 storage를 network를 통해 사용하는 것이 NFS의 원리입니다. 

kubernetes에서는, cluster 외부의 file system을 network를 통해 사용할 수 있습니다.

이 경우 cluster와 독립적인 생명주기를 가지기 때문에 데이터가 지속적으로 유지될 수 있습니다.

또한 POD가 실행중인 node와 상관 없이, 일정한 volume을 mount할 수 있습니다.

## TEST

NFS를 어떻게 사용하는지에 대해 알아보겠습니다.

NFS로 사용할 node가 추가적으로 필요하고 이 volume을 provisioning할 PV와 이를 사용하기 위한 PVC가 필요합니다.

새로운 node를 하나 생성하겠습니다.

자세한 스펙은 다음과 같습니다. 

OS: Ubuntu 20.04, CPU: 4Core, RAM: 8GB, NODE NAME: NFS

``` bash
/// NFS node에서 root로 진행
sudo -i
apt install nfs-kernel-server -y

```


<img src="/images/volume/44.JPG">
<img src="/images/volume/45.JPG">

NFS node에 nfs를 설치했습니다.

nfs로 사용할 directory인 /var/nfs/general을 만들고 외부에서 이 nfs를 사용할 수 있도록 config를 변경하겠습니다.

``` bash
mkdir /var/nfs/general -p
chown nobody:nogroup /var/nfs/general
```
<img src="/images/volume/47.JPG">
```
vi /etc/exports
```
<img src="/images/volume/46.JPG">


*은 모든 ip에서 접근이 가능하도록 만드는 설정이고 rw는 read/write, sync는 동기식으로 volume을 사용하도록 만드는 설정입니다.

변경된 설정을 적용하기 위해 nfs-server를 재실행하겠습니다.

```
systemctl restart nfs-server
```
<img src="/images/volume/48.JPG">

nfs로 /var/nfs/general이 잘 export되었는지 확인해보겠습니다.

<img src="/images/volume/52.JPG">

TEST로 사용할 temp.txt를 만들고 777 권한을 주겠습니다.

``` bash

echo "NFS-server" > /var/nfs/general/temp.txt

chmod 777 /var/nfs/general/temp.txt

```

<img src="/images/volume/52.JPG">

이제 nfs server에 대한 설정은 완료되었고, 이를 사용할 client에 대한 설정이 필요합니다.

nfs server의 ip주소를 미리 확인하겠습니다.

``` bash
hostname -I
```

<img src="/images/volume/49.JPG">

nfs-server의 ip는 130.1.3.124입니다.

kubernetes cluster의 모든 node에 이 client 설정을 해줘야 nfs사용이 가능합니다.

각 node에 nfs-common을 설치하겠습니다.

``` bash
// 각 node에서 진행
apt install nfs-common -y
```
<img src="/images/volume/50.JPG">
<img src="/images/volume/51.JPG">

중략

node에서 nfs-server의 ip인 130.1.3.124에서 export하는 volume을 확인해보겠습니다.

``` bash

showmount -e 130.1.3.124

```
<img src="/images/volume/52.JPG">

이제 이 nfs를 사용하는 PV를 만들어보겠습니다.

아래는 PV-NFS.yaml 파일 내용입니다.

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
  labels:
    app: pv-nfs
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 130.1.3.124
    path: /var/nfs/general
```

여기서, nfs.server의 값은 아까 구한 nfs-server의 ip를 입력하면 됩니다.

```
//master node에서 진행 
cd week4/Volume/4.NFS
kubectl apply -f PV-NFS.yaml

```
<img src="/images/volume/55.JPG">

성공적으로 PV가 생성되었고 Available상태입니다.

이제 PVC를 생성해보겠습니다.



``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
spec:
  storageClassName: manual
  selector:
    matchLabels:
      app: pv-nfs
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

방금 생성한 pv가 app:pv-nfs라는 label을 가지고 있습니다. 이 PVC는 app:pv-nfs인 pv에 Bound되니, pv-nfs에 Bound될 것입니다.

``` bash

kubectl apply -f PVC-NFS.yaml

```
<img src="/images/volume/56.JPG">

이제 이 PVC를 사용하는 POD를 만들어서, 아까 생성한 temp.txt의 내용을 확인해보겠습니다.
``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: nfs-test
spec:
  containers:
    - name: nfs-test
      image: nginx
      volumeMounts:
      - mountPath: "/temp"
        name: pv-nfs
  volumes:
    - name: pv-nfs
      persistentVolumeClaim:
        claimName: pvc-nfs
```
이 POD는, nfs를 사용하는 pv를 container의 /temp 위치로  mount시킵니다.

즉, 이 POD의 /temp에는 temp.txt라는 파일이 존재할 것입니다.

``` bash
kubectl apply -f POD.yaml
```

<img src="/images/volume/57.JPG">

``` bash
kubectl get pod
```

<img src="/images/volume/58.JPG">

nfs-test POD가 실행중인 상태가 되면 접근해서 확인해보겠습니다.

``` bash
kubectl exec -it nfs-test -- bash

cat /temp/temp.txt
```
<img src="/images/volume/59.JPG">

아까 저장한 NFS-server라는 값이 출력되는 것을 알 수 있습니다.

이번엔 이 파일을 수정해보겠습니다.

``` bash

echo "Hi from kubernetes node!" > /temp/temp.txt

exit

```

<img src="/images/volume/60.JPG">

이 변경된 사항을 nfs-server에서 확인해보겠습니다.

``` bash
// nfs-server node에서 진행

cat /var/nfs/general/temp.txt

```

<img src="/images/volume/61.JPG">

아까 수정한 내용이 반영된 것을 알 수 있습니다.

현재 POD는 node에서 실행중입니다.

이 POD를 worker1에서 실행되게 했을 때 변경된 데이터가 유지되는지 확인해보겠습니다.

``` bash

//master node에서 진행

kubectl delete -f POD.yaml

kubectl apply -f POD.yaml

kubectl get pod -o wide

```
<img src="/images/volume/62.JPG">

이제 nfs-test는 worker1에서 실행됩니다.

다시 한 번 nfs-test POD에 접근해서 /temp/temp.txt에 저장된 데이터를 확인해보겠습니다.

``` bash
kubectl exec -it nfs-test -- bash

cat /temp/temp.txt

```
<img src="/images/volume/63.JPG">
master node에서 실행중이던 POD에서 작성한 "Hi from kubernetes node!" 값이 nfs server에 저장되고, POD가 worker1에서 다시 실행된 뒤에도 그 값을 그대로 가져오는 모습입니다.
``` bash
exit
```
<img src="/images/volume/64.JPG">

네트워크 환경에 따라 I/O속도가 달라지겠지만 데이터의 integrity를 지키기 위해선 NFS형태를 사용하는 것이 적절하다고 생각합니다.

저는 NFS를 사용했지만, 만약 public cloud를 사용한다면 (AWS, GCP, Azure), 공유 storage를 PV로 provisioning해서 사용하는 것이 적절해보입니다.