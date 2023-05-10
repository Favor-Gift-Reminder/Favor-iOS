//
//  FriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import Reusable

final class FriendCell: BaseCollectionViewCell, Pressable, Reusable {

  // MARK: - Constants

  private enum Metric {
    static let profileImageViewSize = 48.0
    static let rightImageViewSize = 28.0
  }

  // MARK: - Properties

  var pressedScale: Double = 0.96
  var idleBackgroundColor: UIColor = .favorColor(.white)
  var pressedBackgroundColor: UIColor = .favorColor(.background)

  // MARK: - UI Components

  var containerView = UIView()

  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 24)
      .withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    imageView.layer.cornerRadius = Metric.profileImageViewSize / 2
    imageView.clipsToBounds = true
    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.text = "유저"
    return label
  }()

  private let userIdentifierImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.favor)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 16)
      .withTintColor(.favorColor(.main))
    imageView.contentMode = .center
    return imageView
  }()

  private let rightImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.right)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 16)
      .withTintColor(.favorColor(.line2))
    imageView.contentMode = .center
    return imageView
  }()

  private let rightIconStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    return stackView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.setupLongPressRecognizer()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func bind(with friend: Friend) {
    self.nameLabel.text = friend.name
    self.userIdentifierImageView.isHidden = !friend.isUser
  }
}

// MARK: - UI Setups

extension FriendCell: BaseView {
  func setupStyles() {
    self.layer.cornerRadius = Metric.profileImageViewSize / 5
  }

  func setupLayouts() {
    self.addSubview(self.containerView)

    [
      self.userIdentifierImageView,
      self.rightImageView
    ].forEach {
      self.rightIconStack.addArrangedSubview($0)
    }

    [
      self.profileImageView,
      self.nameLabel,
      self.rightIconStack
    ].forEach {
      self.containerView.addSubview($0)
    }
  }

  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.profileImageView.snp.makeConstraints { make in
      make.leading.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.profileImageViewSize)
    }

    self.nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(16)
      make.directionalVerticalEdges.equalToSuperview()
      make.centerY.equalToSuperview()
    }

    self.rightImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.rightImageViewSize)
    }

    self.userIdentifierImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.rightImageViewSize)
    }

    self.rightIconStack.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
