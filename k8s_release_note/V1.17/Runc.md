## Runc?

runc는 container를 구성하는 low-level tool이다.

Docker, containerd, CRI-O는 runc위 level에서 구성된 것들이다.

kubernetes는 앞의 tool들 위에 구현된 것이다.



## 취약점

컨테이너에서 root(uid 0)으로 실행되는 process가 runc의 버그를 이용해서 root privilege를 얻을 수 있따.

이 권한을 통해 어디든 접속할 수 있는 상황이 된다.

그래서, 믿을만한 process나 root가 아닌 상태로 실행되는 process는 문제가 되지 않는다.

또한 적절한 policy를 적용해서 SELinux를 통해 위의 문제를 막을 수 있다.

주요 침입 경로는 public repo에 뿌려진 해커가 만든 검증되지 않은 image들이다.

## 해결방법

pod 배포시, spec.securityContext.runAsUser값을 0이 아닌 값으로 설정한다. ( root 권한 부여X )

혹은 PodSecurityPolicy를 이용한다.

``` yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: non-root
spec:
  privileged: false
  allowPrivilegeEscalation: false
  runAsUser:
    # Require the container to run without root privileges.
    rule: 'MustRunAsNonRoot'
```


p.s. PodSecurityPolicy는 v1.25+에서 deprecated된다.