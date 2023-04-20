//
//  File.swift
//  
//
//  Created by 이창준 on 2023/04/19.
//

public struct UserUpdateRequestDTO: Encodable {
  let name: String
  let userID: String
  let favorList: [String] // [Enum]

  private enum CodingKeys: String, CodingKey {
    case name
    case userID = "userId"
    case favorList
  }

  public init(
    name: String,
    userID: String,
    favorList: [String]
  ) {
    self.name = name
    self.userID = userID
    self.favorList = favorList
  }
}
