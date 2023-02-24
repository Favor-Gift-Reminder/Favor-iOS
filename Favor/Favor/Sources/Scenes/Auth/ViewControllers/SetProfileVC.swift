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
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = UIImage(named: "ic_person")?.withTintColor(.favorColor(.white))
    
    let button = UIButton(configuration: config)
    button.clipsToBounds = true
    button.layer.cornerRadius = 120 / 2
    return button
  }()
  
  private lazy var plusImageView: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line2)
    config.baseForegroundColor = .favorColor(.white)
    config.image = UIImage(named: "ic_add")?.withTintColor(.favorColor(.white))
    
    let button = UIButton()
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.layer.cornerRadius = 24
    button.backgroundColor = .favorColor(.line2)
    button.tintColor = .favorColor(.white)
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private lazy var nameTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이름"
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private lazy var idTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "유저 아이디"
    textField.textField.returnKeyType = .done
    
    let label = UILabel()
    label.text = "@"
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    
    textField.addLeftItem(item: label)
    
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
    let button = LargeFavorButton(with: .main("다음"))
    return button
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SetProfileViewReactor) {
    // Action
    Observable.just(())
      .bind(with: self, onNext: { owner, _ in
        owner.nameTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.profileImageButton.rx.tap
      .map { Reactor.Action.ProfileImageButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nameTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.idTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.idTextField.rx.editingDidEndOnExit
      .map { Reactor.Action.returnKeyboardTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tap
      .map { Reactor.Action.nextButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state
      .skip(1)
      .map { $0.profileImage }
      .asDriver(onErrorJustReturn: nil)
      .drive(with: self, onNext: { owner, image in
        owner.profileImageButton.setImage(image, for: .normal)
      })
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
