## emptydir

> nginx image는, /usr/share/nginx/html/index.html를 이용해 landing page를 구성합니다.
>
> 성공적으로 nginx container를 실행 시킨 뒤, 접근하면 해당 html파일을 response로 반환합니다.
>
> 이번 TEST는 다음과 같이 진행하겠습니다.
>
> 1. emptydir을 mount한 nginx container 실행
>
> 2. 해당 container접근하여 html파일 확인
>
> 3. /usr/share/nginx/html파일 수정
>
> 4. 수정내용 반영 확인
>
> 5. container 재실행 ( POD 재실행 )
>
> 6. 3에서 수정한 내용이 유지되었는지 확인
>
> 
```
cd week4/Volume/emptydir
kubectl apply -f POD1.yaml
```
>
> <img src="/images/volume/3.JPG">
>
> web browser를 통해 localhost:30030으로 접속해보겠습니다.
>
> <img src="/images/volume/4.JPG">
>
> 404 Not Found의 의미는 server에 없는 데이터를 요청했다는 것입니다.
>
> emptydir의 특성상, 초기화된 상태로 mount되기 때문에 mountPath를 /usr/share/nginx로 설정하게 되면 default html이 존재하지 않습니다.
>
> 그래서 mountPath를 다른 곳으로 설정한 뒤, 해당 파일이 유지되는지 확인해보겠습니다.
> 
```
kubectl apply -f POD2.yaml
```
> 
> <img src="/images/volume/5.JPG">
>
> 이번엔 localhost:30080을 통해 새로운 container로 접속해보겠습니다.
>
> <img src="/images/volume/6.JPG">
> 
> 성공적으로 nginx 페이지에 접속했습니다.
>
> 이 페이지를 수정해보겠습니다.
>
```
kubectl exec -it test-temp -- bash
echo "hi" > /usr/share/nginx/html/index.html
```
>
> 다시 localhost:30080으로 접속해보겠습니다.
>
> <img src="/images/volume/7.JPG">
> 
> 방금 수정한 내용이 반영된 모습입니다.
>
> 이 내용을 mount된 volume에도 적용해보겠습니다.
```
cat /usr/share/nginx/html/index.html > /temp/index.html
cat /temp/index.html
exit
```
>
> <img src="/images/volume/8.JPG">
> 
> POD를 재실행 시킨 뒤 수정한 내용이 유지되는지 확인해보겠습니다.
>
```
kubectl delete pod test-temp && kubectl apply -f POD2.yaml
```
> 
> <img src="/images/volume/9.JPG">
> 
> 다시 /temp/index.html이 있는지 확인해보겠습니다.
> 
```
kubectl exec -it test-temp -- cat /temp/index.html
```
> 
> <img src="/images/volume/10.JPG">
> 
> /temp/index.html가 존재하지 않는 모습입니다.
> 
> emptydir이 mount된 POD가 종료되면서 초기화되었고 다시 mount되었기에 아무 정보도 없는 모습입니다.

