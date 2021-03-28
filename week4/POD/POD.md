# POD
>
> kubernetes에서 POD란 무엇이고 어떤 방식으로 사용해야하는지에 대해 정리해봤습니다.
>

## POD란
>
> kubernetes에서, process를 관리하는 최소단위입니다.
>
> 실제 application이 실행되는 container를 POD라는 단위로 묶어서 관리하게 됩니다.
>
> POD가 생성될 때 cluster 내부의 CNI에서 요구하는 CIDR 대역폭의 unique한 private ip를 동적으로 할당받습니다.
>
> container는 본인이 속한 POD의 ip주소를 공유합니다.
>
> 그래서 POD는 container를 hosting하는 VM처럼 느껴집니다.
>
> {POD ip}:{container port} 를 통해 POD에서 실행중인 container에 접근할 수 있습니다.
>
> 그래서 하나의 POD에 여러 container가 실행되려면, 각기 다른 port를 사용해야합니다.
>
> 기본적으로 모든 traffic을 허용하기 때문에 cluster내부에서 NAT없이 다른 POD와 통신이 가능합니다.
>

## Details of POD

### POD lifecycle
>
> POD의 lifecycle는 pending 에서 Running로 진행되고, 내부 container의 상태에 따라 Succeeded 혹은 Failed상태로 종료됩니다.
>
> POD는 master node의 kube-scheduler의 명령에 의해 특정 node에 scheduling되고 그 node의 kubelet에 의해 실행되거나 종료됩니다.
>
> 이때 POD가 종료되거나 중지되기 전까지는 다른 node로 옮겨가지 않습니다.
> 

### POD STATUS
>
> POD는 총 6가지의 상태가 존재하며, 그에 대해 알아보겠습니다.
>
> #### Pending 
> 
> > POD가 아직 cluster에서 실행되기 전의 상태로, container가 실행준비가 되지 않은 상태입니다.
> >
> > scheduling이 아직 완료되지 않았거나 container image를 pull하고 있는 상황입니다.
>
> #### Running
>
> > POD가 node에 binding되고 모든 container가 준비되어 최소 하나의 container가 실행중인 상태입니다.
> >
>
> #### Succeeded
>
> > 모든 container가 success인채로 종료된 상황이며, 다시 실행되지 않습니다.
>
> #### Failed
>
> > 모든 container가 종료된 상황이고 최소 하나의 container는 failed인 상황입니다.
> >
> > container가 failed라는 것은 container가 0이 아닌 상태 혹은 시스템에 의해 종료된 상태입니다.
>
> #### Unknown
> 
> > POD가 실행중이던 node와의 통신이 끊겨 상태를 알 수 없는 상황입니다.
> >
> 
> #### crashloopbackoff, Error
>
> > POD가 실행되고난 뒤, 필요한 resource를 찾을 수 없을 때 발생하며, Error로 이어지게됩니다.
> >
> > container image를 가져오지 못했거나 환경 변수가 전달되지 않거나 volume이 제대로 mount되지 않은 상황입니다.


### POD : Ephemeral resource 
>
> 하지만, POD는 다양한 이유로 삭제되거나 재실행되기 때문에 cluster 내에서 ephemeral, 즉 임시 resource입니다. ( ephemeral의 반대 표현은 durable입니다. )
>
> 실행중인 POD가 삭제 혹은 재실행 되는 이유는 아래와 같습니다.
>
> > - resource부족 혹은 network issue로 인한  node의 장애
> >
> > - 새로운 node 추가
> >
> > - POD policy변화로 인한 rescheduling
> >
> > - container image update를 위한 재배포
> >
> > - POD replica scaling
>
> 이러한 이유로 전체 solution을 안정적으로 유지하기위해 다른 resource를 추가적으로 사용합니다.
>
> ( volume, service...)
>

### The architecture of application
>
> 기존의 코딩 방식은 여러 function을 작성한 뒤, parameter passing방식으로 전체 process를 진행했습니다.
> 
> 이는 전체 function이 memory를 공유하는 구조에서 이루어집니다.
>
> 이런 방식으로 container image를 만드는 경우 하나의 container에서 모든 application의 기능을 담당해야합니다.
>
> container.md에서 언급했듯 container에 여러 process가 포함되면 해당 container의 상태를 알기 어려워 관리가 힘들어집니다.
> 
> 그래서, application을 설계할 때 container image를 function단위로 만든 뒤, network를 통해 parameter를 넘겨주는 MSA 방식으로 구현해야합니다.
>
> 이때 POD를 VM처럼 생각하여 방금 설계한 모든 container를 실행하면, POD가 삭제되거나 재실행될 때 전체 service down time이 발생합니다. 
>
> 그래서 이와 같은 architecture는 바람직하지 않고 하나의 POD에 하나의 function을 담당하는 container를 실행시키는 것이 적절합니다.
>

