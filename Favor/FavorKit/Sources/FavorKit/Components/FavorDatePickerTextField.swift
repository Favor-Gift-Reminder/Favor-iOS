//
//  DatePickerTextField.swift
//  Favor
//
//  Created by 김응철 on 2023/03/27.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

public final class FavorDatePickerTextField: UIView {

  // MARK: - PROPERTIES

  private let disposeBag = DisposeBag()

  public var pickerMode: UIDatePicker.Mode = .date {
    didSet { self.datePicker.datePickerMode = self.pickerMode }
  }

  /// DatePicker의 `date` 프로퍼티를 Optional하게 래핑한 프로퍼티
  fileprivate let optionalDate = PublishRelay<Date?>()

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
    didSet { self.downButton.isSelected = self.isSelected }
  }

  // MARK: - UI

  private let contentsStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.alignment = .leading
    stackView.spacing = 4
    return stackView
  }()

  private lazy var downButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.down)?.resize(newWidth: 12).withRenderingMode(.alwaysTemplate)
    config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
    config.baseForegroundColor = .favorColor(.explain)
    config.baseBackgroundColor = .clear

    let btn = UIButton(configuration: config)
    btn.configurationUpdateHandler = { button in
      switch button.state {
      case .normal: button.configuration?.baseForegroundColor = .favorColor(.explain)
      case .selected: button.configuration?.baseForegroundColor = .favorColor(.icon)
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

  public func updateIsUserInteractable(to isInteractable: Bool) {
    self.textField.isUserInteractionEnabled = isInteractable
    self.downButton.isHidden = !isInteractable
  }

  public func finishEditMode() {
    self.textField.resignFirstResponder()
  }

  // MARK: - BINDING

  private func bind() {
    self.datePicker.rx.date
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, date in
        let dateString = self.pickerMode == .time ? date.toTimeString() : date.toDateString()
        owner.textField.text = dateString
        owner.optionalDate.accept(date)
      })
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.textField.resignFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.downButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.textField.becomeFirstResponder()
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
    }

    self.downButton.snp.makeConstraints { make in
      make.width.height.equalTo(20)
    }
  }
}

// MARK: - Reactive

public extension Reactive where Base: FavorDatePickerTextField {
  var date: ControlProperty<Date> {
    let source = base.datePicker.rx.date
    let bindingObserver = Binder(self.base) { (picker, date: Date) in
      picker.datePicker.date = date
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }

  ///
  var optionalDate: ControlProperty<Date?> {
    let source = base.optionalDate
    let bindingObserver = Binder(self.base) { (picker, date: Date?) in
      if let date {
        picker.optionalDate.accept(date)
        picker.datePicker.date = date
      } else { // nil
        picker.optionalDate.accept(date)
      }
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }

  var dateString: ControlProperty<String?> {
    let source = base.textField.rx.text
    let bindingObserver = Binder(self.base) { (picker, dateString: String?) in
      picker.textField.text = dateString
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }
}
