//
//  AnniversaryUpdateRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import FavorKit

public struct AnniversaryUpdateRequestDTO: Encodable {
  public let anniversaryTitle: String
  public let anniversaryDate: String
  public let anniversaryCategory: String
  public let isPinned: Bool
  
  public init(
    anniversaryTitle: String,
    anniversaryDate: String,
    category: String,
    isPinned: Bool
  ) {
    self.anniversaryTitle = anniversaryTitle
    self.anniversaryDate = anniversaryDate
    self.anniversaryCategory = category
    self.isPinned = isPinned
  }
}
