# jeknins gitlab 연동

1.gitlab에서 gitlab과 개발환경을 연동했고 2.jenkins에서 kubernetes cluster와 jenkins간의 접근과 kubectl 사용권한에 대한 설정을 마무리 했습니다.

이제 gitlab과 jenkins를 연동하여 gitlab으로 소스코드를 push했을 때 jenkins POD를 통해 docker image build,push,pull를 진행하고 kubectl를 사용해서 CD를 진행할 수 있도록 설정하겠습니다.


## gitlab access token

gitlab에서는 access token을 발급해서 이를 가지고 있는 사용자가 gitlab에 접근할 수 있도록 합니다.

이 token을 jenkins에 부여해서 jenkins에서 소스코드를 읽어올 수 있도록 만들 것입니다.

우선 gitlab에 접속해보도록 하겠습니다.

```
<node ip>:30080 을 통해 gitlab에 접속합니다.
ex) 130.1.3.68:30080 
```

<img src="/images/CICD/73.jpg">

<img src="/images/CICD/74.jpg">

개발환경에서 연동한 project를 클릭합니다.

<img src="/images/CICD/75.jpg">

<img src="/images/CICD/76.jpg">

setting을 클릭해서 Access Tokens tab을 클릭합니다.

저는 Token Name : token_2021_03_30 , Expires at : 2022-03-30, Scopes는 모든 영역으로 설정했습니다.

access token : RDyHsKik9mzByyQX7SBi

<img src="/images/CICD/77.jpg">

<img src="/images/CICD/78.jpg">

이제 jenkins로 접속해서 이 token을 통해 gitlab과 연동해보겠습니다.

<img src="/images/CICD/83.jpg">

Manage jenkins -> Configure System

## 하루 뒤에 작성하느라, 재부팅을 했더니 IP가 130.1.3.79로 바뀌었습니다.

<img src="/images/CICD/84.jpg">

connection name : gitlab

Gitlab host URL : http://{node ip}:30080

그리고 Credentials의 Add를 눌러 Jenkins를 클릭합니다.

<img src="/images/CICD/85.jpg">

Kind를 GitLab API token, Scope는 Global, API token은 아까 gitlab에서 발급받은 access token을 입력하시면 됩니다.

ID와 Description은 편하신대로 작성하시면 됩니다.

저는 ID : jenkins-test, Descriptio : jenkins credentials로 설정했습니다.

<img src="/images/CICD/86.jpg">

방금 만든 Credentials를 추가한 뒤, Test connection을 누르면 success가 출력될 것입니다.

그리고 save를 해주시면 이후 pipeline을 만들 때 지금의 connection을 불러와서 사용할 수 있습니다.

이제 pipeline을 만들어보겠습니다.

<img src="/images/CICD/79.jpg">

<img src="/images/CICD/80.jpg">

이름은 편하신 걸로 정하시고 pipeline을 만들면 됩니다.

<img src="/images/CICD/81.jpg">

Advanced Project Options에서, definition을 Pipeline script from SCM으로 변경합니다.

SCM은 git으로 변경하고 Repository URL은 http://{node ip}:30080/{gitlab username}/{gitlab repository.git}으로 설정합니다. (SCM은 Software Configuration Management의 약어)

그리고 Credentials Add를 눌러 Jenkins를 클릭합니다.

<img src="/images/CICD/82.jpg">

Kind : Username with password, Username : 이전에 가입한 gitlab 계정, Password : gitlab 계정 암호

<img src="/images/CICD/88.jpg">

<img src="/images/CICD/89.jpg">

Credentials를 추가하면, 앞서 오류가 사라집니다.

그리고 SAVE를 하게 되면 다음과 같은 화면이 나옵니다.

<img src="/images/CICD/90.jpg">

gitlab과 연동은 되었으나 pipeline에 설정을 하지 않았기 때문에, 아무런 동작도 하지 않습니다.

저는 docker를 통해 소스코드를 image단위로 관리할 pipeline을 설계하고 있습니다.

그래서, dockerfile에 대한 부분은 다음 <a href="week5/CI-CD/4.dockerfile">4.dockerfile</a>에서 다루도록 하겠습니다.

또한 pipeline을 관리하는 jenkinsfile은 <a href="week5/CI-CD/5.jenkinsfile">5.jenkinsfile</a>에서 다루겠습니다.

## webhook

지금까지 개발환경과 gitlab을 연동했고, jenkins의 git repository를 gitlab으로 연결했습니다.

이제 필요한 것은, 개발환경에서 gitlab으로 push를 했을 때 jenkins가 그 사실을 알 수 있도록 해야 자동 CI / CD 가 이루어집니다.

이 과정은 webhook을 통해서 이루어집니다.

gitlab이 소스코드의 update를 인지하면 ( push ) 연결된 jenkins로 trigger를 발생시킵니다. ( webhook )

이 trigger를 받아 이후 작성할 jenkinsfile을 토대로 pipeline이 실행되는 것입니다.

우선 jenkins에서 trigger를 새롭게 설정하겠습니다.

jenkins 첫 페이지 -> cicd-test 클릭

<img src="/images/CICD/98.jpg">

Gitlab webhook URL: 값을 기억해둡니다.

저는 http://localhost:30303/project/cicd-test 입니다.

advanced 클릭한 뒤, Secret token generate

<img src="/images/CICD/99.jpg">

저의 secret token 값은 42e3e273d1b93e29ec1d895f696785dd 입니다.

이제 gitlab에서 project의 webhook설정을 바꾸겠습니다.

<img src="/images/CICD/100.jpg">

<img src="/images/CICD/101.jpg">

<img src="/images/CICD/102.jpg">

아까 발급받은 token과 URL을 입력한 뒤, Add webhook 클릭

<img src="/images/CICD/103.jpg">

localhost로 입력하니, 위와같은 에러가 발생합니다.

현재 주소인 130.1.3.79로 지정한 뒤 Add webhook을 클릭합니다.

클릭하게 되면, Project Hooks에 항목이 추가됩니다.

<img src="/images/CICD/104.jpg">

<img src="/images/CICD/105.jpg">

Push events를 누르고 jenkins 홈페이지로 가보면, pipeline이 실행되는 것을 알 수 있습니다.

<img src="/images/CICD/106.jpg">

이로써 jenkins와 gitlab 연동을 완료했습니다!


