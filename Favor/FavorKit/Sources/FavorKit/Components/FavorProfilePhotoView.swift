//
//  FavorProfilePhotoView.swift
//  Favor
//
//  Created by 이창준 on 6/20/23.
//

import UIKit

import SnapKit

/// 친구 리스트 왼쪽에 있는 친구의 이미지 입니다.
/// 마이페이지 또는 친구페이지에 있는 프로필 이미지 입니다.
public class FavorProfilePhotoView: UIView {

  // MARK: - Constants

  public enum ProfileImageViewType {
    case small, big

    public var size: CGFloat {
      switch self {
      case .small: return 48.0
      case .big: return 60.0
      }
    }
  }

  // MARK: - Properties

  public var type: ProfileImageViewType = .small {
    didSet { self.updateSize() }
  }
  
  /// 추가하기 버튼으로 만들 수 있는 값입니다.
  /// 이 값은 `.big`일 때만 사용할 수 있습니다.
  public var isNewFriendCell: Bool = false {
    willSet {
      if newValue {
        self.defaultImageView.image = self.addFriendImage
        self.profileImage = nil
      } else {
        self.defaultImageView.image = self.friendImage
      }
    }
  }
  
  /// 사용자의 프로필 이미지입니다.
  public var profileImage: UIImage? {
    willSet {
      self.defaultImageView.isHidden = newValue != nil
      self.profileImageView.image = newValue
    }
  }
  
  private var profileImageViewSize: Constraint?

  // MARK: - UI Components
  
  /// 기본 이미지에 들어갈 친구 아이콘 입니다.
  private lazy var friendImage: UIImage? = {
    let image: UIImage? = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: self.type.size / 2)
      .withTintColor(.favorColor(.white))
    return image
  }()

  /// 친구 추가하기 이미지에 들어갈 친구 추가 아이콘입니다.
  private lazy var addFriendImage: UIImage? = {
    let image: UIImage? = .favorIcon(.addFriend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: self.type.size / 2)
      .withTintColor(.favorColor(.white))
    return image
  }()

  /// 친구의 프로필 이미지 입니다.
  private var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .favorColor(.line3)
    imageView.clipsToBounds = true
    return imageView
  }()
  
  /// 프로필 이미지가 존재하지 않을 경우 나타나는 기본 이미지입니다.
  private lazy var defaultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = self.friendImage
    imageView.contentMode = .center
    return imageView
  }()

  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  public convenience init(
    _ type: ProfileImageViewType,
    isUser: Bool,
    image: UIImage? = nil
  ) {
    self.init(frame: .zero)
    self.profileImage = image
    self.type = type
    self.updateSize()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  /// 사이즈를 업데이트 해줍니다.
  private func updateSize() {
    guard
      let profileImageViewSize = self.profileImageViewSize
    else { print("Size constraints missing."); return }
    profileImageViewSize.update(offset: self.type.size)
    profileImageViewSize.update(priority: .high)
    self.profileImageView.layer.cornerRadius = self.type.size / 2
  }
}

// MARK: - UI Setups

extension FavorProfilePhotoView: BaseView {
  public func setupStyles() {}

  public func setupLayouts() {
    [
      self.profileImageView
    ].forEach {
      self.addSubview($0)
    }
    
    self.profileImageView.addSubview(self.defaultImageView)
  }

  public func setupConstraints() {
    self.snp.makeConstraints { make in
      self.profileImageViewSize = make.width.height.equalTo(self.type.size).priority(.high).constraint
    }

    self.profileImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.defaultImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
