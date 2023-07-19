//
//  DatePickerTextField.swift
//  Favor
//
//  Created by 김응철 on 2023/03/27.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

public final class FavorDatePickerTextField: UIView {

  // MARK: - PROPERTIES
  
  private let disposeBag = DisposeBag()
  
  /// 실질적으로 사용되는 date 프로퍼티
  /// 변경 가능한 지점
  /// 1. updateDate
  /// 2. 유저 선택
  fileprivate let date = BehaviorRelay<Date?>(value: nil)

  public var pickerMode: UIDatePicker.Mode = .date {
    didSet { self.datePicker.datePickerMode = self.pickerMode }
  }

  public var placeholder: String = "선택" {
    didSet {
      let placeholder = NSAttributedString(
        string: self.placeholder,
        attributes: [
          .foregroundColor: UIColor.favorColor(.explain),
          .font: UIFont.favorFont(.regular, size: 16)
        ]
      )
      self.textField.attributedPlaceholder = placeholder
    }
  }
  
  public var isSelected: Bool = false {
    willSet { self.downButton.isSelected = newValue }
  }

  // MARK: - UI Components

  private let contentsStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    stackView.spacing = 4
    return stackView
  }()
  
  private lazy var downButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
    config.baseForegroundColor = .favorColor(.explain)
    config.baseBackgroundColor = .clear
    
    let btn = UIButton(configuration: config)
    btn.configurationUpdateHandler = { button in
      let image: UIImage? = .favorIcon(.down)?
        .resize(newWidth: 12.0)
        .withRenderingMode(.alwaysTemplate)
      switch button.state {
      case .normal:
        button.configuration?.image = image?.withTintColor(.favorColor(.explain))
        button.configuration?.baseForegroundColor = .favorColor(.explain)
      case .selected:
        button.configuration?.image = image?.withTintColor(.favorColor(.icon))
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      default: break
      }
    }
    return btn
  }()
  
  fileprivate lazy var datePicker: UIDatePicker = {
    let dp = UIDatePicker()
    dp.datePickerMode = .date
    dp.preferredDatePickerStyle = .wheels
    dp.locale = Locale(identifier: "ko_KR")
    return dp
  }()

  private lazy var doneButton = UIBarButtonItem(
    title: "완료",
    style: .plain,
    target: nil,
    action: nil
  )
  private lazy var toolBar: UIToolbar = {
    let tb = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 33)))
    let spacing = UIBarButtonItem(systemItem: .flexibleSpace)
    tb.sizeToFit()
    tb.backgroundColor = .favorColor(.white)
    tb.setItems([spacing, self.doneButton], animated: false)
    return tb
  }()

  fileprivate lazy var textField: UITextField = {
    let tf = UITextField()
    tf.textColor = .favorColor(.icon)
    tf.tintColor = .clear
    tf.font = .favorFont(.regular, size: 16)
    tf.inputView = self.datePicker
    tf.inputAccessoryView = self.toolBar
    return tf
  }()

  // MARK: - INITIALIZER

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - FUNCTIONS

  public func updateDate(_ date: Date?) {
    self.date.accept(date)
  }

  public func updateIsUserInteractable(to isInteractable: Bool) {
    self.textField.isUserInteractionEnabled = isInteractable
    self.downButton.isHidden = !isInteractable
  }

  // MARK: - BINDING
  
  private func bind() {
    self.date
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, date in
        let dateString = owner.pickerMode == .time ? date.toTimeString() : date.toDateString()
        owner.textField.text = dateString
        owner.isSelected = true
      })
      .disposed(by: self.disposeBag)

    self.datePicker.rx.date
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, date in
        if owner.textField.isFirstResponder {
          owner.date.accept(date)
        }
      })
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.textField.resignFirstResponder()
      })
      .disposed(by: self.disposeBag)

    // TextField가 선택되고 휠이 화면에 올라올 때
    self.downButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.popDatePicker()
      })
      .disposed(by: self.disposeBag)
    self.textField.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.popDatePicker()
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - SETUP

extension FavorDatePickerTextField: BaseView {
  public func setupStyles() {
    self.backgroundColor = .clear
  }

  public func setupLayouts() {
    self.addSubview(self.contentsStack)

    [
      self.textField,
      self.downButton
    ].forEach {
      self.contentsStack.addArrangedSubview($0)
    }
  }

  public func setupConstraints() {
    self.contentsStack.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.centerY.equalToSuperview()
    }

    self.downButton.snp.makeConstraints { make in
      make.width.height.equalTo(20)
    }
  }
}

// MARK: - Privates

private extension FavorDatePickerTextField {
  func popDatePicker() {
    self.textField.becomeFirstResponder()
    self.datePicker.setDate(self.date.value ?? .now, animated: true)
  }
}

// MARK: - Reactive

public extension Reactive where Base: FavorDatePickerTextField {
  var date: ControlProperty<Date?> {
    let source = base.date
    let bindingObserver = Binder(self.base) { picker, date in
      picker.date.accept(date)
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }
}
