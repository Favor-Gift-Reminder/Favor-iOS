//
//  AcceptAllView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/03.
//

import UIKit

import SnapKit

final class AcceptAllView: UIView {

  // MARK: - Constants

  // MARK: - Properties

  var isChecked: Bool = false {
    didSet {
      let image = self.isChecked ? "checkmark.square.fill" : "checkmark.square"
      self.checkButton.configuration?.image = UIImage(systemName: image)
    }
  }

  // MARK: - UI Components

  private lazy var checkButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: "checkmark.square")
    config.contentInsets = NSDirectionalEdgeInsets(top: 6.5, leading: 6.5, bottom: 6.5, trailing: 6.5)
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    button.isUserInteractionEnabled = false
    return button
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    return label
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

// MARK: - UI Setup

extension AcceptAllView: BaseView {
  func setupStyles() {
    self.frame = self.frame.inset(
      by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    )
  }

  func setupLayouts() {
    [
      self.checkButton,
      self.titleLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.checkButton.snp.makeConstraints { make in
      make.leading.directionalVerticalEdges.equalToSuperview()
      make.width.equalTo(self.checkButton.snp.height)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.checkButton.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
}
