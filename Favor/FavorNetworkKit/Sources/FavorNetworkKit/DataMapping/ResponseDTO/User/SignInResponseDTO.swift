//
//  SignInResponseDTO.swift
//  Favor
//
//  Created by 이창준 on 6/25/23.
//

public struct SignInResponseDTO: Decodable {
  public let token: String

  enum CodingKeys: CodingKey {
    case token
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.token = try container.decode(String.self, forKey: .token)
  }
}
