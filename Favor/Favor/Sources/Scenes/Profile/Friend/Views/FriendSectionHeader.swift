//
//  FriendSectionHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/04/28.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class FriendSectionHeader: BaseSectionHeader, Reusable {

  // MARK: - UI Components

  private let numberOfFriendsLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    return label
  }()

  // MARK: - Functions

  public func bind(title: String, numberOfFriends: Int) {
    self.titleLabel.text = title
    self.numberOfFriendsLabel.text = "\(numberOfFriends)"
  }

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
  }

  override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.numberOfFriendsLabel)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.numberOfFriendsLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
      make.centerY.equalTo(self.titleLabel.snp.centerY)
    }
  }
}
