# Volume

### Volume 등장 배경
>
> container의 경우 image기반으로 실행되기 때문에 실행도중 변경사항이 발생해도, 재실행되면 다시 초기화됩니다.
>
> stateless 작업의 경우 문제가 없지만 DB와 같이 stateful 작업에는 치명적인 문제입니다.
> 
> 그래서 등장한 것이 Volume입니다.
>
> Volume은 POD로 mount되며 각 container에 mountPath를 지정하여 원하는 위치로 mount할 수 있습니다.

### Volume 종류
>
> Volume에는 크게 3가지가 있습니다.
>
> 1. emptydir
>
>
>
> 2. hostpath
>
>
>
>
> 3.  NFS
>
>
>
>

### Volume 세부사항
>
> #### 1. emptydir
> 
> >
> > 이름에서 알 수 있듯 초기화된 volume이고, host node의 volume을 사용합니다.
> >
> > POD와 같은 생명주기를 가집니다. POD가 생성될 때, 초기화된 상태로 POD에 mount되고 POD가 종료되면 초기화되어 사라집니다.
> > 
> > 즉, 메모리와 같은 휘발성을 띄는 volume이기 때문에 storage용도로 사용하는 건 부적절합니다.
> > 
> > 연산작업을 위한 공간으로 사용하는 것이 적절합니다.
> > 
> 
> #### 2. hostpath
> 
> >
> > emptydir와 같이 host node의 volume을 사용합니다.
> >
> > 다만, POD와 독립적인 생명주기를 가지기 때문에 POD가 종료되더라도 초기화 되지 않고 데이터가 유지됩니다.
> >
> > host node의 volume을 사용하기 때문에 POD가 다른 node로 옮겨가게 된다면 기존 데이터를 사용하지 못하게 됩니다.
> >
> > 그래서 nodeSelector나 affinity를 함께 사용하는 것이 적절합니다.
> >
> 
> #### 3. NFS
> 
> > 
> > 물리적인 host node의 volume이 아닌, network로 연결된 volume을 사용합니다.
> > 
> > POD가 다른 node에서 실행되어도 file system의 변경이 없다면 동일한 volume을 사용할 수 있습니다.
> > 
> > cloud를 이용하는 경우, 해당 provider의 file system을 사용하는 것이 일반적입니다.
> > 
> > network 대역폭에 따라 성능이 좌우되는 단점이 존재합니다.
> > 
> > 

### TEST

각 테스트는 emptydir, hostpath, NFS directory에서 확인하시기 바랍니다.

