
## DataMapping

서버로부터 받는 데이터들을 앱 내부에서 사용할 수 있는 데이터로 변환하는 DTO(Data Transfer Object)를 모아둡니다.

- enum을 기준으로 중첩 타입(Nested Type)을 이용합니다.
- 중첩 타입안에 있는 `struct`는 `부사 + 명사`의 조합으로 네이밍을 합니다.

- 전체 조회는 명사 앞에 `All`이 들어갑니다.
