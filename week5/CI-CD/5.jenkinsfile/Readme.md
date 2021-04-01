# jenkinsfile

### configure the pipeline

jenkinsfile은 pipeline를 관리하는 파일입니다.

stage단위로 전체 pipeline의 흐름을 관리합니다.

자세한 건 코드를 보며 설명하겠습니다.

``` yaml
def DOCKER_IMAGE_NAME = "wotkddl21"           // 본인 docker hub 계정
def DOCKER_IMAGE_TAGS = "cicd-test"  // 설정하고자 하는 tag  주로 def tag = "tag"+new Date();로 설정
def NAMESPACE = "cicd-space"
def DATE = new Date();
  
podTemplate(
    label: 'builder',
            containers: [
                containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
                containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:latest', command: 'cat', ttyEnabled: true)
            ],
            volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
            ]) 
{
    node('builder') {
        stage('Checkout') {
             checkout scm   // gitlab으로부터 소스 다운
        }
        stage('Docker build') {
            container('docker') {
                withCredentials([usernamePassword(
                    credentialsId: 'docker_hub_auth',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD')]) {
                        /* jenkins에 등록된 credentialsId 를 통해 docker account 접근 */
                        sh "docker build -t ${DOCKER_IMAGE_NAME}/${DOCKER_IMAGE_TAGS} ."
                        sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "docker push ${DOCKER_IMAGE_NAME}/${DOCKER_IMAGE_TAGS}"
                }
            }
        }
        stage('Run kubectl') {
            container('kubectl') {
                withCredentials([usernamePassword(
                    credentialsId: 'docker_hub_auth',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD')]) {
                        /* namespace 존재여부 확인후, 없다면 namespace 생성 */
                        sh "kubectl get ns ${NAMESPACE}|| kubectl create ns ${NAMESPACE}"

                        /* secret 존재여부 확인. 미존재시 secret 생성 */
                        sh """
                            kubectl get secret my-secret -n ${NAMESPACE} || \
                            kubectl create secret docker-registry my-secret \
                            --docker-server=https://index.docker.io/v1/ \
                            --docker-username=${USERNAME} \
                            --docker-password=${PASSWORD} \
                            --docker-email=jaesang.park@samyang.com \
                            -n ${NAMESPACE}
                        """
                        /* yaml파일에 변화가 없다면 새롭게 배포하지 않기 때문에 수정내역을 반영하려면 yaml파일에 변화를 줘야한다. */
                        /* k8s-deployment.yaml에서, env.value의 값을 수정 */
                        /* value : 'DATE' */
                        sh "echo ${DATE}"
                        /* value: 를 value: '${DATE}' 값으로 변경*/
                        sh "sed -i \"s/value:.*/value: '${DATE}'/g\" ./k8s/deployment.yaml"
                        
                        sh "kubectl apply -f ./k8s/deployment.yaml -n ${NAMESPACE}"
                        sh "kubectl apply -f ./k8s/service.yaml -n ${NAMESPACE}"
                    }
                }
            }
        }
    }
    
```

이는 전체 Jenkinsfile이고, 전체 흐름을 먼저 보고 세부적인 내용을 다루겠습니다.

podTemplate을 먼저 선언하고, node('builder')의 stage 3가지 ( Checkout, Docker build, Run kubectl )를 정의했습니다.

### podTemplate
> 
> 각 containerTemplate을 보시면 name을 정의했습니다.
> 
> 이는 이후 container를 지정할 때 사용하게 됩니다. ( ex : container('docker'))
> 
> 그 다음 container에서 사용할 image (docker,lachlanevenson/k8s-kubectl:latest)를 정의했습니다.
> 
> 각 image에 대해 설명해드리겠습니다.
> 
> #### image: docker 
> > 
> > docker command를 사용할 수 있는 container입니다. 이곳으로 소스코드를 복사해서 docker build, push를 진행할 예정입니다.
> > 
> #### image: lachlanevenson/k8s-kubectl:latest
> > 
> > 우선, latest의 의미는 가장 최신 버전을 사용하겠다는 의미입니다.
> > 
> > 새로운 버전의 image를 저장하려면 기존 tag에 덮어 써도 되지만, 이는 재사용성이 떨어지므로 새로운 tag를 붙여 image를 관리하게 됩니다.
> > 
> > 신규 tag가 추가될 때마다 이 가져올 image tag를 수정하는 것은 비효율적입니다.
> > 
> > 그래서 latest는 docker에서 제공해주는 기능 중 하나로, pull명령어를 실행하는 순간 가장 최근 버전의 image를 > 가져옵니다.
> > 
> > 이 image로 container를 실행하명 kubectl 명령어를 사용할 수 있습니다.
> > 
> > docker image를 push하고, kubernetes cluster에 배포할 때 사용됩니다.
> > 
> > 
> > 마지막으로 volume이 mount될 위치를 지정했습니다.
> > 
> > containerTemplate는 2개인데, volume은 1개만 정의되어있습니다.
> > 
> > 이렇게 되면 첫 번째 container에만 volume이 mount됩니다.
> > 
> > 이때 volume을 보면 /var/run/docker.sock 인데, 이는 Docker daemon이 항상 바라보고 있는 곳입니다.
> > 
> > docker command를 사용하기 위해서, 이 volume이 있어야합니다.
> > 
> ### builder
> > 
> > build단계에서 3가지 stage를 선언했습니다.
> > 
> > 1. Checkout
> > > 
> > > 명령어를 보면 아시겠지만 checkout scm 입니다.  이는, 앞서 jenkins의 scm을 gitlab으로 연동해놨기 때문에 새롭게  push된 소스코드를 gitlab으로 부터 가져오는 stage입니다.
> > > 
> > 2. Docker build
> > > 
> > > checkout stage에서 가져온 소스코드를 바탕으로 build가 진행되는 stage입니다.
> > > 
> > > 앞서 podTemplate의 containerTemplate에서 'docker'라고 정의한 container에 대한 설정입니다.
> > > 
> > > <a href="week5/CI-CD/4.dockerfile">4.dockerfile</a>에서 설정한 docker credential을 이용하는 모습입니다.
> > > 
> > > 이 credential을 통해 이후 docker push를 위한 권한 인증을 진행하게 됩니다.
> > > 
> > > 이 과정이 끝나면, 사용자가 push한 소스코드가 docker image가 되어 registry로 push됩니다.
> > > 
> > 3. Run kubectl
> > > 
> > > 마지막으로 배포가 이루어지는 stage입니다.
> > > 
> > > 여기는 배경지식이 많이 필요합니다. 차근차근 살펴보겠습니다.
> > > 
> > > ##### image pull
> > > > 
> > > > kubectl을 통해서, POD를 배포할 때 container image가 필요합니다.
> > > > 
> > > > 이 image가 local에 존재한다면 무리가 없지만, 지금 상황은 2. Docker build 에서 hub로 image를 push한 > > > 상태입니다.
> > > > 
> > > > 이를 가져오기 위해서 docker username, password를 통한 인증과정을 거쳐야합니다.
> > > > 
> > > > kubernetes에서는 위 인증과정을 docker-registry라는 secret resource를 통해  진행할 수 있습니다.
> > > > 
> > > > registry server의 주소와 username, password 정보를 가지고 만들 수 있습니다.
> > > > 
> > > > 이 username, password는 <a href="week5/CI-CD/4.dockerfile">4.dockerfile</a>에서 설정한 credentials에서 참조해올 수 있습니다.
> > > > 
> > > > 
> > > ##### POD 재배포
> > > > 
> > > > POD에서 사용되는 container image를 2. docker build에서 만든 image로 업데이트 하는것이 우리의 목표입니다.
> > > > 
> > > > 이 경우 방법은 크게 2가지가 있습니다.
> > > > 
> > > > ###### 1. latest
> > > > >
> > > > > 앞서 kubectl image에 latest를 붙인 것처럼, 항상 최신 tag가 붙은 image를 사용합니다.
> > > > > 
> > > > > 이렇게 하고 싶다면, 2. docker build단계에서, tag부분을 build할 때마다 바뀌도록 설정해야 합니다. ( 보통 date를 사용하거나, 기존 version에서 +1 된 숫자를 사용합니다. )
> > > > > 
> > > > > 
> > > > ###### 2. edit yaml
> > > > > 
> > > > > yaml파일이 변경된 경우, POD의 재배포가 이루어집니다.
> > > > > 
> > > > > 제가 진행한 방식은 이 방식입니다.
> > > > > 
> > > > > 2. docker build를 보면 docker image의 tag값을 변경시키지 않고 계속해서 덮어 쓰는 방식으로 push를 진행합니다.
> > > > > 
> > > > > yaml파일의 변화가 없다면 image가 변경되어도, 애초에 config unchanged라는 출력과 함께 아무런 변화도 일어나지 않습니다.
> > > > > 
> > > > > 그래서 yaml파일에 환경변수를 추가했고, 이 환경변수에 jenkinsfile이 실행되는 시간을 기록했습니다.
> > > > > 
> > > > > 그러면 사용자가 code push를 하고 pipeline이 실행되고 이 때의 시간이 yaml파일에 기록되면서 항상 재배포가 이루어집니다.
> > > > > 
> > > > > sed라는 linux 명령어를 활용해서, env의 value부분을 ${DATE}로 변경하는 모습입니다.
> > > > > 
> > > > > DATE의 경우, new DATE();라는 java 함수값으로 정의됩니다. ( jenkins가 java를 기반으로 작성되었기 때문에 java 함수를 사용할 수 있습니다. )
> > > > >


이제 POD를 배포하기 위한 yaml과 POD를 외부로 노출시키기 위한 yaml을 작성해야 합니다.

제 project를 따라하셨다면, k8s 디렉토리에 deployment.yaml과 service.yaml을 사용하시면 됩니다.

다른 project를 연동하신다면 제 yaml을 참고해서 작성하시면 됩니다.

이제 테스트를 진행해보겠습니다.

개발환경에서, git push를 진행해보겠습니다.

```shell

git push -u origin --tags
```
<img src="/images/CICD/107.jpg">

<img src="/images/CICD/114.jpg">

push를 하니, jenkins에서 pipeline이 실행됩니다.

<img src="/images/CICD/115.jpg">

실행중인 pipeline의 상황을 보겠습니다.

<img src="/images/CICD/116.jpg">

console output 클릭

<img src="/images/CICD/117.jpg">

어느 정도 시간이 지난 뒤, SUCCESS라는 출력과 함께 pipeline이 종료되었습니다.

이제 kubernetes cluster에서, cicd-space namespace의 POD와 service를 확인해보겠습니다.

```shell
kubectl get svc -n cicd-space
kubectl get pod -n cicd-space
```

<img src="/images/CICD/119.jpg">

<img src="/images/CICD/120.jpg">

POD와 service가 정상적으로 동작하고 있습니다.

이제 실제로 접속해보겠습니다.

localhost:31111   ( localhost가 아닌, node의 ip로 접근하면 kakao 지도 api가 연동이 되지 않으니 localhost로 진행하셔야합니다. )

kubernetes cluster의 모든 node에서 접근이 가능합니다.

<img src="/images/CICD/118.jpg">






