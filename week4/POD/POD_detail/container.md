# Container

kubernetes가 등장하게 된 근본적인 이유인 container에 대해 알아봤습니다.

## Container 등장 배경
>
> 기존에는 application을 개발하기 위해 Baremetal에 개발환경을 구축했습니다. 
> 
> 또한 beta test를 위한 환경도 위와 같이 구성했습니다.
> 
> 새로운 환경을 구축하려면 기존 환경을 초기화하거나 혹은 적절한 업그레이드를 진행해야합니다.
> 
> 이는 상당히 많은 시간과 노력을 투자해야하는 작업이지만 효용은 그다지 높지 않습니다.
> 
> 시대의 흐름을 읽고 필요한 application을 빠르게 개발해야하는 IT업계의 특성상 구조적인 혁신이 필요하게 되었습니다.
>
> 필요한 환경을 빠르게 구축하고, 필요 없어지면 삭제할 수 있는 그러한 기술을 요구하게 되었고 Virtual Machine이 등장하게 되었습니다.
> 
> Virtual Machine은 host machine위에 hypervisor -> guest os를 쌓아 구축한 가상환경으로 기존 방식보다 빠르게 환경구축이 가능하지만 host os -> hypervisor -> guest os 라는 비효율적인 구조를 가지고 있습니다.
>
> 그래서 VM보다 더 경량화된 container가 등장하게 됩니다.
>

## Container 개념
>
> container는 host os의 kernel을 공유하는 방식으로 실행됩니다.
>
> linux의 namespace를 통해 격리된 공간을 제공받아 원하는 환경을 구축할 수 있습니다.
>
> 또한 guest os가 없기 때문에 container runtime위에서 가볍게 실행될 수 있다는 장점이 있습니다.
>
> 다양한 container runtime이 존재하지만, kubernetes에서 주로 사용하는 Docker에 대해서만 다루도록 하겠습니다.
>

## Docker ( container runtime )
>
> Docker는 가장 유명한 container runtime입니다. ( Google에서 밀어주는 kubernetes에 사용되기 때문입니다...)
>
> container에서 실행될 application을 image라는 단위로 관리합니다.
>
> 필요한 resource와 library 혹은 다른 image들을 가져와서 build를 통해 image로 만들고, 이를 registry에 push하고, 필요시 pull하는 방법으로 진행됩니다.
>
> image registry는 크게 docker hub와 private registry로 나뉩니다.
>
> docker hub는 인터넷이 연결된 곳이라면 어디서든 이용이 가능하고, private registry는 credential을 가진 사용자만 접근할 수 있습니다.
>
> 다음은 Docker container의 network에 대해 알아보겠습니다.
>

## Network of Docker
>
> Docker의 network는 docker0라는 network interface에 virtual network interface가 bridge형태로 연결된 형태입니다.
>
> container가 생성되면 linux namespace라는 isolated network space를 할당받게 됩니다.
>
> 이 namespace에서 container가 외부와 통신을 하기 위해 container의 network interface가 docker0에 연결된 virtual network  interface와 1대1로 연결됩니다.
> 
> 이때 container의 gateway역할을 하는 것이 docker0입니다.
>
> 결국 container는 docker0를 거쳐 외부와 통신하게됩니다.
> 
> 외부에서는, container의 network interface는 보이지 않고 docker0와 virtual network interface만 보이게 됩니다.
>

## Container 설계하기
>
> container는 격리된 공간과 network interface를 제공받기 때문에, 하나의 VM처럼 다룰 수 있습니다.
>
> 하나의 VM처럼 다룬다는 의미는 하나의 image에 여러가지 기능을 넣는 것을 말합니다. ( web / db / log 를 하나의 container에서 실행)
>
> 허나 이는 바람직하지 않은 architecture입니다.
>
> container를 하나의 VM처럼 구축했을 때의 단점은 크게 2가지가 있습니다.
>
> ### POD health check
> >
> > POD의 상태 체크를 하는 kubelet은 내부 container의 상태를 통해 결정합니다.
> >
> > 만약 container에서 다양한 application이 실행중이라면 container의 상태를 파악하기 어려울 것입니다. ( 일부 app은 종료되고 나머지 app만 실행 중인 상황 )
> >
> ### Container update의 어려움
> >
> > image의 update를 진행하는 경우, container가 재실행되어야합니다.
> >
> > 여러가지 app이 하나의 container에서 실행중이라면 재실행되는 동안, 전체 solution의 down time이 발생하게됩니다.
> >
>
> 위와 같은 이유로, container에는 한가지 기능을 하는 image를 실행시키는 것이 바람직합니다.
>

## Docker image layer
>
> docker를 통해 container의 image를 만드는 경우, caching기능을 이용할 수 있습니다.
>
> Dockerfile의 각 line은 하나의 layer로 취급하는데, docker는 image build를 할 때 각 layer를 caching합니다.
>
> layer가 이전과 다른 경우, 새롭게 build를 진행하고 그렇지 않으면 caching을 이용합니다.
>
> 그래서 자주 바뀌는 부분을 마지막 layer에 두는 것이 효과적입니다.
>
> 다음은 Dockerfile의 예시입니다.
>
> <img src="/images/POD/container1.JPG" >
>
> 이상태에서, 처음 build를 하게 되면 꽤 오랜시간이 걸립니다.
>
> 그러나, Dockerfile을 수정하지 않고 build를 다시 진행하게 되면 모든 layer에서 caching이 진행되어 빠르게 처리됩니다.
>
> <img src="/images/POD/container2.JPG" >
>
> <img src="/images/POD/container3.JPG" >
>
> 22개의 layer가 모두 caching된 모습입니다.
>
> 여기서, 3번째 layer를 수정하게되면 4~22 layer를 다시 build해야합니다.
>
> <img src="/images/POD/container4.JPG" >
> 
> 2번 layer는 caching이 되었지만 그 이후로는 새롭게 build하는 모습입니다.
> 
> 즉, 자주 변경되는 부분은 최대한 마지막 layer에 배치하는 것이 유리합니다.
>
> 
