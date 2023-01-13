//
//  SignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import UIKit

import ReactorKit
import SnapKit
import Then

final class SignInViewController: BaseViewController, View {
  typealias Reactor = SignInReactor
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var idTextField = {
    let textField = BaseTextField()
    return textField
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SignInReactor) {
    //
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [self.idTextField].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.idTextField.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
}
