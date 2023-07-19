//
//  FavorPlainButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/20.
//

import UIKit

import SnapKit

public final class FavorPlainButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let plainFavorButtonType: FavorPlainButtonType

  // MARK: - INITIALIZER
  
  public init(with plainFavorButtonType: FavorPlainButtonType) {
    self.plainFavorButtonType = plainFavorButtonType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  /// 원하는 색깔과 타이틀로 버튼의 상태를 업데이트합니다.
  /// - Parameters:
  ///  - color: 바꿀 색상
  ///  - title: 바꿀 타이틀 텍스트
  public func updateButtonState(_ color: UIColor, title: String) {
    let font: UIFont
    var image: UIImage?
    var container = AttributeContainer()
    var config = self.configuration
    switch self.plainFavorButtonType {
    case .navigate(_, let isRight):
      font = .favorFont(.regular, size: 14)
      image = isRight ? .favorIcon(.right): .favorIcon(.down)
      config?.image =  image?
        .resize(newWidth: 12)
        .withTintColor(color)
    case .more:
      font = .favorFont(.regular, size: 12)
    case .main(_, let isRight):
      font = .favorFont(.regular, size: 16)
      image = isRight ? .favorIcon(.right): .favorIcon(.down)
      config?.image = image?
        .resize(newWidth: 13)
        .withTintColor(color)
    }
    container.font = font
    container.foregroundColor = color
    config?.attributedTitle = AttributedString(title, attributes: container)
    config?.baseForegroundColor = color
    self.configuration = config
  }
}

// MARK: - SETUP

extension FavorPlainButton {
  func setupStyles() {
    self.configuration = self.plainFavorButtonType.configuration
  }
  
  func setupLayouts() {}
  func setupConstraints() {}
}
