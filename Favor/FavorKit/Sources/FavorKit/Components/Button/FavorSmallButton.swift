//
//  FavorSmallButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/16.
//

import UIKit

import SnapKit

public final class FavorSmallButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let smallFavorButtonType: FavorSmallButtonType

  /// 현재 선물 카테고리의 case를 알 수 있습니다.
  var category: FavorCategory {
    guard let title = self.configuration?.title else { return .lightGift }
    return FavorCategory(rawValue: title) ?? .lightGift
  }
  
  // MARK: - INITIALIZER
  
  public init(with smallFavorButtonType: FavorSmallButtonType) {
    self.smallFavorButtonType = smallFavorButtonType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SETUP

extension FavorSmallButton {
  func setupStyles() {
    self.configuration = self.smallFavorButtonType.configuration
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(32)
    }
  }
}
