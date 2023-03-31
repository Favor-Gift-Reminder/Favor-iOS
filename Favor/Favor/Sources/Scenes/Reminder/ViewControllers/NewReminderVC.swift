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
import SnapKit

final class NewReminderViewController: BaseViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = true
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
  private lazy var selectFriendButton = FavorPlainButton(with: .main("친구 선택", isRight: true))
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
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(32)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
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
  func makeEditStack(
    title: String,
    itemView: UIView,
    isDividerNeeded: Bool = true
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .fillProportionally

    // Title Label
    let titleLabel = self.makeTitleLabel(title: title)

    // Divider
    let divider = FavorDivider()
    divider.layer.opacity = isDividerNeeded ? 1.0 : 0.0

    [
      titleLabel,
      itemView,
      divider
    ].forEach {
      stackView.addArrangedSubview($0)
    }

    return stackView
  }

  func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textAlignment = .left
    label.text = title
    return label
  }
}
