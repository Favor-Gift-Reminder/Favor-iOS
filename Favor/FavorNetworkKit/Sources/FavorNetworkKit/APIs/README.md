#  API

API request, response와 관련된 코드들을 모아두는 디렉토리입니다.

### 예시
`BaseTargetType`을 준수하는 enum 타입을 구현합니다.
UserAPI.swfit
UserAPI+Path.swift
UserAPI+Method.swift
UserAPI+Task.swift

```
enum FriendAPI: BaseTargetType { 
  case getFriend
  case getAllFriend
  case deleteFriend
  case patchFriend
  case postFriend
  case postUserFriend
}
```
