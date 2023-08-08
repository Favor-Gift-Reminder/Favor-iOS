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
  
  private enum Metric {
    static let profileImageViewSize: CGFloat = 48.0
  }
  
  // MARK: - UI Components
  
  public var containerView = UIView()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.icon)
    label.text = "친구"
    return label
  }()
  
  private let favorProfilePhotoView = FavorProfilePhotoView(.small, isUser: false)
  
  // MARK: - Properties
  
  public var friendName: String = "" {
    willSet { self.nameLabel.text = newValue }
  }
  
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
  
  open func configure(
    name: String,
    image: UIImage? = nil
  ) {
    self.favorProfilePhotoView.profileImage = image
    self.friendName = name
  }

  // MARK: - Setup

  open func setupStyles() {
    self.layer.cornerRadius = Metric.profileImageViewSize / 4
    self.clipsToBounds = true
  }

  open func setupLayouts() {
    self.contentView.addSubview(self.containerView)
    
    [
      self.favorProfilePhotoView,
      self.nameLabel
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  open func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.favorProfilePhotoView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.profileImageViewSize)
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.favorProfilePhotoView.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
    }
  }
}
