//
//  AnniversaryResponseDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

import FavorKit

public struct AnniversarySingleResponseDTO: Decodable {
  public let anniversaryDate: Date
  public let anniversaryNo: Int
  public let anniversaryTitle: String
  public let anniversaryCategory: AnniversaryCategory
  public let isPinned: Bool
  public let userNo: Int
  
  private enum CodingKeys: CodingKey {
    case anniversaryDate
    case anniversaryNo
    case anniversaryTitle
    case anniversaryCategory
    case isPinned
    case userNo
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let anniversaryDateString = try container.decode(String.self, forKey: .anniversaryDate)
    let anniversaryDate = anniversaryDateString.toDate("yyyy-MM-dd")
    self.anniversaryDate = anniversaryDate ?? .distantPast
    self.anniversaryNo = try container.decode(Int.self, forKey: .anniversaryNo)
    self.anniversaryTitle = try container.decode(String.self, forKey: .anniversaryTitle)
    self.anniversaryCategory = try container.decode(AnniversaryCategory.self, forKey: .anniversaryCategory)
    self.isPinned = try container.decode(Bool.self, forKey: .isPinned)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
  }
}
