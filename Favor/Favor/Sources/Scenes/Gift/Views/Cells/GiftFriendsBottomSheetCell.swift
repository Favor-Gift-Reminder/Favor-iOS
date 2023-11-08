//
//  GiftFriendsBottomSheetCell.swift
//  Favor
//
//  Created by 이창준 on 6/20/23.
//

import UIKit

import FavorKit
import SnapKit

public final class GiftFriendsBottomSheetCell: BaseCollectionViewCell {

  // MARK: - UI Components

  private let profileImageView = FavorProfilePhotoView(.big)

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    return label
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

  // MARK: - Functions
  
  public func bind(_ friend: Friend) {
    self.profileImageView.profileImage = friend.profilePhoto
    self.nameLabel.text = friend.friendName
    self.profileImageView.isTempUser = friend.identifier < 0
  }
}

// MARK: - UI Setups

extension GiftFriendsBottomSheetCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.profileImageView,
      self.nameLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.nameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.profileImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.nameLabel.snp.top).offset(-10.0)
    }
  }
}
