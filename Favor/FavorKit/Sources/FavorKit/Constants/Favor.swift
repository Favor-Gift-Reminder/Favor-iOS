//
//  Favor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

public enum Favor: String, CaseIterable {
  case simple = "심플한"
  case useful = "실용성있는"
  case cute = "귀여운"
  case sincere = "정성이담긴"
  case longUsing = "오래쓰는"
  case goodPriced = "가성비좋은"

  case goodVibe = "감성있는"
  case healthy = "건강에좋은"
  case trendy = "힙한"
  case goodQuality = "양보단질"
  case tasty = "맛있는"
  case pricey = "가격있는"

  case useless = "쓸데없는"
  case adorable = "아기자기한"
  case comforting = "위로가되는"
  case unique = "독특한"
  
  public var width: Int {
    return self.rawValue.count * 12
  }

  public static var allCases: [Favor] {
    return [
      .simple,
      .useful,
      .cute,
      .sincere,
      .longUsing,
      .goodPriced,
      .goodVibe,
      .healthy,
      .trendy,
      .goodQuality,
      .tasty,
      .pricey,
      .useless,
      .adorable,
      .comforting,
      .unique
    ]
  }
}
