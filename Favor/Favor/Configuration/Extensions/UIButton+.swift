//
//  UIButon+.swift
//  Favor
//
//  Created by 이창준 on 2023/01/06.
//

import UIKit

// MARK: - UIButton

extension UIButton {
  
  /// UIButton의 state에 따라 배경색과 텍스트 색을 바꾸는 `UpdateHandler`를 생성하고 할당합니다.
  func makeUpdateHandler() {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = FavorStyle.Color.white.value
        button.configuration?.baseBackgroundColor = FavorStyle.Color.typo.value
      case .disabled:
        button.configuration?.baseForegroundColor = FavorStyle.Color.typo.value
        button.configuration?.baseBackgroundColor = FavorStyle.Color.box1.value
      default:
        break
      }
    }
    self.configurationUpdateHandler = handler
  }
  
}

// MARK: - UIButton Configuraiton

@available(iOS 15.0, *)
extension UIButton.Configuration {
  
  enum FavorButton {
    case large, small, plain
    
    /// 버튼의 배경 색상
    var backgroundColor: UIColor? {
      switch self {
      case .large, .small:
        return FavorStyle.Color.typo.value
      case .plain:
        return .clear
      }
    }
    
    /// 버튼의 내용 색상
    var foregroundColor: UIColor? {
      switch self {
      case .large, .small:
        return FavorStyle.Color.white.value
      case .plain:
        return FavorStyle.Color.detail.value
      }
    }
    
    /// 버튼의 모서리 반경 (corner radius)
    var cornerRadius: CGFloat { // TODO: - 정확한 값 정해지면 적용하기.
      return 28.0
    }

    // 버튼의 텍스트 폰트
    var font: UIFont {
      return .systemFont(ofSize: 18.0, weight: .bold)
    }
  }
  
}
