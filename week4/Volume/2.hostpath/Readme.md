## hostpath

이번 테스트는 emptydir과 유사하게 진행하겠습니다.

container의 /temp로 host node의 /etc/opt volume을 mount했습니다.

``` bash
cd week4/Volume/2.hostpath
kubectl apply -f POD1.yml
```

<img src="/images/volume/11.JPG">

localhost:30040으로 접속을 시도해보겠습니다.

<img src="/images/volume/12.JPG">

이제 /temp 위치에 새로운 html 파일을 생성해보겠습니다.

``` bash
kubectl exec -it hostpath-test -- bash
echo "Data before the deleting POD" > /temp/index.html
exit
```
<img src="/images/volume/13.JPG">

이제 POD를 재실행 시켜보겠습니다.

``` bash
kubectl delete pod hostpath-test && kubectl apply -f POD1.yaml
```

<img src="/images/volume/14.JPG">

다시 container에 접근해서, 아까 저장한 /temp/index.html이 존재하는지 확인해보겠습니다.

``` bash
kubectl exec -it hostpath-test -- bash
cat /temp/index.html
```

<img src="/images/volume/15.JPG">

기존 데이터가 유지된 모습입니다.

이제 host의 /etc/temp로 가서 해당 index.html이 있는지 확인해보겠습니다.

``` bash
exit
kubectl get pod -o wide
```

<img src="/images/volume/16.JPG">

해당 POD는 worker1에서 실행 중이므로, worker1의 /etc/opt를 확인해보겠습니다.

``` bash
// worker node에서 진행
cd /etc/opt
cat index.html
```

<img src="/images/volume/17.JPG">

container에서 설정한 값 그대로 저장된 것을 알 수 있습니다.

이제 worker node에서 index.html을 변경해보겠습니다.

``` bash
echo "Edit this file from host node" > /etc/opt/index.html
```

<img src="/images/volume/18.JPG">

다시 container에 접속해서 /temp/index.html을 확인해보겠습니다.

``` bash
// master node에서 진행
kubectl exec -it hostpath-test -- bash
cat /temp/index.html
```
<img src="/images/volume/19.JPG">

host node의 /etc/opt volume이 container의 /temp로 mount된 것을 확인할 수 있습니다.





hostpath volume을 사용할 경우 주의사항이 있습니다.

말 그대로 host node의 volume을 사용하기 때문에 POD가 다른 node에서 실행되면 다른 volume이 mount됩니다.

이를 확인해보겠습니다.

우선 master 1개, worker 1개인 환경이기 때문에 master에도 scheduling이 되도록 taint를 해제하겠습니다.

taint는 음식이나 물건의 quality를 떨어뜨리는 행위나 그 주체입니다. 박테리아나 세균이 음식을 상하게 할 때 taint라는 표현을 합니다.

즉 node에 taint 설정을 하면, 해당 taint에 대한 toleration이 있는 POD만 해당 node에서 실행이 가능합니다.

``` bash
// master node에서 진행
kubectl taint node $(cat /etc/hostname) node-role.kubernetes.io/master:NoSchedule-
```
<img src="/images/volume/20.JPG">

이제부터 masternode에도 POD scheduling이 가능합니다.

mongodb를 실행해보겠습니다.

``` bash
cd week4/Volume/2.hostpath

kubectl apply -f ./mongo.yaml

kubectl get pod -o wide

```

<img src="/images/volume/21.JPG">

<img src="/images/volume/25.JPG">


``` bash
kubectl exec -it mongo-0 -- mongo
```

<img src="/images/volume/22.JPG">

worker1에서 실행중인 mongodb POD에 접속했습니다.

``` bash
use user

db.user.insert({"node":"worker1"})

```
<img src="/images/volume/23.JPG">
user라는 db namespace에 { "node":"worker1"}라는 데이터를 저장했습니다.

``` bash
db.user.find({})

```
<img src="/images/volume/24.JPG">


user에 저장된 정보를 확인할 수 있습니다.
``` bash
exit
```

이제 이 POD가 worker node에서 master node로 옮겨갈 수 있도록 해보겠습니다.

``` bash
//master node에서 진행
kubectl cordon worker1

```
<img src="/images/volume/26.JPG">
<img src="/images/volume/27.JPG">

노드를 cordon을 하게되면 더이상 scheduling되지 않습니다.

node와 worker1 중 worker1을 cordon했으니 앞으로 POD는 node에만 scheduling될 것입니다.

mongo POD를 재실행 시켜보겠습니다.

``` bash
kubectl scale statefulset mongo --replicas=0 && kubectl scale statefulset mongo --replicas=1

```
<img src="/images/volume/28.JPG">

``` bash
kubectl get pod -o wide
```
<img src="/images/volume/29.JPG">

이제 POD가 master에서 실행되는 모습입니다.

이 POD로 접속해서, 이전에 삽입한 {"node":"worker1"}이 존재하는지 확인해보겠습니다.

``` bash
kubectl exec -it mongo-0 -- mongo
```
``` bash
db.user.find()
```
<img src="/images/volume/30.JPG">

아무것도 저장되지 않은 모습입니다.

``` bash
use user

db.user.insert({"node":"master"})

db.user.find()

exit
```
<img src="/images/volume/31.JPG">
{"node":"master"}라는 데이터를 삽입하고 종료하겠습니다.

worker1의 cordon을 해제하겠습니다.

``` bash
kubectl uncordon worker1
```
<img src="/images/volume/32.JPG">

그리고 POD를 다시 재실행 시켜보겠습니다.

``` bash
kubectl scale statefulset mongo --replicas=0 && kubectl scale statefulset mongo --replicas=1
```

<img src="/images/volume/33.JPG">

이제 POD가 worker1에서 실행되고 있습니다.

POD가 Running상태가 되면 접근해서 저장된 데이터를 확인해보겠습니다.

``` bash
kubectl exec -it mongo-0 -- mongo

use user

db.user.find()

exit
```
<img src="/images/volume/34.JPG">
worker1에서 실행되는 mongo POD에는 {"node":"worker1"}이라는 데이터가 저장되어 있습니다.

node에서 실행되는 mongo POD에서는 {"node":"master"}라는 데이터가 저장되어 있을 것입니다.

``` bash
kubectl cordon worker1

kubectl scale statefulset mongo --replicas=0 && kubectl scale statefulset mongo --replicas=1

kubectl get pod -o wide

```
<img src="/images/volume/35.JPG">

node에서 실행되는 mongo POD에 접근해보겠습니다.

``` bash
kubectl exec -it mongo-0 -- mongo

use user

db.user.find()
```
<img src="/images/volume/36.JPG">

hostpath를 사용하게 되면 실행중인 host node에 따라 volume이 바뀌어 data integrity를 보장할 수 없습니다.

그래서, nodeSelector나 affinity를 활용해서 특정 node에서만 실행될 수 있도록 설정해야 합니다.

nodeSelector와 affinity는 week4/POD/NODE directory를 참고하시기 바랍니다.

