//
//  EditMyPageFavorCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class EditMyPageFavorCell: BaseCollectionViewCell, Reusable {

  // MARK: - Constants

  // MARK: - Properties

  public var isButtonSelected: Bool = false {
    didSet { self.favorButton.isSelected = self.isButtonSelected }
  }

  public var favor: Favor? {
    didSet { self.updateTitle() }
  }

  // MARK: - UI Components

  private let favorButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.titleLineBreakMode = .byTruncatingMiddle

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseBackgroundColor = .favorColor(.button)
        button.configuration?.baseForegroundColor = .favorColor(.subtext)
      case .selected:
        button.configuration?.baseBackgroundColor = .favorColor(.icon)
        button.configuration?.baseForegroundColor = .favorColor(.white)
      default: break
      }
    }
    button.titleLabel?.numberOfLines = 1
    button.isUserInteractionEnabled = false
    button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

}

// MARK: - UI Setups

extension EditMyPageFavorCell: BaseView {
  func setupStyles() {
    self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
  }

  func setupLayouts() {
    self.addSubview(self.favorButton)
  }

  func setupConstraints() {
    self.favorButton.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension EditMyPageFavorCell {
  func updateTitle() {
    self.favorButton.configuration?.updateAttributedTitle(
      self.favor?.rawValue,
      font: .favorFont(.bold, size: 12)
    )
  }
}
