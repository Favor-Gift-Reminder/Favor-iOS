//
//  FriendManagementVC.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import UIKit

import FavorKit
import ReactorKit
import Then

public final class FriendManagementViewController: BaseViewController, View {
  
  public enum ViewControllerType {
    case new
    case edit(Friend)
  }
  
  // MARK: - UI Components
  
  private lazy var nameTextField: FavorTextField = FavorTextField().then {
    $0.titleLabelText = "친구 이름"
    switch self.viewControllerType {
    case .new:
      $0.placeholder = "친구 이름 (최대 10자)"
    case .edit:
      break
    }
  }
  
  private let finishButton: FavorButton = {
    let button = FavorButton("완료")
    button.baseBackgroundColor = .white
    button.contentInset = .zero
    button.font = .favorFont(.bold, size: 18.0)
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? FavorButton else { return }
      switch button.state {
      case .disabled:
        button.configuration?.background.backgroundColor = .white
        button.baseForegroundColor = .favorColor(.line2)
      default:
        button.baseForegroundColor = .favorColor(.main)
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }()

  // MARK: - Properties
  
  private let viewControllerType: ViewControllerType
  
  // MARK: - Initializer
  
  init(_ viewControllerType: ViewControllerType) {
    self.viewControllerType = viewControllerType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  public override func setupStyles() {
    let title: String
    switch self.viewControllerType {
    case .new: title = "직접 입력하기"
    case .edit: title = "프로필 수정"
    }
    self.navigationItem.title = title
    self.view.backgroundColor = .favorColor(.white)
    self.navigationItem.rightBarButtonItem = self.finishButton.toBarButtonItem()
    self.finishButton.isEnabled = false
  }
  
  public override func setupLayouts() {
    [
      self.nameTextField
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  public override func setupConstraints() {
    self.nameTextField.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(32.0)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
  // MARK: - Bind
  
  public func bind(reactor: FriendManagementViewReactor) {
    // Action
    self.nameTextField.rx.text.orEmpty
      .scan("") { previous, new in
        if new.count > 10 {
          self.nameTextField.rx.text.onNext(previous)
          return previous
        } else {
          return new
        }
      }
      .map { Reactor.Action.textFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.finishButton.rx.tap
      .map { Reactor.Action.finishButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isEnabledFinishButton }
      .distinctUntilChanged()
      .bind(to: self.finishButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
  }
}
