# dockerfile

### 사전지식

docker에 대해 많은 것을 다루려면 너무 양이 방대해지기 때문에 CI-CD를 설계하는데 필요한 정도로만 설명하겠습니다.

Dockerfile은 사용자가 원하는 container환경을 구축하기 위한 명령어 모음집입니다.

docker의 build를 사용하면 이 파일에 적혀있는 명령어를 순서대로 진행해서 image로 만드는 작업을 합니다.

```
ex)
docker build -t wotkddl21/k8s .

```

예시에서 사용한 명령어를 간단하게 해석해보겠습니다.

docker를 실행해서 build라는 기능을 사용했습니다.

-t 는 docker iamge를 지칭할 tag에 대한 옵션입니다.

이 명령어로 만들어지는 image는 wotkddl21/k8s tag를 가지게 됩니다.

마지막의  .  은 현재 디렉토리를 의미하는 것으로, image를 build하기 위한 데이터를 현재 디렉토리에서 가져온다는 뜻입니다.

이렇게 build한 image는, local에서는 바로 사용이 가능합니다.

그러나 이 image를 다른 위치에서 사용하려면 registry에 push를 해야합니다.

registry는 크게 local registry와 docker hub가 있습니다.

local registry는 내부 망에 존재하는 registry로, local registry의 주소가 tag의 prefix로 존재합니다.

ex)  local registry 주소 : localhost:5000 
tag : localhost:5000/wotkddl21/k8s

docker hub에서 사용할 image는 tag만 사용합니다.

ex) tag: wotkddl21/k8s

그래서 tag만 보고도 local registry에서 사용하는지, docker hub에서 관리하는지 알 수 있습니다.

이렇게 만들어진 image를 registry에 push를 하면 다른 사람이 pull해서 사용할 수 있게됩니다.

``` shell
docker push wotkddl21/k8s
```

명령어를 살펴보면, 어디로 push할 지 지정하지 않았습니다.

이는, tag자체가 image가 저장될 주소를 의미하기 때문입니다. 앞서 tag만 보고도 어느 registry에서 사용하는지 알 수 있다는 것의 연장선입니다.

wotkddl21/k8s 경우 hub.docker.com/r/wotkddl21/k8s 에 저장됩니다.

<img src="/images/CICD/91.jpg">

localhost:5000/wotkddl21/k8s 경우 localhost:5000/wotkddl21/k8s에 저장됩니다.

그리고 push를 하려면 무조건 인증과정을 거쳐야합니다. username, password로 login을 통해 인증이 이루어집니다.

image를 build하고 push하는 흐름에 대해 어느정도 알아봤습니다.

이제 image를 가져와서 사용하려면 pull을 해야합니다.

``` shell
docker pull wotkddl21/k8s
```
pull도 tag를 통해 image의 위치를 파악하고 가져옵니다.

이때 해당 image가 저장된 곳이 private registry라면 인증과정을 거쳐야합니다. ( public image는 인증없이 가져올 수 있습니다.)

docker는 username, password 방식으로 인증을 진행합니다.

저의 docker 명령어를 사용할 수 있는 docker image로 POD를 만든 뒤 소스코드를 build해서 docker hub에 push를 진행할 예정입니다.

이렇게 만들어진 image를 jenkins POD에서 pull한 뒤, k8s cluster에 배포를 하는 방식으로 CD기능을 구현할 것입니다.

image를 push, pull 하는 과정에서 docker 인증이 필요한데, 이 정보를 docker credential로 만들어서 jenkins pipeline에 추가해서 docker 인증을 진행할 예정입니다.

docker credential을 추가하는 것 부터 Dockerfile을 작성하는 것까지 진행해보겠습니다.

### docker credential

Jenkins에 docker credential을 추가해보겠습니다.

<img src="/images/CICD/92.jpg">

<img src="/images/CICD/93.jpg">

<img src="/images/CICD/94.jpg">

<img src="/images/CICD/95.jpg">

<img src="/images/CICD/96.jpg">

Username과 Password는 본인 docker hub 계정 username과 password를 입력하면 됩니다.

ID는, 나중에 jenkinsfile에서 참조할 때 사용하기 때문에 기억해두셔야합니다.

저는 docker_credential 로 설정했습니다.

<img src="/images/CICD/97.jpg">


### Dockerfile

Dockerfile도 언급할 내용이 많지만 여기서 필요한 부분만 진행하도록 하겠습니다.

Dockerfile은 docker명령어에서 build할 때 사용되는 파일입니다.

파일 내의 명령어 한 줄을 진행할 때마다 layer를 하나씩 쌓아가는 방식으로 image를 생성합니다.

같은 결과물일지라도 순서가 다르거나 한 줄에 여러 명령어를 실행한다면 다른 layer를 바탕으로 image가 만들어집니다.

이 layer를 언급하는 이유는 docker에서는 caching을 사용하기 때문입니다.

같은 layer라면 caching을 사용할 수 있지만 layer가 달라지면 build를 다시 진행해야합니다.

``` dockerfile
FROM node:12.2.0-alpine

# set working directory
COPY . .
WORKDIR /react-test/client
RUN npm install


WORKDIR /react-test
RUN npm install 
# 앱 실행
CMD ["npm", "run", "dev"]
```

위 코드를 보면 제일 첫 줄에서 node:12.2.0-alpine를 base image로 사용하겠다는 선언을 합니다.

COPY . . 은, 좌측은 Dockerfile이 존재하는 directory이고, 우측은 container의 directory입니다.

즉, 현재 directory에 있는 모든 것을 container로 복사하는 작업입니다.

WORKDIR은 다음 명령어가 실행될 위치를 지정합니다.

이 Dockerfile의 흐름은, 현재 디렉토리의 모든 파일을 container로 옮긴 뒤,

/react-test/client:~# npm install
/react-test:~# npm install
/react-test:~# npm run dev

를 실행하는 것입니다.

제가 예전에 진행했던 project여서 저에게 맞는 형태의 Dockerfile을 만들었습니다.

만약 다른 project를 연동하신다면 해당 project를 실행하기 위한 환경설정과정을 그대로 Dockerfile에 반영하시면 됩니다.

Dockerfile은, .git과 같은 디렉토리에 만드시면됩니다.



