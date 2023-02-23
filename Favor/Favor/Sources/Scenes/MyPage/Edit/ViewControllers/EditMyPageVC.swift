//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import ReactorKit
import SnapKit

final class EditMyPageViewController: BaseViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.alwaysBounceVertical = true
    scrollView.contentInsetAdjustmentBehavior = .never
    return scrollView
  }()

  private lazy var backgroundImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .systemBlue
    config.background.cornerRadius = 0

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var profileImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = 60
    config.baseBackgroundColor = .systemYellow

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var nameTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.titleLabelText = "이름"
    textField.placeholder = "이름"
    textField.updateMessageLabel("이름을 입력", state: .normal, animated: false)
    return textField
  }()

  private lazy var idTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.textField.keyboardType = .asciiCapable
    textField.titleLabelText = "ID"
    textField.placeholder = "@ID1234"
    textField.isSecureField = true
    return textField
  }()

  private lazy var textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    stackView.isLayoutMarginsRelativeArrangement = true
    [
      self.nameTextField,
      self.idTextField
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: EditMyPageReactor) {
    // Action
    self.nameTextField.rx.textIsEditing
      .filter { $0 != nil }
      .subscribe(with: self, onNext: { _, text in
        print(text)
      })
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.nameTextField.updateMessageLabel("", state: .normal)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
      self.nameTextField.updateMessageLabel("erer", state: .error)
    }
  }

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)

    [
      self.backgroundImageButton,
      self.profileImageButton,
      self.textFieldStackView
    ].forEach {
      self.scrollView.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.backgroundImageButton.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(297)
    }

    self.profileImageButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.backgroundImageButton.snp.bottom)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(120)
    }

    self.textFieldStackView.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageButton.snp.bottom).offset(40)
      make.centerX.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.scrollView.snp.makeConstraints { make in
      make.bottom.equalTo(self.textFieldStackView.snp.bottom)
    }
  }
}
