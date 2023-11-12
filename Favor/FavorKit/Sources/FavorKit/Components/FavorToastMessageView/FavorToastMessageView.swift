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
  
  public var message: ToastMessage? {
    didSet { self.updateMessage() }
  }
  
  public var duration: ToastManager.Duration?

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
  
  private let warningImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .favorIcon(.error)?.withTintColor(.favorColor(.white))
    return iv
  }()
  
  private lazy var stackView: UIStackView = {
    let sv = UIStackView()
    [
      self.warningImageView,
      self.titleLabel
    ].forEach {
      sv.addArrangedSubview($0)
    }
    sv.spacing = 10.0
    sv.axis = .horizontal
    return sv
  }()
  
  // MARK: - Initializer
  
  public init(_ message: ToastMessage) {
    super.init(frame: .zero)
    
    self.message = message
    self.updateMessage()
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

extension FavorToastMessageView: BaseView {
  public func setupStyles() {
    self.autoresizingMask = [
      .flexibleLeftMargin,
      .flexibleRightMargin,
      .flexibleTopMargin,
      .flexibleBottomMargin
    ]
    self.layer.cornerRadius = self.height / 2
    
    switch self.message?.viewType {
    case .basic:
      self.backgroundColor = .favorColor(.toast2).withAlphaComponent(0.7)
      self.warningImageView.isHidden = true
    case .warning:
      self.backgroundColor = .favorColor(.toast1).withAlphaComponent(0.7)
      self.warningImageView.isHidden = false
    default:
      break
    }
  }
  
  public func setupLayouts() {
    self.addSubview(self.stackView)
  }
  
  public func setupConstraints() {
    self.snp.makeConstraints { make in
//      make.width.equalTo(self.width)
      make.height.equalTo(self.height)
    }
    
    self.stackView.snp.makeConstraints { make in
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
    self.titleLabel.text = self.message?.description
  }
}
