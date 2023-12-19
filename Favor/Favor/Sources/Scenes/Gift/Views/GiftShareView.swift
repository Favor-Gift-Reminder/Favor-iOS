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
    imageView.backgroundColor = .black
    imageView.layer.masksToBounds = true
    imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    imageView.layer.cornerRadius = 16.0
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
      string: "여기에 문구를 입력하세요! (최대 20자)",
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
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView(image: .favorIcon(.logo))
    imageView.isHidden = true
    return imageView
  }()
  
  // MARK: - Properties
  
  private var topInsetConstraint: Constraint?

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
    if let urlString = gift.photos.first?.remote {
      guard let url = URL(string: urlString) else { return }
      self.imageView.setImage(from: url, mapper: .init(gift: gift, subpath: .image(urlString)))
    }
    self.titleTextField.text = gift.name
  }
}

// MARK: - UI Setups

extension GiftShareView: BaseView {
  func setupStyles() {
    self.layer.cornerRadius = 16
    self.clipsToBounds = true
    self.backgroundColor = .clear
  }

  func setupLayouts() {
    [
      self.imageView,
      self.labelContainer,
      self.logoImageView
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
      self.topInsetConstraint = make.top.equalToSuperview().inset(0).constraint
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(self.imageView.snp.width)
    }

    self.labelContainer.snp.makeConstraints { make in
      make.top.equalTo(self.imageView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(80.0)
      make.bottom.equalToSuperview()
    }
    
    self.labelStack.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    self.logoImageView.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview()
    }
  }
  
  // MARK: - Functions
  
  func toImageWithLogo() -> UIImage {
    self.logoImageView.isHidden = false
    self.topInsetConstraint?.update(inset: 34.0)
    self.layoutIfNeeded()
    let image = self.toImage()
    self.logoImageView.isHidden = true
    self.topInsetConstraint?.update(inset: 0)
    return image
  }
}
