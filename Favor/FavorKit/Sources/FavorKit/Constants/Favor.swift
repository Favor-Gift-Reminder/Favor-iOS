//
//  Favor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

public enum Favor: String, CaseIterable {
  case simple = "심플한"
  case useful = "실용성 있는"
  case cute = "귀여운"
  case sincere = "정성이 담긴"
  case longUsing = "오래 쓰는"
  case goodPriced = "가성비 좋은"

  case goodVibe = "감성 있는"
  case healthy = "건강에 좋은"
  case trendy = "힙한"
  case goodQuality = "양보단 질"
  case tasty = "맛있는"
  case pricey = "가격 있는"

  case useless = "쓸데없는"
  case adorable = "아기자기한"
  case comforting = "위로가 되는"
  case unique = "독특한"
  case empty1 = "호호호"
  case empty2 = "하하하"

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
      .unique,
      .empty1,
      .empty2
    ]
  }
}
