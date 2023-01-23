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
  
  static func onboardingHandler(_ index: Int) -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      
      var newContainer = AttributeContainer()
      newContainer.font = .favorFont(.bold, size: 18)
      
      switch index {
      case 0...1:
        newContainer.foregroundColor = .favorColor(.typo)
        button.configuration?.baseBackgroundColor = .favorColor(.box1)
        button.configuration?.attributedTitle = AttributedString("다음", attributes: newContainer)
      default:
        newContainer.foregroundColor = .favorColor(.white)
        button.configuration?.baseBackgroundColor = .favorColor(.typo)
        button.configuration?.attributedTitle = AttributedString("계속하기", attributes: newContainer)
      }
    }
    
    return handler
  }
}
