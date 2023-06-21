//
//  FavorProfileImageView.swift
//  Favor
//
//  Created by 이창준 on 6/20/23.
//

import UIKit

import SnapKit

public class FavorProfilePhotoView: UIView {

  // MARK: - Constants

  public enum ProfileImageViewType {
    case small, big

    public var size: CGFloat {
      switch self {
      case .small: 48.0
      case .big: 60.0
      }
    }

    // borderWidth를 포함한 사이즈
    public var indicatorSize: CGFloat {
      switch self {
      case .small: 14.0 + self.borderWidth
      case .big: 16.0 + self.borderWidth
      }
    }

    public var borderWidth: CGFloat {
      switch self {
      case .small: 2.0
      case .big: 1.5
      }
    }
  }

  // MARK: - Properties

  public var type: ProfileImageViewType = .small {
    didSet { self.updateSize() }
  }

  // MARK: - UI Components

  private var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .favorColor(.line3)
    imageView.clipsToBounds = true
    return imageView
  }()
  private var profileImageViewSize: Constraint?

  private lazy var defaultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: self.type.size / 2)
      .withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    return imageView
  }()

  private lazy var isUserIndicator: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.main)
    view.layer.borderColor = UIColor.favorColor(.white).cgColor
    view.layer.borderWidth = self.type.borderWidth
    view.clipsToBounds = true
    return view
  }()
  private var isUserIndicatorSize: Constraint?

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(_ type: ProfileImageViewType, image: UIImage? = nil) {
    self.init(frame: .zero)
    self.type = type
    self.updateSize()
    self.updateProfileImage(image)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func updateSize() {
    guard
      let profileImageViewSize = self.profileImageViewSize,
      let isUserIndicatorSize = self.isUserIndicatorSize
    else { print("Size constraints missing."); return }
    profileImageViewSize.update(offset: self.type.size)
    profileImageViewSize.update(priority: .high)
    self.profileImageView.layer.cornerRadius = self.type.size / 2
    isUserIndicatorSize.update(offset: self.type.indicatorSize)
    self.isUserIndicator.layer.cornerRadius = self.type.indicatorSize / 2
  }

  public func updateProfileImage(_ image: UIImage?) {
    self.defaultImageView.isHidden = image != nil
    self.profileImageView.image = image
  }
}

// MARK: - UI Setups

extension FavorProfilePhotoView: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    [
      self.profileImageView,
      self.isUserIndicator
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

    self.isUserIndicator.snp.makeConstraints { make in
      make.trailing.bottom.equalToSuperview()
      self.isUserIndicatorSize = make.width.height.equalTo(self.type.indicatorSize).constraint
    }
  }
}
