//
//  FavorToastMessageView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/14.
//

import UIKit

import SnapKit

public final class FavorToastMessageView: UIView {

  // MARK: - Constants

  // MARK: - Properties

  public var width: CGFloat = 375.0 {
    didSet { self.updateWidth() }
  }

  public var height: CGFloat = 44.0 {
    didSet { self.updateHeight() }
  }

  public var message: String? {
    didSet { self.updateMessage() }
  }

  public var duration: ToastManager.duration?

  // MARK: - UI Components

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 16)
    label.textColor = .favorColor(.white)
    label.textAlignment = .center
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    return label
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(_ message: String) {
    self.init(frame: .zero)

    self.message = message
    self.updateMessage()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

}

// MARK: - UI Setup

extension FavorToastMessageView: BaseView {
  public func setupStyles() {
    self.autoresizingMask = [
      .flexibleLeftMargin,
      .flexibleRightMargin,
      .flexibleTopMargin,
      .flexibleBottomMargin
    ]
    self.layer.cornerRadius = self.height / 2
    self.backgroundColor = .favorColor(.sub)
  }

  public func setupLayouts() {
    self.addSubview(self.titleLabel)
  }

  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.width.equalTo(self.width)
      make.height.equalTo(self.height)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension FavorToastMessageView {
  func updateWidth() {
    self.snp.updateConstraints { make in
      make.width.equalTo(self.width)
    }
  }

  func updateHeight() {
    self.snp.updateConstraints { make in
      make.height.equalTo(self.height)
    }
  }

  func updateMessage() {
    self.titleLabel.text = self.message
  }
}
