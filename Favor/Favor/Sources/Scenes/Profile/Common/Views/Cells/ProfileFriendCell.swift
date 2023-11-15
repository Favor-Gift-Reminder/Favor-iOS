//
//  ProfileFriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class ProfileFriendCell: BaseCollectionViewCell, Reusable {

  // MARK: - Constants

  // MARK: - Properties
    
  // MARK: - UI Components
  
  private let favorProfilePhotoView = FavorProfilePhotoView(.big)
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 30
    imageView.isHidden = true
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.spacing = 8
    return stackView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    label.text = "이름"
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
  
  func configure(with friend: Friend) {
    self.nameLabel.text = friend.friendName
    if let urlString = friend.profilePhoto?.remote {
      guard let url = URL(string: urlString) else { return }
      self.imageView.isHidden = false
      self.imageView.setImage(from: url, mapper: .init(friend: friend, subpath: .profilePhoto(urlString)))
    } else {
      self.imageView.isHidden = true
    }
  }
}

// MARK: - UI Setups

extension ProfileFriendCell: BaseView {
  func setupStyles() {}

  func setupLayouts() {
    [
      self.favorProfilePhotoView,
      self.nameLabel
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.favorProfilePhotoView.addSubview(self.imageView)
    self.addSubview(self.stackView)
  }

  func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.favorProfilePhotoView.snp.makeConstraints { make in
      make.width.height.equalTo(60)
    }
    
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
