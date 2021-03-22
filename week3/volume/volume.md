# PV와 Statefulset test
> mongodb image를 사용한 Statefulset에 PV를 mount한 뒤 2가지 test를 진행해보겠습니다.
> 
>   > #### 초기상태
>   >
>   > mongo POD의 /data/db에 PV를 mount
>   >
>   > 해당 POD에 접근한 뒤, user db에 {data:"hi"}를 삽입
```
use user
db.user.insert({data,"hi"})
```
>   > #### TEST 1
>   >
>   > 실행중인 mongo POD를 종료시킨 뒤, 다시 실행되는 POD에서 {data:"hi"}가 있는지 확인
>   > 
>   > #### TEST 2
>   > 
>   > Statefulset을 삭제시킨 뒤, 다시 배포하여 {data:"hi"}가 있는지 확인

> #### 초기 상태 구현
```
kubectl apply -f mongo-pv.yaml

kubectl apply -f mongo.yaml
```
>
> < img src="/images/volume/1.JPG">
>
```
kubectl exec -it mongo-0 -- mongo
```
```
use user

db.user.insert({data:"hi"})

db.user.find()
```
>
> < img src="/images/volume/2.JPG">
>
>   > #### TEST 1
>   > 
```
kubectl delete pod mongo-0
```
