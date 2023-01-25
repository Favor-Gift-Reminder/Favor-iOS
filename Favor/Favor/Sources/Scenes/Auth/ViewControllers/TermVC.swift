//
//  TermVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/19.
//

import UIKit

import SnapKit

final class TermViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: AuthCoordinator?
  
  // MARK: - UI Components
  
  private lazy var logoImage: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "app.gift.fill")
    imageView.tintColor = .favorColor(.black)
    return imageView
  }()
  
  private lazy var welcomeLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textAlignment = .center
    label.font = .favorFont(.bold, size: 22)
    label.text = "이름 님\n환영합니다"
    return label
  }()
  
  private lazy var startButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .white, title: "시작하기")
    button.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  @objc
  private func startButtonDidTap() {
    self.coordinator?.finish()
  }
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.logoImage,
      self.welcomeLabel,
      self.startButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.logoImage.snp.makeConstraints { make in
      make.width.height.equalTo(70)
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.layoutMarginsGuide).offset(56)
    }
    
    self.welcomeLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.logoImage.snp.bottom).offset(28)
    }
    
    self.startButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(53)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
}
