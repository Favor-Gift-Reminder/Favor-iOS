//
//  ProfileSetupHelperCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

final class ProfileSetupHelperCell: BaseCollectionViewCell, Reusable, View {
  
  // MARK: - Properties
  
  // MARK: - UI Components

  private let containerView = UIView()
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .favorColor(.titleAndLine)
    imageView.contentMode = .center
    imageView.image = .favorIcon(.friend)
    return imageView
  }()
  
  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 14)
    label.textColor = .favorColor(.titleAndLine)
    label.textAlignment = .center
    label.text = "설명"
    return label
  }()
  
  private let goButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.cornerStyle = .capsule
    config.baseBackgroundColor = .favorColor(.titleAndLine)
    config.baseForegroundColor = .favorColor(.white)
    config.updateAttributedTitle("바로가기", font: .favorFont(.bold, size: 12))
    config.titleAlignment = .center
    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

    let button = UIButton(configuration: config)
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
  
  // MARK: - Bind
  
  func bind(reactor: ProfileSetupHelperCellReactor) {
    // Action
    
    // State
    reactor.state.map { $0.type }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, type in
        owner.iconImageView.image = type.iconImage
        owner.descriptionLabel.text = type.description
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Setup

extension ProfileSetupHelperCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.divider)
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }
  
  func setupLayouts() {
    self.addSubview(self.containerView)

    [
      self.iconImageView,
      self.descriptionLabel,
      self.goButton
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    self.iconImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.width.height.equalTo(48)
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.iconImageView.snp.bottom).offset(8)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.goButton.snp.makeConstraints { make in
      make.top.equalTo(self.descriptionLabel.snp.bottom).offset(40)
      make.bottom.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
}
