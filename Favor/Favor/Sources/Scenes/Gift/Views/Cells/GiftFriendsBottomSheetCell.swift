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

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 10
    return stackView
  }()

  private let profileImageView = FavorProfilePhotoView(.big, isUser: false)

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
    self.nameLabel.text = friend.name
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
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  public func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
