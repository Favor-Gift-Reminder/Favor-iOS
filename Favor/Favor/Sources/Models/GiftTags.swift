//
//  GiftTags.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import FavorKit

public enum GiftTags {
  case emotion
  case category(FavorCategory)
  case isGiven(Bool)
  case friends([Friend])
}
