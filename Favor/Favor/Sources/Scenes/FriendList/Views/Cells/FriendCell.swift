//
//  FriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import Reusable

final class FriendCell: BaseFriendCell, Pressable, Reusable {

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

  private let isUserIconImageView: UIImageView = {
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
    
    self.setupLongPressRecognizer()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public override func bind(with friend: Friend) {
    super.bind(with: friend)
//    self.nameLabel.text = friend.name
    self.isUserIconImageView.isHidden = !friend.isUser
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    [
      self.isUserIconImageView,
      self.rightImageView
    ].forEach {
      self.rightIconStack.addArrangedSubview($0)
    }

    self.containerView.addSubview(self.rightIconStack)
  }

  override func setupConstraints() {
    super.setupConstraints()

    [
      self.isUserIconImageView,
      self.rightImageView
    ].forEach {
      $0.snp.makeConstraints { make in
        make.width.height.equalTo(Metric.rightImageViewSize)
      }
    }

    self.rightIconStack.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
