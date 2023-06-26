//
//  AuthEntryVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import SnapKit

final class AuthEntryViewController: BaseViewController, View {
  
  // MARK: - Constants

  private enum Metric {
    static let imageViewSize: CGFloat = 180.0
  }

  private enum Typo {
    static let brandName: String = "Favor"
    static let brandSlogan: String = "나의 특별한 선물 기록"
    static let signIn: String = "로그인"
    static let signUp: String = "회원가입"
  }

  // MARK: - Properties
  
  // MARK: - UI Components

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.card)
    return imageView
  }()

  private let brandLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 24)
    label.text = Typo.brandName
    label.textAlignment = .center
    return label
  }()

  private let brandSloganLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.text = Typo.brandSlogan
    label.textAlignment = .center
    return label
  }()

  private let signInButton = FavorLargeButton(with: .main2(Typo.signIn))
  private let signUpButton = FavorPlainButton(with: .navigate(Typo.signUp, isRight: true))

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = 24
    stackView.axis = .vertical
    return stackView
  }()
  
  // MARK: - Binding
  
  func bind(reactor: AuthEntryViewReactor) {
    // Action
    self.rx.viewDidAppear
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.signInButton.rx.tap
      .map { Reactor.Action.signInButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.signUpButton.rx.tap
      .map { Reactor.Action.signUpButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.signInButton,
      self.signUpButton
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    [
      self.imageView,
      self.brandLabel,
      self.brandSloganLabel,
      self.stackView,
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().inset(70)
      make.width.height.equalTo(Metric.imageViewSize)
    }

    self.brandLabel.snp.makeConstraints { make in
      make.top.equalTo(self.imageView.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }

    self.brandSloganLabel.snp.makeConstraints { make in
      make.top.equalTo(self.brandLabel.snp.bottom).offset(12)
      make.centerX.equalToSuperview()
    }

    self.stackView.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(32)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
