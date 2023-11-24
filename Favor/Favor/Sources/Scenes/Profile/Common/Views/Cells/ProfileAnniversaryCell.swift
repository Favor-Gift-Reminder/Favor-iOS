//
//  ProfileAnniversaryCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

class ProfileAnniversaryCell: UICollectionViewCell, Reusable {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  var anniversary: Anniversary?
  var rightButtonDidTap: ((Anniversary) -> Void)?
  
  // MARK: - UI Components
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    imageView.image = .favorIcon(.congrat)?
      .resize(newWidth: 36)
    imageView.contentMode = .center
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.titleAndLine)
    label.textAlignment = .left
    label.text = "기념일"
    return label
  }()
  
  private lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.titleAndLine)
    label.text = "2000. 1. 1"
    return label
  }()
  
  private lazy var rightButton: FavorButton = {
    let button = FavorButton()
    button.baseBackgroundColor = .clear
    button.contentInset = .zero
    let action = UIAction { [weak self] _ in
      guard let anniversary = self?.anniversary else { return }
      self?.rightButtonDidTap?(anniversary)
    }
    button.addAction(action, for: .touchUpInside)
    return button
  }()
  
  private lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    [
      self.titleLabel,
      self.dateLabel
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
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
  
  // MARK: - Configure
  
  func configure(with anniversary: Anniversary, isMine: Bool) {
    self.titleLabel.text = anniversary.name
    self.dateLabel.text = anniversary.date.toShortenDateString()
    self.iconImageView.image = anniversary.category.image?.resize(newWidth: 36.0)
    self.rightButton.isHidden = isMine
    self.rightButton.image = .favorIcon(.addnoti)
    self.anniversary = anniversary
  }
}

// MARK: - Setup

extension ProfileAnniversaryCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.card)
    self.layer.cornerRadius = 24
    self.clipsToBounds = true
  }
  
  func setupLayouts() {
    [
      self.iconImageView,
      self.vStack,
      self.rightButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.iconImageView.snp.makeConstraints { make in
      make.height.width.equalTo(48)
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    self.vStack.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(29)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(22.0)
    }
  }
}
