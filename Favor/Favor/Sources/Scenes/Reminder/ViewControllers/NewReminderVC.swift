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
import SnapKit

final class NewReminderViewController: BaseEventEditViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 32.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = true
    scrollView.contentInset = UIEdgeInsets(top: Metric.topSpacing, left: 0, bottom: 0, right: 0)
    return scrollView
  }()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 40
    return stackView
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

  // 받을 사람
  private lazy var selectFriendButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .main("친구 선택", isRight: true))
    button.contentHorizontalAlignment = .leading
    return button
  }()
  private lazy var selectFriendStack = self.makeEditStack(
    title: "받을 사람",
    itemView: self.selectFriendButton
  )

  // 날짜
  private lazy var selectDateStack = self.makeEditStack(title: "날짜", itemView: UIView())

  // 알림
  private lazy var selectNotiStack = self.makeEditStack(title: "알림", itemView: UIView())

  // 메모
  private lazy var memoTextView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    let attributedPlaceholder = NSAttributedString(
      string: "자유롭게 작성해주세요!",
      attributes: [
        .foregroundColor: UIColor.favorColor(.explain),
        .font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    textView.attributedPlaceholder = attributedPlaceholder
    textView.textColor = .favorColor(.explain)
    textView.font = .favorFont(.regular, size: 16)
    textView.backgroundColor = .clear
    return textView
  }()
  private lazy var memoStack = self.makeEditStack(title: "메모", itemView: self.memoTextView)

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

    self.memoTextView.rx.didBeginEditing
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.scrollToBottom()
      })
      .disposed(by: self.disposeBag)

    self.memoTextView.rx.didChange
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.scrollToBottom()
      })
      .disposed(by: self.disposeBag)

    self.memoTextView.rx.didEndEditing
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.scrollToBottom()
      })
      .disposed(by: self.disposeBag)

    self.scrollView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.view.endEditing(true)
        owner.scrollView.scroll(to: .zero)
      })
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)

    self.scrollView.addSubview(self.stackView)

    [
      self.titleStack,
      self.selectFriendStack,
      self.selectDateStack,
      self.selectNotiStack,
      self.memoStack
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }

  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }

    self.memoTextView.snp.makeConstraints { make in
      make.height.equalTo(130)
    }
  }
}

// MARK: - Privates

private extension NewReminderViewController {
  func scrollToBottom() {
    self.scrollView.scroll(to: self.memoTextView.frame.maxY + self.memoTextView.contentSize.height)
  }
}
