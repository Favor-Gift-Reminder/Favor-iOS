//
//  NewGiftFriendCell.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import Reusable

final class FriendSelectorCell: BaseFriendCell, Reusable {
  
  enum RightButtonType {
    case add
    case done
    case remove
  }
  
  // MARK: - UI Components
  
  private let rightImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .favorIcon(.newGift)?.withTintColor(.favorColor(.divider))
    return iv
  }()
  
  // MARK: - Properties
  
  var currentButtonType: RightButtonType = .add {
    didSet {
      let image: UIImage?
      switch currentButtonType {
      case .add:
        image = .favorIcon(.newGift)?.withTintColor(.favorColor(.divider))
      case .remove:
        image = .favorIcon(.remove)?.withTintColor(.favorColor(.divider))
      case .done:
        image = .favorIcon(.done)?.withTintColor(.favorColor(.divider))
      }
      self.rightImageView.image = image
    }
  }

  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.contentView.addSubview(self.rightImageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.rightImageView.snp.makeConstraints { make in
      make.width.height.equalTo(18.0)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(with friend: Friend, buttonType: RightButtonType) {
    self.currentButtonType = buttonType
    if let profileUrl = friend.profilePhoto?.remote {
      let mapper = CacheKeyMapper(friend: friend, subpath: .profilePhoto(profileUrl))
      self.configure(
        friendName: friend.friendName,
        profileURL: profileUrl,
        mapper: mapper
      )
    } else {
      self.configure(
        friendName: friend.friendName
      )
    }
  }
}
