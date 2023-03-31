//
//  ChoiceFriendButton.swift
//  Favor
//
//  Created by 김응철 on 2023/03/30.
//

import UIKit

import FavorKit
import SnapKit

final class NewGiftChoiceFriendView: UIView {
  
  // MARK: - UI
  
  private let friendLabel: UILabel = {
    let lb = UILabel()
    lb.text = "친구 선택"
    lb.textColor = .favorColor(.explain)
    lb.font = .favorFont(.regular, size: 16)
    return lb
  }()
  
  private let iconImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage.favorIcon(.right)?.withTintColor(.favorColor(.explain))
    return iv
  }()
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SETUP

extension NewGiftChoiceFriendView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.white)
  }
  
  func setupLayouts() {
    [
      self.friendLabel,
      self.iconImageView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(20)
    }
    
    self.friendLabel.snp.makeConstraints { make in
      make.leading.centerY.equalToSuperview()
    }
    
    self.iconImageView.snp.makeConstraints { make in
      make.leading.equalTo(self.friendLabel.snp.trailing).offset(6)
      make.trailing.centerY.equalToSuperview()
      make.width.height.equalTo(12)
    }
  }
}
