
## DataMapping

서버로부터 받는 데이터들을 앱 내부에서 사용할 수 있는 데이터로 변환하는 DTO(Data Transfer Object)를 모아둡니다.

``` Swift
struct UserDTO: Codable {
	private let id: String
	private let name: String
	
	private enum CodingKeys: String, CodingKey {
		case id
		case name = "username"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
	}
}

extension UserDTO {
	func toDomain() -> User {
		User(
			id: self.id,
			name: self.name
		)
	}
}
```
