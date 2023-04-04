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

  public var topSpacing: CGFloat { return 32.0 }
  public var memoMinimumHeight: CGFloat { return 130.0 }

  // MARK: - UI Components

  public lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = true
    scrollView.contentInset = UIEdgeInsets(
      top: self.topSpacing,
      left: .zero,
      bottom: self.topSpacing,
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
  public lazy var selectDatePicker = FavorPickerTextField(pickerType: .date)
  public lazy var selectDateStack = self.makeEditStack(title: "날짜", itemView: selectDatePicker)

  // 알림
  public lazy var selectNotiPicker: FavorPickerTextField = {
    let picker = FavorPickerTextField(pickerType: .custom)
    picker.dataSource = [
      NotifyDays.allCases.compactMap { $0.stringValue },
      ["오전", "오후"],
      (1...12).compactMap { "\($0)시" }
    ]
    picker.width = [120, 80, 100]
    picker.customPickerStringFormat = "%@ %@ %@"
    return picker
  }()
  public lazy var selectNotiStack = self.makeEditStack(title: "알림", itemView: self.selectNotiPicker)

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
    Observable.merge(
      self.memoTextView.rx.didBeginEditing.asObservable(),
      self.memoTextView.rx.didChange.asObservable()
    )
    .flatMap { _ -> Observable<CGFloat> in
      return RxKeyboard.instance.willShowVisibleHeight.map { height in
        return height
      }
      .asObservable()
    }
    .asDriver(onErrorRecover: { _ in return .never()})
    .drive(with: self, onNext: { owner, height in
      owner.scrollToCursor(keyboardHeight: height)
    })
    .disposed(by: self.disposeBag)

    Observable.merge(
      self.scrollView.rx.tapGesture(configuration: { [weak self] recognizer, delegate in
        guard let `self` = self else { return }
        recognizer.delegate = self
        delegate.simultaneousRecognitionPolicy = .never
      })
      .asObservable(),
      self.memoTextView.rx.tapGesture(configuration: { [weak self] recognizer, delegate in
        guard let `self` = self else { return }
        recognizer.delegate = self
        delegate.simultaneousRecognitionPolicy = .never
      })
      .asObservable()
    )
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

    self.stackView.addArrangedSubview(self.editablesStack)
    [
      self.selectFriendStack,
      self.selectDateStack,
      self.selectNotiStack,
      self.memoStack
    ].forEach {
      self.editablesStack.addArrangedSubview($0)
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
  func scrollToCursor(keyboardHeight: CGFloat) {
    if self.memoTextView.isFirstResponder {
      if let selectedRange = self.memoTextView.selectedTextRange?.start {
        let cursorPosition = self.memoTextView.caretRect(for: selectedRange).origin.y
        self.scrollView.scroll(to: self.memoStack.frame.minY - keyboardHeight + cursorPosition)
      }
    }
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
