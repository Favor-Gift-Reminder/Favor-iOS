//
//  FavorSelectorCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import Reusable
import SnapKit

open class FavorSelectorCell: BaseCollectionViewCell, Reusable {

  // MARK: - Properties

  // MARK: - UI Components

  private let button: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.updateAttributedTitle("선택", font: .favorFont(.regular, size: 16))
    config.imagePlacement = .trailing
    config.imagePadding = 7
    config.contentInsets = .zero

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.explain)
        button.configuration?.image = .favorIcon(.right)?
          .withRenderingMode(.alwaysTemplate)
          .resize(newWidth: 12)
          .withTintColor(.favorColor(.explain))
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
        button.configuration?.image = .favorIcon(.right)?
          .withRenderingMode(.alwaysTemplate)
          .resize(newWidth: 12)
          .withTintColor(.favorColor(.icon))
      default: break
      }
    }
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func bind(unselectedTitle: String) {
    self.isSelected = false
    self.button.configuration?.updateAttributedTitle(
      unselectedTitle,
      font: .favorFont(.regular, size: 16)
    )
  }

  public func bind(selectedTitle: String?) {
    self.isSelected = true
    self.button.configuration?.updateAttributedTitle(
      selectedTitle,
      font: .favorFont(.regular, size: 16)
    )
  }
}

// MARK: - UI Setups

extension FavorSelectorCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.addSubview(self.button)
  }

  public func setupConstraints() {
    self.button.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview()
      make.leading.equalToSuperview()
    }
  }
}
