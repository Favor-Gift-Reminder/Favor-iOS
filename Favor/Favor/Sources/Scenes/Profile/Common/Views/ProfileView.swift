//
//  ProfileView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import SnapKit

final class ProfileView: UIView, View {
  
  // MARK: - Constants

  public static let height: CGFloat = 330.0
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components

  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "MyPageHeaderPlaceholder")
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  fileprivate lazy var profileImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .systemBlue
    config.background.cornerRadius = 30

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .favorColor(.white)
    label.font = .favorFont(.bold, size: 22)
    label.text = "이름"
    return label
  }()

  private lazy var idLabel: UILabel = {
    let label = UILabel()
    label.textColor = .favorColor(.line3)
    label.font = .favorFont(.regular, size: 16)
    label.text = "@ID123"
    return label
  }()

  private lazy var profileStackView: UIStackView = {
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
  
  func bind(reactor: MyPageHeaderViewReactor) {
    // Action
    
    // State
    
  }
  
  // MARK: - Functions

  func updateBackgroundAlpha(to alpha: CGFloat) {
    self.backgroundImageView.alpha = alpha
  }
}

// MARK: - Setup

extension ProfileView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.main)
  }

  func setupLayouts() {
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

  func setupConstraints() {
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
