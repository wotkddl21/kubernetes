## hostpath

이번 테스트는 emptydir과 유사하게 진행하겠습니다.

container의 /temp로 host node의 /etc/opt volume을 mount했습니다.

```
cd week4/Volume/hostpath
kubectl apply -f POD1.yml
```

<img src="/images/volume/11.JPG">

localhost:30040으로 접속을 시도해보겠습니다.

<img src="/images/volume/12.JPG">

이제 /temp 위치에 새로운 html 파일을 생성해보겠습니다.

```
kubectl exec -it hostpath-test -- bash
echo "Data before the deleting POD" > /temp/index.html
exit
```
<img src="/images/volume/13.JPG">

이제 POD를 재실행 시켜보겠습니다.

```
kubectl delete pod hostpath-test && kubectl apply -f POD1.yaml
```

<img src="/images/volume/14.JPG">

다시 container에 접근해서, 아까 저장한 /temp/index.html이 존재하는지 확인해보겠습니다.

```
kubectl exec -it hostpath-test -- bash
cat /temp/index.html
```

<img src="/images/volume/15.JPG">

기존 데이터가 유지된 모습입니다.

이제 host의 /etc/temp로 가서 해당 index.html이 있는지 확인해보겠습니다.

```
exit
kubectl get pod -o wide
```

<img src="/images/volume/16.JPG">

해당 POD는 worker1에서 실행 중이므로, worker1의 /etc/opt를 확인해보겠습니다.

```
// worker node에서 진행
cd /etc/opt
cat index.html
```

<img src="/images/volume/17.JPG">

container에서 설정한 값 그대로 저장된 것을 알 수 있습니다.

이제 worker node에서 index.html을 변경해보겠습니다.

```
echo "Edit this file from host node" > /etc/opt/index.html
```

<img src="/images/volume/18.JPG">

다시 container에 접속해서 /temp/index.html을 확인해보겠습니다.

```
// master node에서 진행
kubectl exec -it hostpath-test -- bash
cat /temp/index.html
```
<img src="/images/volume/18.JPG">

host node의 /etc/opt volume이 container의 /temp로 mount된 것을 확인할 수 있습니다.
