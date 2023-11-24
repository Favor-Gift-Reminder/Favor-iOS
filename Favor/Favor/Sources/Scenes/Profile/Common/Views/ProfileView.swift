//
//  ProfileView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public final class ProfileView: UIView {
  
  // MARK: - Constants

  public static let height: CGFloat = 330.0
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  let backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .favorColor(.background)
    return imageView
  }()

  fileprivate let profileImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 30)
      .withTintColor(.favorColor(.white))
    config.background.cornerRadius = 30

    let button = UIButton(configuration: config)
    return button
  }()
  
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 30.0
    imageView.layer.masksToBounds = true
    imageView.backgroundColor = .favorColor(.line3)
    return imageView
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .favorColor(.white)
    label.font = .favorFont(.bold, size: 22)
    label.text = "이름"
    return label
  }()
  
  let idLabel: UILabel = {
    let label = UILabel()
    label.textColor = .favorColor(.line3)
    label.font = .favorFont(.regular, size: 16)
    label.text = "@ID123"
    return label
  }()

  private let profileStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 10
    return stackView
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
  
  // MARK: - Functions
  
  func updateName(_ name: String) {
    self.nameLabel.text = name
  }
  
  func updateId(_ id: String) {
    self.idLabel.text = "@\(id)"
  }
  
  func updateBackgroundImage(_ urlString: String, mapper: CacheKeyMapper) {
    if let url = URL(string: urlString) {
      self.backgroundImageView.setImage(from: url, mapper: mapper)
    } else {
      let url = URL(string: "https://picsum.photos/1200/1200")!
      self.backgroundImageView.kf.setImage(with: url)
    }
  }
  
  func updateProfileImage(_ urlString: String, mapper: CacheKeyMapper) {
    if let url = URL(string: urlString) {
      self.profileImageView.setImage(from: url, mapper: mapper)
      self.profileImageButton.isHidden = true
    } else {
      self.profileImageButton.isHidden = false
    }
  }
  
  func updateBackgroundAlpha(to alpha: CGFloat) {
    [
      self.backgroundImageView,
      self.profileStackView,
      self.profileImageView
    ].forEach {
      $0.alpha = alpha
    }
  }
}

// MARK: - Setup

extension ProfileView: BaseView {
  public func setupStyles() {
    self.backgroundColor = .favorColor(.white)
  }

  public func setupLayouts() {
    [
      self.backgroundImageView,
      self.profileImageView,
      self.profileImageButton,
      self.profileStackView
    ].forEach {
      self.addSubview($0)
    }

    [
      self.nameLabel,
      self.idLabel
    ].forEach {
      self.profileStackView.addArrangedSubview($0)
    }
  }

  public func setupConstraints() {
    self.backgroundImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.profileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(60)
      make.width.height.equalTo(60)
    }
    
    self.profileImageButton.snp.makeConstraints { make in
      make.edges.equalTo(self.profileImageView)
    }
    
    self.profileStackView.snp.makeConstraints { make in
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(16)
      make.centerY.equalTo(self.profileImageView.snp.centerY)
    }
  }
}

// MARK: - Reactive

extension Reactive where Base: ProfileView {
  @MainActor
  public var name: Binder<String> {
    return Binder(self.base, binding: { view, name in
      view.nameLabel.text = name
    })
  }

  @MainActor
  public var id: Binder<String> {
    return Binder(self.base, binding: { view, id in
      view.idLabel.text = "@\(id)"
    })
  }
}
