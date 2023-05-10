//
//  FriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

final class FriendCell: BaseCollectionViewCell, Reusable, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.text = "유저"
    return label
  }()

  private let userIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.main)
    return imageView
  }()

  private let rightArrow: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.right)
    return imageView
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

  // MARK: - Binding

  func bind(reactor: FriendCellReactor) {
    // Action

    // State

  }

  // MARK: - Functions

}

// MARK: - UI Setups

extension FriendCell: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    [
      self.profileImageView,
      self.nameLabel,
      self.userIcon,
      self.rightArrow
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.leading.directionalVerticalEdges.equalToSuperview()
      make.width.equalTo(self.profileImageView.snp.height)
    }

    self.nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(16)
      make.directionalVerticalEdges.equalToSuperview()
      make.centerY.equalToSuperview()
    }

    self.rightArrow.snp.makeConstraints { make in
      make.height.width.equalTo(28)
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }

    self.userIcon.snp.makeConstraints { make in
      make.height.width.equalTo(28)
      make.trailing.equalTo(self.rightArrow.snp.leading).offset(10)
      make.centerY.equalToSuperview()
    }
  }
}
