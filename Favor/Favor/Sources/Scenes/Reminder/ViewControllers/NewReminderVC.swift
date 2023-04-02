//
//  NewReminderVC.swift
//  Favor
//
//  Created by 이창준 on 2023/03/31.
//

import UIKit

import FavorKit
import ReactorKit
import RSKPlaceholderTextView
import RxCocoa
import RxGesture
import RxKeyboard
import SnapKit

final class NewReminderViewController: BaseReminderViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var postButton: UIBarButtonItem = {
    let button = UIBarButtonItem(title: "등록", style: .done, target: nil, action: nil)
    button.setTitleTextAttributes(
      [NSAttributedString.Key.foregroundColor: UIColor.favorColor(.icon)],
      for: .normal
    )
    button.setTitleTextAttributes(
      [NSAttributedString.Key.foregroundColor: UIColor.favorColor(.line2)],
      for: .disabled
    )
    return button
  }()

  // 제목
  private lazy var titleTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이벤트 이름 (최대 20자)"
    return textField
  }()
  private lazy var titleStack = self.makeEditStack(
    title: "제목",
    itemView: titleTextField,
    isDividerNeeded: false
  )

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: NewReminderViewReactor) {
    // Action
    self.rx.viewDidDisappear
      .map { _ in Reactor.Action.viewDidPop }
      .bind(with: self, onNext: { owner, _ in
        if owner.isMovingFromParent {
          reactor.action.onNext(.viewDidPop)
        }
      })
      .disposed(by: self.disposeBag)

    self.postButton.rx.tap
      .map { Reactor.Action.postButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.isPostButtonEnabled }
      .bind(with: self, onNext: { owner, isEnabled in
        owner.postButton.isEnabled = isEnabled
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
    self.title = "새 이벤트"
  }

  override func setupLayouts() {
    self.navigationItem.setRightBarButton(self.postButton, animated: true)

    self.stackView.addArrangedSubview(self.titleStack)

    super.setupLayouts()
  }

  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
    super.setupConstraints()
  }
}
