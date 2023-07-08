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
    imageView.image = UIImage(named: "MyPageHeaderPlaceholder")
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
    
    // TODO: 테스트 코드 삭제
    let url = URL(string: "https://picsum.photos/1200/1200")!
    self.backgroundImageView.setImage(from: url, mapper: CacheKeyMapper(user: User(), subpath: .background))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Binding
  
  // MARK: - Functions
  
  func updateBackgroundAlpha(to alpha: CGFloat) {
    [
      self.backgroundImageView,
      self.profileStackView,
      self.profileImageButton
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

    self.profileImageButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(60)
      make.width.height.equalTo(60)
    }
    
    self.profileStackView.snp.makeConstraints { make in
      make.leading.equalTo(self.profileImageButton.snp.trailing).offset(16)
      make.centerY.equalTo(self.profileImageButton.snp.centerY)
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

  @MainActor
  public var backgroundImage: Binder<UIImage?> {
    return Binder(self.base) { view, image in
      view.backgroundImageView.image = image
    }
  }
}
