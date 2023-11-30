//
//  GiftResponseDTO.swift
//
//
//  Created by 김응철 on 10/29/23.
//

import Foundation

public struct GiftResponseDTO: Decodable {
  public let giftNo: Int
  public let giftName: String
  public let giftDate: Date
  public let photoList: [PhotoResponseDTO]
  
  enum CodingKeys: CodingKey {
    case giftNo
    case giftName
    case giftDate
    case photoList
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.giftNo = try container.decode(Int.self, forKey: .giftNo)
    self.giftName = try container.decode(String.self, forKey: .giftName)
    let giftDateString = try container.decode(String.self, forKey: .giftDate)
    let giftDate = giftDateString.toDate("yyyy-MM-dd")
    self.giftDate = giftDate ?? .distantPast
    self.photoList = try container.decode([PhotoResponseDTO].self, forKey: .photoList)
  }
}
