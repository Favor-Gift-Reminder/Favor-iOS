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
  
  /// `OnboardingVC`에서 사용하는 `UpdateHandler`입니다.
  static func onboardingHandler(_ index: Int) -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      
      switch index {
      case 0...1:
        updateAttributes(
          button,
          title: "다음",
          font: .favorFont(.bold, size: 18),
          backgroundColor: .favorColor(.box1),
          foregroundColor: .favorColor(.typo)
        )
      default:
        updateAttributes(
          button,
          title: "계속하기",
          font: .favorFont(.bold, size: 18),
          backgroundColor: .favorColor(.typo),
          foregroundColor: .favorColor(.white)
        )
      }
    }
    
    return handler
  }
}

private extension UpdateHandlerManager {
  static func updateAttributes(
    _ button: UIButton,
    title: String = "",
    font: UIFont,
    backgroundColor: UIColor,
    foregroundColor: UIColor
  ) {
    button.configuration?.baseBackgroundColor = backgroundColor
    
    if !title.isEmpty {
      var newContinaer = AttributeContainer()
      newContinaer.foregroundColor = foregroundColor
      newContinaer.font = font
      button.configuration?.attributedTitle = AttributedString(title, attributes: newContinaer)
    } else {
      button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.foregroundColor = foregroundColor
        
        return outgoing
      }
    }
  }
}
