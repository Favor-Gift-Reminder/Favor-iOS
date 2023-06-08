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

class ProfileAnniversaryCell: UICollectionViewCell, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    imageView.image = .favorIcon(.congrat)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 36)
      .withTintColor(.favorColor(.icon))
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
  
  // MARK: - Bind
  
  func bind(reactor: ProfileAnniversaryCellReactor) {
    // Action
    
    // State
    reactor.state.map { $0.anniversary }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, anniversary in
        owner.titleLabel.text = anniversary.name
        owner.dateLabel.text = anniversary.date.toShortenDateString()
      })
      .disposed(by: self.disposeBag)
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
      self.vStack
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
  }
}
