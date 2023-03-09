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
  
  private let smallFavorButtonType: SmallFavorButtonType
  
  // MARK: - INITIALIZER
  
  public init(with smallFavorButtonType: SmallFavorButtonType, title: String = "") {
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
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 10)
    self.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(32)
    }
  }
}
