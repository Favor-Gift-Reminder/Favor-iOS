//
//  ErrorResponseDTO.swift
//  Favor
//
//  Created by 이창준 on 6/25/23.
//

import Foundation

public struct ErrorResponseDTO: Decodable {
  public let responseCode: String
  public let responseMessage: String

  enum CodingKeys: String, CodingKey {
    case responseCode = "ResponseCode"
    case responseMessage = "ResponseMessage"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.responseCode = try container.decode(String.self, forKey: .responseCode)
    self.responseMessage = try container.decode(String.self, forKey: .responseMessage)
  }
}
