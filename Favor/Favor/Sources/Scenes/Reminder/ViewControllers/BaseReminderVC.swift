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

  // 받을 사람
  public lazy var selectFriendButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .main("친구 선택", isRight: true))
    button.contentHorizontalAlignment = .leading
    return button
  }()
  public lazy var selectFriendStack = self.makeEditStack(
    title: "받을 사람",
    itemViews: [self.selectFriendButton]
  )

  // 날짜
  public lazy var selectDatePicker = FavorDatePickerTextField()
  public lazy var selectDateStack = self.makeEditStack(
    title: "날짜",
    itemViews: [self.selectDatePicker]
  )

  // 알림
  public lazy var notifyDateSelectorButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .main("당일", isRight: false))
    button.configuration?.background.backgroundColor = .clear
    button.configuration?.imagePadding = 8

    button.configurationUpdateHandler = { button in
      var config = button.configuration
      switch button.state {
      case .normal:
        config?.image = .favorIcon(.down)?
          .withTintColor(.favorColor(.explain), renderingMode: .alwaysTemplate)
          .resize(newWidth: 12)
        config?.baseForegroundColor = .favorColor(.explain)
      case .selected:
        config?.image = .favorIcon(.down)?
          .withTintColor(.favorColor(.icon), renderingMode: .alwaysTemplate)
          .resize(newWidth: 12)
        config?.baseForegroundColor = .favorColor(.icon)
      default: break
      }
      button.configuration = config
    }

    button.showsMenuAsPrimaryAction = true
    button.changesSelectionAsPrimaryAction = false

    let actions = NotifyDays.allCases.compactMap { day in
      UIAction(title: day.stringValue, handler: { _ in
        self.updateNotifyDateSelectorButton(title: day.stringValue)
      })
    }
    let buttonMenu = UIMenu(title: "알림 기간", children: actions)
    button.menu = buttonMenu

    button.setContentHuggingPriority(.defaultHigh, for: .vertical)

    return button
  }()
  public lazy var notifyTimePicker: FavorDatePickerTextField = {
    let picker = FavorDatePickerTextField()
    picker.pickerMode = .time
    picker.placeholder = "시간 선택"
    return picker
  }()
  public lazy var selectNotiStack = self.makeEditStack(
    title: "알림",
    itemViews: [self.notifyDateSelectorButton, self.notifyTimePicker]
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
  public lazy var memoStack = self.makeEditStack(title: "메모", itemViews: [self.memoTextView])

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
    itemViews: [UIView],
    isDividerNeeded: Bool = true
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16

    // Title Label
    let titleLabel = self.makeTitleLabel(title: title)

    // Item View
    let itemsContainer = UIView()
    let itemStack = UIStackView(arrangedSubviews: itemViews)
    itemStack.axis = .horizontal
    itemStack.spacing = 16
    itemsContainer.addSubview(itemStack)
    itemStack.snp.makeConstraints { make in
      make.directionalVerticalEdges.leading.equalToSuperview()
    }

    // Divider
    let divider = FavorDivider()
    divider.isHidden = isDividerNeeded ? false : true

    [
      titleLabel,
      itemsContainer,
      divider
    ].forEach {
      stackView.addArrangedSubview($0)
    }

    stackView.layoutMargins = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    stackView.isLayoutMarginsRelativeArrangement = true

    return stackView
  }

  public func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textAlignment = .left
    label.text = title
    return label
  }

  public func updateNotifyDateSelectorButton(state isEditable: Bool) {
    self.notifyDateSelectorButton.isUserInteractionEnabled = isEditable
    let downIcon: UIImage? = .favorIcon(.down)?
      .resize(newWidth: 12)
      .withTintColor(.favorColor(.explain), renderingMode: .alwaysTemplate)
    self.notifyDateSelectorButton.configuration?.image = isEditable ? downIcon : nil
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)
  }

  override func setupConstraints() {
    self.memoTextView.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(self.memoMinimumHeight)
    }
  }
}

// MARK: - Privates

private extension BaseReminderViewController {
  func updateNotifyDateSelectorButton(title: String) {
    self.notifyDateSelectorButton.configuration?.updateAttributedTitle(
      title,
      font: .favorFont(.regular, size: 16)
    )
    self.notifyDateSelectorButton.isSelected = true
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
