//
//  SignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
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
  
  private lazy var kakaoLoginButton = UIButton.Configuration.makeButton(with: .large)
  
  private lazy var idLoginButton = UIButton.Configuration.makeButton(with: .large)
  
  private lazy var vStack = UIStackView().then {
    $0.axis = .vertical
  }
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SignInReactor) {
    //
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
}
