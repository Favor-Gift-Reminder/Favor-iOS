//
//  AnniversaryType.swift
//  Favor
//
//  Created by 김응철 on 2023/05/23.
//

import UIKit

public enum AnniversaryCategory: String, CaseIterable, Hashable, Codable {
  case couple = "연인"
  case congrat = "축하_생일"
  case gradu = "졸업"
  case pass = "합격"
  case employ = "입사_승진"
  case house = "이사_집들이"
  case birth = "출산"
  
  var string: String {
    switch self {
    case .couple: "연인"
    case .congrat: "축하/생일"
    case .gradu: "졸업"
    case .pass: "합격"
    case .employ: "입사/승진"
    case .house: "이사/집들이"
    case .birth: "출산"
    }
  }
  
  public var image: UIImage? {
    switch self {
    case .birth:
      return .favorIcon(.baby)
    case .congrat:
      return .favorIcon(.congrat)
    case .couple:
      return .favorIcon(.couple)
    case .employ:
      return .favorIcon(.employed)
    case .gradu:
      return .favorIcon(.gradu)
    case .house:
      return .favorIcon(.housewarm)
    case .pass:
      return .favorIcon(.pass)
    }
  }
}
