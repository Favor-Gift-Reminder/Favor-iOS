#  Models

앱 내부에서 사용되는 데이터 모델을 정의하는 디렉토리입니다.

``` Swift
struct User: Codable {
  let id: String
  let name: String
}
```

Realm을 사용하는 데이터일 경우 아래와 같이 정의할 수 있습니다.

``` Swift
import RealmSwift

class User: Object, Codable {
  @Persisted var name: String
  @Persisted var id: String

  private enum CodingKeys: String, CodingKey {
    case name
    case id = "userID"
  }

  // Decode
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
  }

  // Encode
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.id, forKey: .id)
  }
}
```
