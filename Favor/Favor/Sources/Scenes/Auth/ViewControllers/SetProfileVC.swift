//
//  SetProfileVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

final class SetProfileViewController: BaseViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var profileImageButton: UIButton = {
    let button = UIButton()
    button.clipsToBounds = true
    button.layer.cornerRadius = 120 / 2
    button.backgroundColor = .favorColor(.box1)
    button.setImage(UIImage(systemName: "person.fill"), for: .normal)
    button.tintColor = .favorColor(.white)
    return button
  }()
  
  private lazy var plusImageView: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.layer.cornerRadius = 24
    button.backgroundColor = .favorColor(.box2)
    button.tintColor = .favorColor(.white)
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private lazy var nameTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.delegate = self
    textField.placeholder = "이름"
    textField.autocapitalizationType = .none
    textField.becomeFirstResponder()
    return textField
  }()
  
  private lazy var idTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.delegate = self
    textField.placeholder = "유저 아이디"
    textField.autocapitalizationType = .none
    return textField
  }()
  
  private lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 50.0
    stackView.addArrangedSubview(self.nameTextField)
    stackView.addArrangedSubview(self.idTextField)
    return stackView
  }()
  
  private lazy var nextButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .white, title: "다음")
    return button
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SetProfileReactor) {
    // Action
    self.profileImageButton.rx.tap
      .map { Reactor.Action.ProfileImageButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tap
      .map { Reactor.Action.nextButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state
      .map { $0.profileImage }
      .bind(to: self.profileImageButton.rx.image(for: .normal))
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.profileImageButton,
      self.plusImageView,
      self.vStack,
      self.nextButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.profileImageButton.snp.makeConstraints { make in
      make.width.height.equalTo(120)
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(56)
    }
    
    self.plusImageView.snp.makeConstraints { make in
      make.width.height.equalTo(48)
      make.bottom.trailing.equalTo(self.profileImageButton)
    }
    
    self.vStack.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageButton.snp.bottom).offset(56)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
    
    self.nextButton.snp.makeConstraints { make in
      make.top.equalTo(self.vStack.snp.bottom).offset(56)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
}

// MARK: - TextField

extension SetProfileViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
  
}
