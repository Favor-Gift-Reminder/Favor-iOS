//
//  BaseReminderVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import UIKit

import FavorKit
import RSKPlaceholderTextView
import RxKeyboard
import RxSwift
import SnapKit

/// 포함된 컴퍼넌트: 받을 사람, 날짜, 알림, 메모
///
/// ⚠️ ScrollView Constraints 설정 필요
class BaseReminderViewController: BaseViewController {

  // MARK: - Properties

  public var verticalSpacing: CGFloat { return 32.0 }
  public var memoMinimumHeight: CGFloat { return 130.0 }
  public var memoStackMinY: CGFloat { return self.memoStack.frame.minY }

  // MARK: - UI Components

  public lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = true
    scrollView.contentInset = UIEdgeInsets(
      top: self.verticalSpacing,
      left: .zero,
      bottom: self.verticalSpacing,
      right: .zero
    )
    return scrollView
  }()

  public lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    return stackView
  }()

  public lazy var editablesStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 40
    stackView.layoutMargins = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    stackView.isLayoutMarginsRelativeArrangement = true
    return stackView
  }()

  // 받을 사람
  public lazy var selectFriendButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .main("친구 선택", isRight: true))
    button.contentHorizontalAlignment = .leading
    return button
  }()
  public lazy var selectFriendStack = self.makeEditStack(
    title: "받을 사람",
    itemView: self.selectFriendButton
  )

  // 날짜
  public lazy var selectDatePicker = FavorDatePickerTextField()
  public lazy var selectDateStack = self.makeEditStack(title: "날짜", itemView: selectDatePicker)

  // 알림
  public lazy var notifyDateSelectorButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .main("당일", isRight: false))
    button.showsMenuAsPrimaryAction = true
    button.changesSelectionAsPrimaryAction = false

    let actions = NotifyDays.allCases.compactMap { day in
      UIAction(title: day.stringValue, handler: { _ in
        self.updateNotiDayButton(title: day.stringValue)
      })
    }
    let buttonMenu = UIMenu(title: "알림 기간", children: actions)
    button.menu = buttonMenu
    return button
  }()
  public lazy var notifyTimeSelectorButton: FavorDatePickerTextField = {
    let picker = FavorDatePickerTextField()
    return picker
  }()
  public lazy var notifySelectorButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillProportionally
    stackView.spacing = 16
    return stackView
  }()
  public lazy var selectNotiStack = self.makeEditStack(
    title: "알림",
    itemView: self.notifySelectorButtonStack
  )

  // 메모
  public lazy var memoTextView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    let attributedPlaceholder = NSAttributedString(
      string: "자유롭게 작성해주세요!",
      attributes: [
        .foregroundColor: UIColor.favorColor(.explain),
        .font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    textView.attributedPlaceholder = attributedPlaceholder
    textView.textColor = .favorColor(.icon)
    textView.font = .favorFont(.regular, size: 16)
    textView.backgroundColor = .clear
    textView.isScrollEnabled = false
    return textView
  }()
  public lazy var memoStack = self.makeEditStack(title: "메모", itemView: self.memoTextView)

  // MARK: - Binding

  override func bind() {
    self.scrollView.rx.tapGesture(configuration: { [weak self] recognizer, delegate in
      guard let `self` = self else { return }
      recognizer.delegate = self
      delegate.simultaneousRecognitionPolicy = .never
    })
    .when(.recognized)
    .asDriver(onErrorRecover: { _ in return .never()})
    .drive(with: self, onNext: { owner, _ in
      owner.view.endEditing(true)
    })
    .disposed(by: self.disposeBag)

    self.scrollView.rx.willBeginDragging
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        if owner.memoTextView.isFirstResponder {
          owner.memoTextView.resignFirstResponder()
        }
      })
      .disposed(by: self.disposeBag)

    RxKeyboard.instance.visibleHeight
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, height in
        owner.scrollView.contentInset.bottom = height + self.verticalSpacing
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func makeEditStack(
    title: String,
    itemView: UIView,
    isDividerNeeded: Bool = true
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .equalSpacing
    stackView.alignment = .leading

    // Title Label
    let titleLabel = self.makeTitleLabel(title: title)

    // Divider
    let divider = FavorDivider()
    divider.isHidden = isDividerNeeded ? false : true

    [
      titleLabel,
      itemView,
      divider
    ].forEach {
      stackView.addArrangedSubview($0)
    }

    return stackView
  }

  public func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textAlignment = .left
    label.text = title
    return label
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.stackView)

    [
      self.selectFriendStack,
      self.selectDateStack,
      self.selectNotiStack,
      self.memoStack
    ].forEach {
      self.editablesStack.addArrangedSubview($0)
    }
    self.stackView.addArrangedSubview(self.editablesStack)

    [
      self.notifyDateSelectorButton,
      self.notifyTimeSelectorButton
    ].forEach {
      self.notifySelectorButtonStack.addArrangedSubview($0)
    }
  }

  override func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }

    self.memoTextView.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(self.memoMinimumHeight)
    }
  }
}

// MARK: - Privates

private extension BaseReminderViewController {
  func updateNotiDayButton(title: String) {
    self.notifyDateSelectorButton.configuration?.updateAttributedTitle(
      title,
      font: .favorFont(.regular, size: 16)
    )
  }
}

// MARK: - Recognizer

extension BaseReminderViewController: UIGestureRecognizerDelegate {
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    guard touch.view?.isDescendant(of: self.memoTextView) == false else { return false }
    return true
  }
}
