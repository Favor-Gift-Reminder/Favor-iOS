//
//  ProfileSetupCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

class ProfileSetupCell: UICollectionViewCell, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .favorColor(.titleAndLine)
    imageView.contentMode = .center
    imageView.image = .favorIcon(.friend)
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
    label.textColor = .favorColor(.titleAndLine)
    label.textAlignment = .center
    label.text = "취향"
    return label
  }()
  
  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    label.numberOfLines = 2
    label.text = "Aliquip occaecat elit irure Lorem est reprehenderit consectetur anim ea. Non tempor ad magna sit proident in sit proident incididunt. Dolor deserunt qui nulla aute minim ex excepteur elit nostrud est minim dolor anim. Veniam irure nostrud minim labore consectetur sit amet ut id deserunt nisi. Irure ex magna in reprehenderit veniam id occaecat proident consectetur occaecat elit est elit ad minim."
    return label
  }()
  
  private lazy var goButton = FavorSmallButton(with: .gray("바로가기"))
  
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
  
  func bind(reactor: FavorSetupProfileCellReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension ProfileSetupCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.divider)
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }
  
  func setupLayouts() {
    [
      self.iconImageView,
      self.titleLabel,
      self.descriptionLabel,
      self.goButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.iconImageView.snp.makeConstraints { make in
      make.width.height.equalTo(48)
      make.top.equalToSuperview().offset(24)
      make.centerX.equalToSuperview()
    }
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.iconImageView.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
    }
    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
      make.centerX.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
    self.goButton.snp.makeConstraints { make in
      make.top.equalTo(self.descriptionLabel.snp.bottom).offset(48)
      make.centerX.equalToSuperview()
    }
  }
}
