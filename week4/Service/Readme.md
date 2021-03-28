# Service
  The spokesperson for the POD.
## Service란
> 
> Kubernetes의 철학은 사용자가 더 이상 container에 신경쓰지 않도록 하는 것입니다.
>
> 앞서 week4/POD/POD.md에서 언급했듯 하나의 POD가 하나의 기능을 담당하도록 하는 것이 적절합니다.
>
> 각 POD는 서로 memory를 공유하지 않기 때문에 network를 통한 parameter passing이 필요합니다.
>
> POD의 ip 가 가변적이기 때문에 POD의 ip를 통한 통신은 적절하지 않습니다.
> 
> 유동적인 POD의 ip를 대신해서 사용하기 위한 것이 바로 Service입니다.
> 
> Service는 selector를 통해 POD에 부여된 label을 확인하고 Endpoint POD를 찾아다닙니다.
>
> POD의 ip가 바뀌어도 label은 바뀌지 않기 때문에 Endpoint는 사용자가 지정한 POD를 가리키고 있습니다.
>
> 또한 Port forwarding방식으로 이루어 지기 때문에 POD내부 container로 바로 연결할 수 있습니다.

## Service 종류
>
> Service는 크게 3가지가 존재합니다.
>
> > 1. Clusterip
> > >
> > > Service의 Default형태로, cluster 내부 통신만 가능합니다.
> > >
> > 2. NodePort
> > >
> > > Cluster내부에 포함된 모든 Node의 특정 Port를 사용하는 것으로, 외부 통신이 가능합니다.
> > >
> > > <Node ip>:<NodePort> 로 외부에서 접근이 가능합니다.
> > >
> > 3. Loadbalancer
> > >
> > > Cloud vendor의 Loadbalancer를 사용하여, 외부와의 통신을 가능하게 합니다.
> > >

## Service default dns
>
> Service가 만들어지면 삭제되기 전까지 cluster내부의 한 ip를 영구적으로 사용합니다.
>
> 하지만 할당받는 ip는 가변적이기 때문에 hard coding으로 통신하기에는 부적절합니다.
> 
> 이를 위해 service는 아래와 같은 default domain name을 가집니다.
> 
> <service name>.<namespace>.svc.cluster.local:<port>
>
>
