//
//  NewGiftFriendHeaderView.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class FriendSelectorHeaderView: UICollectionReusableView, Reusable {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 18)
    lb.textColor = .favorColor(.icon)
    return lb
  }()
  
  private let countLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 18)
    lb.textColor = .favorColor(.icon)
    return lb
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
  
  func configure(section: NewGiftFriendSection, friendsCount: Int) {
    self.countLabel.text = "\(friendsCount)"
    switch section {
    case .selectedFriends:
      self.titleLabel.text = "선택한 친구"
    case .friends:
      self.titleLabel.text = "친구"
    }
  }
}

extension FriendSelectorHeaderView: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.titleLabel,
      self.countLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview().inset(32)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
      make.centerY.equalTo(self.titleLabel)
    }
  }
}
