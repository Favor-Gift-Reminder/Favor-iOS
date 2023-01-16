//
//  UpdateHandlerManager.swift
//  Favor
//
//  Created by 김응철 on 2023/01/16.
//

import UIKit

enum UpdateHandlerManager {
  
  /// UIButton의 state에 따라 배경색과 텍스트 색을 바꾸는 `UpdateHandler`를 생성하여 반환합니다.
  static func disabled() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
          var newAttr = attr
          newAttr.foregroundColor = .favorColor(.white)
          
          return newAttr
        }
        button.configuration?.baseBackgroundColor = .favorColor(.typo)
        
      case .disabled:
        button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
          var newAttr = attr
          newAttr.foregroundColor = .favorColor(.typo)
          
          return newAttr
        }
        button.configuration?.baseBackgroundColor = .favorColor(.box1)
      default:
        break
      }
    }
    return handler
  }
}
