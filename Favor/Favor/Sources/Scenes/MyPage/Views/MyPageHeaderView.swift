//
//  MyPageHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

import ReactorKit
import SnapKit

final class MyPageHeaderView: UIView, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components

  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "MyPageHeaderPlaceholder")
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .systemBlue
    imageView.layer.cornerRadius = 30
    return imageView
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
  
  func bind(reactor: MyPageHeaderReactor) {
    // Action
    
    // State
    
  }
  
  // MARK: - Functions

  func updateBackgroundAlpha(to alpha: CGFloat) {
    self.backgroundImageView.alpha = alpha
  }
}

// MARK: - UI Setup

extension MyPageHeaderView: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    [
      self.backgroundImageView,
      self.profileImageView,
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

    self.profileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(58)
      make.width.height.equalTo(60)
    }
    
    self.profileStackView.snp.makeConstraints { make in
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(16)
      make.centerY.equalTo(self.profileImageView.snp.centerY)
    }
  }
}
