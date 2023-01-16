//
//  ValidateManager.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import Foundation

enum ValidateManager {
  
  enum Email {
    case empty
    case invalid
    case valid
    
    var description: String {
      switch self {
      case .empty, .valid:
        return ""
      case .invalid:
        return ""
      }
    }
  }
  
  enum Password {
    case empty
    case invalid
    case valid
    
    var description: String{
      switch self {
      case .empty, .valid:
        return ""
      case .invalid:
        return ""
      }
    }
  }
  
}
