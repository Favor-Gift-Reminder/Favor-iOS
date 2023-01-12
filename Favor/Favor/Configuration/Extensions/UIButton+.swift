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
  
  /// Pre-configured된 UIButton.Configuration에 따라 UIButton을 생성합니다.
  /// - Parameters:
  ///     - style: 버튼의 스타일 (large, small)
  ///     - title: 버튼의 텍스트
  ///     - image: 버튼의 이미지(아이콘)
  static func makeButton(
    with style: FavorButton,
    title: String,
    image: UIImage? = nil
  ) -> UIButton.Configuration {
    // Base
    var configuration: UIButton.Configuration
    switch style {
    case .small, .large:
      configuration = .filled()
    case .plain:
      configuration = .plain()
    }
    // Title
    var titleAttr = AttributedString.init(title)
    titleAttr.font = style.font
    configuration.attributedTitle = titleAttr
    configuration.titleAlignment = .center
    // Image
    configuration.image = image
    configuration.imagePlacement = .leading
    configuration.imagePadding = 8
    // Layer
    configuration.background.cornerRadius = style.cornerRadius
    // Layout
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
    // Color
    configuration.baseBackgroundColor = style.backgroundColor
    configuration.baseForegroundColor = style.foregroundColor
    
    return configuration
  }
  
  /// UIButton의 state에 따라 배경색과 텍스트 색을 바꿉니다.
  /// - Parameters:
  ///   - state: 교체할 버튼의 state
  func updateState(to state: UIButton.State) -> UIButton.Configuration {
    var config = self
    switch state {
    case .normal:
      config.baseForegroundColor = FavorStyle.Color.white.value
      config.baseBackgroundColor = FavorStyle.Color.typo.value
    case .disabled:
      config.baseForegroundColor = FavorStyle.Color.typo.value
      config.baseBackgroundColor = FavorStyle.Color.box1.value
    default:
      break
    }
    return config
  }
}
