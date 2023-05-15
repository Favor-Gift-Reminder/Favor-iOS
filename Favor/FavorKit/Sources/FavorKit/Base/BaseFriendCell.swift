//
//  BaseFriendCell.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import SnapKit

open class BaseFriendCell: BaseCollectionViewCell {

  // MARK: - Constants
  
  public enum ProfileImageType {
    case undefined
    case friend(UIImage?)
  }
  
  private enum Metric {
    static let profileImageViewSize: CGFloat = 48.0
  }
  
  // MARK: - Properties

  public var friendNo: Int?
  
  public var friendName: String = "" {
    didSet {
      self.nameLabel.text = friendName
    }
  }
  
  public var friendProfileImage: ProfileImageType = .undefined {
    didSet {
      switch self.friendProfileImage {
      case .undefined:
        self.profileImageView.isHidden = true
        self.friendIconImageView.isHidden = false
      case .friend:
//        self.profileImageView.image = profileImage
        self.profileImageView.isHidden = false
        self.friendIconImageView.isHidden = true
      }
    }
  }
  
  // MARK: - UI Components

  public var containerView = UIView()

  private let friendIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: Metric.profileImageViewSize / 2)
      .withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    imageView.backgroundColor = .favorColor(.line3)
    imageView.layer.cornerRadius = Metric.profileImageViewSize / 2
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .clear
    imageView.layer.cornerRadius = Metric.profileImageViewSize / 2
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.icon)
    label.text = "친구"
    return label
  }()

  // MARK: - Initializer

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  open func bind(with friend: Friend) {
    self.friendNo = friend.friendNo
    self.friendName = friend.name
//    self.userImage = .friend(friend.profilePhoto)
  }

  // MARK: - Setup

  open func setupStyles() {
    self.layer.cornerRadius = Metric.profileImageViewSize / 4
    self.clipsToBounds = true
  }

  open func setupLayouts() {
    self.contentView.addSubview(self.containerView)

    [
      self.friendIconImageView,
      self.profileImageView,
      self.nameLabel
    ].forEach {
      self.containerView.addSubview($0)
    }
  }

  open func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.profileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.profileImageViewSize)
    }

    self.friendIconImageView.snp.makeConstraints { make in
      make.center.equalTo(self.profileImageView)
      make.width.height.equalTo(Metric.profileImageViewSize)
    }

    self.nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
    }
  }
}
