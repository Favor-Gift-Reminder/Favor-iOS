//
//  MyPageHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

import ReactorKit
import SnapKit

final class MyPageHeaderView: StretchyCollectionHeaderView, ReuseIdentifying, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components

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
  
  // MARK: - Binding
  
  func bind(reactor: MyPageHeaderReactor) {
    // Action
    
    // State
    
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
  }

  override func setupLayouts() {
    super.setupLayouts()

    [
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

  override func setupConstraints() {
    super.setupConstraints()

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
