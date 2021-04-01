# CI / CD pipeline 구축

### 1. gitlab server 구축

개발환경과 연동할 gitlab server를 gitlab image를 통해 구축하겠습니다.

``` bash
cd week5/CI-CD/1.gitlab
kubectl apply -f gitlab.yaml
```
소스코드를 보며 분석해보겠습니다.

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitlab
  labels:
    app: gitlab
spec:
  selector:
    matchLabels:
      app: gitlab
  template:
    metadata:
      labels:
        app: gitlab
    spec:
      containers:
      - name: gitlab-container
        image: gitlab/gitlab-ce
        ports:
          - containerPort: 80
        volumeMounts:
          - name: gitlab-volume1
            mountPath: /etc/gitlab
          - name: gitlab-volume2
            mountPath: /var/log/gitlab
          - name: gitlab-volume3
            mountPath: /var/opt/gitlab
      volumes:
        - name: gitlab-volume1
          hostPath:
            path:  /srv/gitlab/config
        - name: gitlab-volume2
          hostPath:
            path: /srv/gitlab/logs
        - name: gitlab-volume3
          hostPath:
            path: /srv/gitlab/data
```
image는 gitlab에서 제공하는 community edition ( gitlab-ce )를 사용했습니다.

gitlab POD가 재실행되어도 기존 설정을 유지하기 위해서 gitlab 설정 저장 위치인 /etc/gitlab, /var/log/gitlab, /var/opt/gitlab으로 volume이 mount됩니다.

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: gitlab-service
spec:
  type: NodePort
  selector:
    app: gitlab
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
```
gitlab을 외부에서 접속하기 위해 NodePort형태의 service를 붙였습니다.

``` bash
kubectl apply -f service.yaml
```

<img src="/images/CICD/3.JPG">

이제 실행시킨 gitlab POD에 web browser를 통해 접근해보겠습니다.

``` 
localhost:30080
```

<img src="/images/CICD/4.JPG">

root계정의 초기 비밀번호를 설정해야합니다.

저는 test1234로 진행하겠습니다.

<img src="/images/CICD/5.JPG">

비밀번호를 성공적으로 변경했다는 메세지가 출력됩니다.

gitlab계정을 생성해서, 이 gitlab POD와 연동을 해야합니다.

<img src="/images/CICD/10.JPG">

<img src="/images/CICD/6.JPG">

<img src="/images/CICD/11.JPG">

계정을 생성했다면 root계정으로 접속해보겠습니다.

<img src="/images/CICD/7.JPG">

접속했다면 View setting을 눌러 좌측 Nav Bar를 열어줍니다.

<img src="/images/CICD/9.JPG">

관리자 옵션을 클릭합니다.

<img src="/images/CICD/12.JPG">

하단의 Latest users에서 방금 만든 계정을 승인해줘야합니다.

<img src="/images/CICD/13.JPG">

<img src="/images/CICD/14.JPG">

이제 아까 생성한 계정으로 접속합니다.

<img src="/images/CICD/15.JPG">

<img src="/images/CICD/16.JPG">

새로운 blank project를 생성합니다.

<img src="/images/CICD/17.JPG">

<img src="/images/CICD/18.JPG">

<img src="/images/CICD/20.JPG">

개발환경을 만들어 이 project와 연동해보겠습니다.

개발환경은 kubernetes 외부로 설정하겠습니다. project url을 gitlab-7f6d59f5ff-tnww7가 아닌 < node ip >:30080으 로 변경해야합니다.

제가 예전에 진행했던 react와 node를 이용한 코인세탁소 예약 시스템 project를 연동하겠습니다.

``` shell
// 개발환경에서 진행 ( 외부 node )

git clone https://github.com/wotkddl21/cicd-test-k8s.git
cd capstone2_public
git remote rename origin old-origin
git remote add origin http://< node ip>:30080/<gitlab username>/<gitlab project>.git
git push -u origin --all
git push -u origin --tags
```

<img src="/images/CICD/19.JPG">

push를 하게 되면 git credential을 입력해야합니다.

이때 아까 가입한 gitlab 계정을 통해 login을 해야합니다.

<img src="/images/CICD/24.JPG">

<img src="/images/CICD/25.JPG">

<img src="/images/CICD/26.JPG">

이제 개발환경의 ssh key를 gitlab으로 보내서 push가 자동으로 이루어질 수 있도록 합니다.

``` terminal

ssh-keygen -t rsa
```
우선 ssh key를 새로 만듭니다.

저는 이전에 key를 만든 적이 있어, 새롭게 덮어썼습니다.

<img src="/images/CICD/27.JPG">

이 키는 default로 C:\Users\User/.ssh/id_rsa.pub 에 있습니다.

<img src="/images/CICD/28.JPG">

<img src="/images/CICD/29.JPG">

ssh key를 추가하겠습니다.

<img src="/images/CICD/30.JPG">

<img src="/images/CICD/31.JPG">

id_rsa.pub 파일에 적혀있는 ssh key를 복사한 뒤, expire at을 수정하고 Add key버튼을 클릭합니다.

저는 1년 뒤 ssh key가 만료되도록 설정했습니다.

<img src="/images/CICD/32.JPG">

이로써 gitlab과 개발환경의 연동이 완료되었습니다.

Projects를 통해 확인해보겠습니다.

<img src="/images/CICD/33.JPG">

<img src="/images/CICD/34.JPG">

<img src="/images/CICD/temp.jpg">