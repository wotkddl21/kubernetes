# CI / CD pipeline

CI / CD 란 무엇인가?

CI/CD는 Continuous Integration / Continuous Deploy 의 약어입니다.


### CI ( Continuous Integraton )

git을 통해 여러 개발자가 형상관리를 하는 상황을 가정해보겠습니다.

각자 본인의 환경으로 repository를 clone한 뒤 개발을 진행할 것입니다.

프로젝트가 종료되기 전까지 주기적으로 코드를 합쳐야 할 것입니다.

그렇지 않으면 어느지점에서 문제가 발생하는지 찾기 어렵기 때문입니다.

이 때 필요한 것이 CI입니다.

새롭게 추가 혹은 수정한 코드가 잘 실행이 되는지에 대한 테스트를 진행한 뒤 repository에 추가하는 과정을 거칩니다.

이 테스트 과정은 코드의 길이 혹은 복잡도에 따라 크게 달라집니다.

만약 테스트 기간이 너무 길다면 개발자 입장에서는 개발보다 테스트를 진행하는 것에 더많은 시간을 할애할 것입니다.

그래서 많은 사람들이 이 과정을 자동화하려고 합니다.

코드를 수정해서 push를 하게 되면 미리 설정해놓은 테스트 코드를 실행하여 올바른 형태로 작성이 되었는지를 확인하는 과정을 거칩니다.


### CD ( Continuous Deploy )

개발자들이 새롭게 작성한 코드를 운영중인 서비스에 반영해야 새로운 서비스를 제공할 수 있습니다.

kubernetes에서 image를 최신 것으로 반영하려면 POD의 재배포 과정을 거쳐야합니다.

이때 POD 혹은 Deploymnet의 종류가 많다면 수작업으로 진행하기엔 많은 시간이 소요됩니다.

사용자가 지정한 순서대로 POD혹은 Deployment를 수정하도록 자동화한 것이 CD입니다.


### CI / CD pileline

CI / CD pipeline 이라 하는 이유는, 새로운 코드를 작성해서 git으로 저장하게 되면, 소스코드 합병, 테스트를 거쳐 배포까지 한 번에 이루어지도록 설계했기 때문입니다.

개발자의 입장에서 개발에만 신경쓰고 그 이후의 과정은 자동화할 수 있기에 자주 사용하는 개념입니다.


### How to?

CI / CD pipeline은 보통 gitlab과 Jenkins를 통해 구축합니다.

1. git ( gitlab )으로 소스코드 전송 (push)

2. gitlab에서 Jenkins로 Webhook 전송

3. jenkins에서 build 시작 ( docker image )

4. build작업을 진행할 docker POD 실행

5. 1.에서 push한 소스코드를 docker POD로 복사

6. docker image build 및 push

7. push한 image를 다시 pull

8. 가져온 image 재배포


### gitlab Jenkins

gitlab과 Jenkins에 대해 알아보겠습니다.

#### gitlab

<img src="/images/CICD/1.JPG">

gitlab은 원격 혹은 로컬 git registry를 웹 기반으로 사용할 수 있는 오픈소스입니다.

이번 실습에선 gitlab docker image를 통해 로컬 registry로 사용할 예정입니다.

로컬 개발환경과 연동하여 gitlab으로 소스코드를 push, pull 등의 작업을 진행할 수 있습니다.


#### Jenkins

<img src="/images/CICD/2.JPG">

Jenkins는 CI tool입니다. 

이번 예제에서 gitlab으로 부터 webhook을 받아 미리지정한 build pipeline을 실행하게 될 예정입니다.



### 사전지식

#### kube-apiserver 인증

8.의 과정 중 POD를 배포하려면 kube-apiserver로 요청을 보내야합니다.

이때 사용자 인증과정을 거치게 됩니다.

자세한 사항은 <a href="/week1,2/access to kube-apiserver.md" >access to kube-apiserver.md</a>에서 확인하시면 됩니다.

이 경우에는 serviceaccount를 생성하고 k8s-admin role을 binding해서 POD를 배포할 수 있는 권한을 부여할 것입니다.

#### dockerfile

사용자가 작성한 코드를 kubernetes에서 POD로 배포하려면 docker image로 만들어야합니다.

이 때 필요한 것이 dockerfile입니다.

필요한 구성요소들을 복사, 설치하는 command를 작성하면 docker build 실행시 자동으로 진행됩니다.

#### docker hub

앞서 dockerfile로 만든 docker image를 관리할 저장소가 필요합니다.

로컬 registry를 사용해도 되고 docker hub를 사용해도 무관합니다.

그러나 보안, 네트워크 속도 issue로 로컬 registry를 사용하는 경우가 대부분입니다.

이번 예제에서는 간단하게 docker hub를 사용하겠습니다.







