//
//  AnniversaryType.swift
//  
//
//  Created by 김응철 on 2023/05/23.
//

import UIKit

public enum AnniversaryCategory: CaseIterable {
  case couple
  case congrat
  case gradu
  case pass
  case employ
  case house
  case birth
  
  public var text: String {
    switch self {
    case .birth: return "출산"
    case .congrat: return "축하/생일"
    case .couple: return "연인"
    case .gradu: return "졸업"
    case .employ: return "입사/승진"
    case .pass: return "합격"
    case .house: return "이사/집들이"
    }
  }
  
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
