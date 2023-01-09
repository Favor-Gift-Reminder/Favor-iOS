//
//  UIButon+.swift
//  Favor
//
//  Created by 이창준 on 2023/01/06.
//

import UIKit

// MARK: - UIButton

extension UIButton {
  
}

// MARK: - UIButton Configuraiton

@available(iOS 15.0, *)
extension UIButton.Configuration {
  
  enum FavorButton {
    case large, regular, small
    
    /// 버튼의 배경 색상
    var backgroundColor: UIColor? {
      switch self {
      default:
        return FavorStyle.Color.typo.value
      }
    }
    
    /// 버튼의 내용 색상
    var foregroundColor: UIColor? {
      switch self {
      default:
        return FavorStyle.Color.white.value
      }
    }
    
    /// 버튼의 모서리 반경 (corner radius)
    var cornerRadius: CGFloat {
      return 0.0
    }

    // TODO: - 폰트
    
  }
  
  /// Pre-configured된 UIButton.Configuration에 따라 UIButton을 생성합니다.
  /// - Parameters:
  ///     - style: 버튼의 스타일 (large, regular, small)
  ///     - title: 버튼의 텍스트
  static func makeButton(with style: FavorButton, title: String? = nil) -> UIButton.Configuration {
    var configuration = UIButton.Configuration.filled()
    configuration.title = title
    configuration.titleAlignment = .center
    configuration.background.cornerRadius = 12.0 // TODO: - 정확한 값 여쭤보기.
    configuration.baseBackgroundColor = style.backgroundColor
    configuration.baseForegroundColor = style.foregroundColor
    return configuration
  }
}
