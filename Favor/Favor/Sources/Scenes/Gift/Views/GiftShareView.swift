//
//  GiftShareView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import UIKit

import FavorKit
import SnapKit

final class GiftShareView: UIView {

  // MARK: - Properties

  public var currentImage: UIImage? {
    return self.imageView.image
  }

  // MARK: - UI Components

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: "GiftMock")
    return imageView
  }()

  private let titleTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .none
    textField.font = .favorFont(.bold, size: 18)
    textField.textAlignment = .center
    textField.textColor = .favorColor(.white)
    textField.text = "제목"
    return textField
  }()

  private let subtitleTextField: UITextField = {
    let textField = UITextField()
    textField.font = .favorFont(.regular, size: 12)
    textField.textAlignment = .center
    textField.textColor = .favorColor(.line3)
    let placeholder = NSAttributedString(
      string: "여기를 눌러 문구를 입력하세요!",
      attributes: [
        .foregroundColor: UIColor.favorColor(.line3),
        .font: UIFont.favorFont(.regular, size: 12)
      ]
    )
    textField.attributedPlaceholder = placeholder
    return textField
  }()

  private let labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  private let labelContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.black)
    return view
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

  // MARK: - Bind

  public func bind(with gift: Gift, image: UIImage?) {
    if let image {
      self.imageView.image = image
    }
    self.titleTextField.text = gift.name
  }
}

// MARK: - UI Setups

extension GiftShareView: BaseView {
  func setupStyles() {
    self.layer.cornerRadius = 16
    self.clipsToBounds = true
  }

  func setupLayouts() {
    [
      self.imageView,
      self.labelContainer
    ].forEach {
      self.addSubview($0)
    }

    [
      self.titleTextField,
      self.subtitleTextField
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }

    self.labelContainer.addSubview(self.labelStack)
  }

  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(self.imageView.snp.width)
    }

    self.labelContainer.snp.makeConstraints { make in
      make.top.equalTo(self.imageView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    self.labelStack.snp.makeConstraints { make in
      make.directionalVerticalEdges.lessThanOrEqualToSuperview().inset(16)
      make.directionalHorizontalEdges.lessThanOrEqualToSuperview()
      make.center.equalToSuperview()
    }
  }
}
