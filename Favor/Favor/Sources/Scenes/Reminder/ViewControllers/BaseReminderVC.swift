//
//  BaseReminderVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import UIKit

import FavorKit
import RSKPlaceholderTextView
//import RxKeyboard
import RxSwift
import SnapKit

/// 포함된 컴퍼넌트: 스크롤뷰, 받을 사람, 날짜, 알림, 메모
///
/// ⚠️ ScrollView Constraints 설정 필요
class BaseReminderViewController: BaseViewController {

  // MARK: - Properties

  public var isEditable: Bool = false {
    didSet { self.setViewEditable(to: self.isEditable) }
  }

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
      top: .zero,
      left: .zero,
      bottom: self.verticalSpacing,
      right: .zero
    )
    return scrollView
  }()

  // 제목
  public lazy var titleTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이벤트 이름 (최대 20자)"
    textField.hasMessage = false
    return textField
  }()
  public lazy var titleStack = self.makeEditableStack(
    title: "제목",
    itemViews: [self.titleTextField],
    isDividerNeeded: false
  )

  // 받을 사람
  public lazy var friendSelectorButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .main("친구 선택", isRight: true))
    button.contentHorizontalAlignment = .leading
    return button
  }()
  public lazy var friendSelectorStack = self.makeEditableStack(
    title: "받을 사람",
    itemViews: [self.friendSelectorButton]
  )

  // 날짜
  public let dateSelectorTextField = FavorDatePickerTextField()
  public lazy var dateSelectorStack = self.makeEditableStack(
    title: "날짜",
    itemViews: [self.dateSelectorTextField]
  )

  // 알림
  public lazy var notifyDateSelectorButton: UIButton = {
    var config = UIButton.Configuration.plain()
    var titleContainer = AttributeContainer()
    titleContainer.font = .favorFont(.regular, size: 16)
    config.attributedTitle = AttributedString(
      "당일",
      attributes: titleContainer
    )
    config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.background.backgroundColor = .clear
    config.imagePadding = 8
    config.imagePlacement = .trailing

    let button = UIButton(configuration: config)

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
  public lazy var notifyTimeSelectorTextField: FavorDatePickerTextField = {
    let picker = FavorDatePickerTextField()
    picker.pickerMode = .time
    picker.placeholder = "시간 선택"
    return picker
  }()
  public lazy var notifyTimeDateSelectorStack: UIStackView = {
    let stackView = UIStackView(
      arrangedSubviews: [
        self.notifyDateSelectorButton,
        self.notifyTimeSelectorTextField
      ]
    )
    stackView.axis = .horizontal
    stackView.spacing = 16
    return stackView
  }()
  public lazy var notifySelectorStack = self.makeEditableStack(
    title: "알림",
    itemStackView: self.notifyTimeDateSelectorStack
  )
  public let notifySwitch = FavorSwitch()

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
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = .zero
    return textView
  }()
  public lazy var memoStack = self.makeEditableStack(title: "메모", itemViews: [self.memoTextView])

  // MARK: - Binding

  override func bind() {
    self.scrollView.rx.tapGesture(configuration: { [weak self] recognizer, delegate in
      guard let `self` = self else { return }
      recognizer.delegate = self
      delegate.simultaneousRecognitionPolicy = .never
    })
    .when(.recognized)
    .asDriver(onErrorRecover: { _ in return .empty()})
    .drive(with: self, onNext: { owner, _ in
      owner.view.endEditing(true)
    })
    .disposed(by: self.disposeBag)

    self.scrollView.rx.willBeginDragging
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        if owner.memoTextView.isFirstResponder {
          owner.memoTextView.resignFirstResponder()
        }
      })
      .disposed(by: self.disposeBag)

//    RxKeyboard.instance.visibleHeight
//      .asDriver(onErrorRecover: { _ in return .empty()})
//      .drive(with: self, onNext: { owner, height in
//        owner.scrollView.contentInset.bottom = height + self.verticalSpacing
//      })
//      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func makeEditableStack(
    title: String,
    itemViews: [UIView]? = nil,
    itemStackView: UIStackView? = nil,
    isDividerNeeded: Bool = true
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16

    // Title Label
    let titleLabel = self.makeTitleLabel(title: title)

    // Item View
    let itemsContainer = UIView()
    var itemStack = UIStackView()
    if let itemViews {
      itemStack = UIStackView(arrangedSubviews: itemViews)
      itemStack.axis = .horizontal
      itemStack.spacing = 16
    } else if let itemStackView {
      itemStack = itemStackView
    }
    itemsContainer.addSubview(itemStack)

    itemStack.snp.makeConstraints { make in
      if [self.memoTextView, self.titleTextField].contains(itemStack.arrangedSubviews.first) {
        make.edges.equalToSuperview()
      } else {
        make.directionalVerticalEdges.leading.equalToSuperview()
      }
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

  public func setViewEditable(to isEditable: Bool) {
    // 받을 사람
    // 날짜
    self.dateSelectorTextField.updateIsUserInteractable(to: isEditable)
    // 알림
    self.updateNotifyDateSelectorButton(toEditable: isEditable)
    self.notifyTimeSelectorTextField.updateIsUserInteractable(to: isEditable)
    self.notifyTimeDateSelectorStack.spacing = isEditable ? 16 : -16
    self.notifySwitch.isHidden = !isEditable
    // 메모
    self.memoTextView.isUserInteractionEnabled = isEditable
    let placeholderText = isEditable ? "자유롭게 작성해주세요!" : "메모가 없습니다."
    let placeholder = NSAttributedString(
      string: placeholderText,
      attributes: [
        .foregroundColor: UIColor.favorColor(.explain),
        .font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    self.memoTextView.attributedPlaceholder = NSAttributedString(attributedString: placeholder)
  }

  func updateNotifyDateSelectorButton(toEditable isEditable: Bool) {
    self.notifyDateSelectorButton.isUserInteractionEnabled = isEditable
    self.notifyDateSelectorButton.imageView?.isHidden = !isEditable
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)
    self.notifySelectorStack.addSubview(self.notifySwitch)
  }

  override func setupConstraints() {
    self.memoTextView.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(self.memoMinimumHeight)
    }

    self.notifySwitch.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(20)
      make.width.equalTo(40)
      make.height.equalTo(24)
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
    guard
      touch.view?.isDescendant(of: self.memoTextView) == false,
      touch.view?.isDescendant(of: self.notifySwitch) == false
    else { return false }
    return true
  }
}
