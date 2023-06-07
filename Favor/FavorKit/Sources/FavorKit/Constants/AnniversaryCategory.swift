//
//  AnniversaryType.swift
//  Favor
//
//  Created by 김응철 on 2023/05/23.
//

import UIKit

public enum AnniversaryCategory: String, CaseIterable {
  case couple = "연인"
  case congrat = "축하/생일"
  case gradu = "졸업"
  case pass = "합격"
  case employ = "입사/승진"
  case house = "이사/집들이"
  case birth = "출산"
  
  public var image: UIImage? {
    switch self {
    case .birth:
      return .favorIcon(.birth)
    case .congrat:
      return .favorIcon(.congrat)
    case .couple:
      return .favorIcon(.couple)
    case .employ:
      return .favorIcon(.employed)
    case .gradu:
      return .favorIcon(.graduate)
    case .house:
      return .favorIcon(.housewarm)
    case .pass:
      return .favorIcon(.pass)
    }
  }
}
