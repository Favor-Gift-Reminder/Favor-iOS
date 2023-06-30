//
//  FavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

import SnapKit

public final class FavorLargeButton: UIButton {

  // MARK: - Constants

  private enum Metric {
    static let buttonHeight: CGFloat = 56.0
  }

  // MARK: - Properties

  private let largeFavorButtonType: FavorLargeButtonType
  
  // MARK: - Initializer

  public init(with largeFavorButtonType: FavorLargeButtonType) {
    self.largeFavorButtonType = largeFavorButtonType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Setups

extension FavorLargeButton {
  func setupStyles() {
    self.configuration = self.largeFavorButtonType.configuration

    if case FavorLargeButtonType.main2 = self.largeFavorButtonType {
      self.layer.borderColor = UIColor.favorColor(.divider).cgColor
      self.layer.borderWidth = 1.0
    }

    self.layer.cornerRadius = Metric.buttonHeight / 2
    self.clipsToBounds = true
  }
  
  func setupLayouts() { }

  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(Metric.buttonHeight)
    }
  }
}
