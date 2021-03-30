# NODE

POD를 scheduling할 때, 어떤 NODE에서 실행할지 혹은 못하게 할지를 설정하는 방법에 대해 알아보겠습니다.

POD는 사용자가 직접 재실행시키거나, resource부족, node의 network문제로 인해 POD는 재실행됩니다.

이때 POD는 한번 scheduling되면 재실행되기 전까지 다른 node로 옮겨가지 않습니다.

중요한 혹은 민감한 데이터가 한 node에만 저장되어 있는 상황이거나 resource를 많이 잡아먹는 POD거나 public cloud를 사용할 때 특정 node만 외부와 통신할 수 있는 상황이라면 POD는 특정 node에서만 실행되어야 하는 경우가 있습니다.

POD를 강제적으로 특정 node로 scheduling하는 방법은 크게 3가지가 있습니다.

1. nodeSelector

2. nodeName

3. affinity

반대로 특정 node에서 실행되지 못하도록 설정해야하는 경우도 있습니다.

중요한 내부자료