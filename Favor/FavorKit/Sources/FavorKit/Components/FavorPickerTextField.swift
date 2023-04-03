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

/// TODO: -
///  - `downButton` 숨김 / 표시 메서드 (애니메이션과 함께)

/// `.custom` 타입일 경우 필요한 프로퍼티들:
/// `dataSource`, `width`, `customPickerStringFormat`
public final class FavorPickerTextField: UIView {

  // MARK: - CONSTANTS

  public enum PickerType {
    case date, custom
  }

  // MARK: - PROPERTIES

  /// custom Picker 선택 시 포함되는 데이터들
  public var dataSource: [[String]] = []
  /// custom Picker 선택 시 각 Component들의 너비
  public var width: [CGFloat] = []
  /// custom Picker 선택 시 TextField에 표현되는 String의 Format
  public var customPickerStringFormat: String = ""

  public var currentDateString: String? {
    didSet { self.downButton.isSelected = true }
  }

  public var pickerType: PickerType = .custom {
    didSet { self.updatePickerType(to: self.pickerType) }
  }
  
  // MARK: - UI
  
  private let contentsView = UIView()
  
  private lazy var downButton: UIButton = {
    let btn = UIButton()
    let downIcon = UIImage.favorIcon(.down)?
      .resize(newWidth: 12)
    btn.setImage(
      downIcon?.withTintColor(.favorColor(.explain), renderingMode: .alwaysOriginal),
      for: .normal
    )
    btn.setImage(
      downIcon?.withTintColor(.favorColor(.icon), renderingMode: .alwaysOriginal),
      for: .selected
    )
    btn.addTarget(self, action: #selector(didTapDownButton), for: .touchUpInside)
    return btn
  }()

  private lazy var customPicker: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.delegate = self
    pickerView.dataSource = self
    return pickerView
  }()
  
  private lazy var datePicker: UIDatePicker = {
    let dp = UIDatePicker()
    dp.datePickerMode = .date
    dp.preferredDatePickerStyle = .wheels
    dp.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
    dp.locale = Locale(identifier: "ko_KR")
    return dp
  }()
  
  private lazy var toolBar: UIToolbar = {
    // 초기값을 주지 않으면 Constraints Warning 발생..
    let tb = UIToolbar(frame: CGRect(
      origin: .zero,
      size: CGSize(width: 100, height: 35)
    ))
    let doneBtn = UIBarButtonItem(
      title: "완료",
      style: .plain,
      target: self,
      action: #selector(didTapDoneButton)
    )
    tb.backgroundColor = .favorColor(.white)
    tb.setItems([doneBtn], animated: false)
    tb.sizeToFit()
    return tb
  }()
  
  fileprivate lazy var textField: UITextField = {
    let tf = UITextField()
    let placeholder = NSAttributedString(
      string: "날짜 선택",
      attributes: [
        .foregroundColor: UIColor.favorColor(.explain),
        .font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    tf.attributedPlaceholder = placeholder
    tf.textColor = .favorColor(.icon)
    tf.tintColor = .clear
    tf.font = .favorFont(.regular, size: 16)
    tf.inputAccessoryView = self.toolBar
    return tf
  }()
  
  // MARK: - INITIALIZER
  
  private override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(pickerType type: PickerType) {
    self.init(frame: .zero)
    self.updatePickerType(to: type)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - SELECTORS
  
  @objc
  private func datePickerDidChange() {
    let dateString = self.datePicker.date.toString()
    self.textField.text = dateString
    self.currentDateString = dateString
  }
  
  @objc
  private func didTapDoneButton() {
    self.textField.resignFirstResponder()
  }
  
  @objc
  private func didTapDownButton() {
    self.textField.becomeFirstResponder()
  }

  // MARK: - FUNCTIONS

  public func updateIsUserInteractable(to isInteractable: Bool) {
    self.textField.isUserInteractionEnabled = isInteractable
    let animator = UIViewPropertyAnimator(
      duration: TimeInterval(0.2),
      curve: .easeInOut,
      animations: {
        self.downButton.alpha = isInteractable ? 1.0 : 0.0
      }
    )
    animator.startAnimation()
  }
}

// MARK: - PRIVATES

private extension FavorPickerTextField {
  func updatePickerType(to type: PickerType) {
    self.textField.inputView = type == .date ? self.datePicker : self.customPicker
  }
}

// MARK: - SETUP

extension FavorPickerTextField: BaseView {
  public func setupStyles() {
    self.backgroundColor = .favorColor(.white)
  }
  
  public func setupLayouts() {
    self.addSubview(self.contentsView)
    
    [
      self.textField,
      self.downButton
    ].forEach {
      self.contentsView.addSubview($0)
    }
  }
  
  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(19)
      make.width.greaterThanOrEqualTo(130)
    }
    
    self.contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.textField.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.downButton.snp.makeConstraints { make in
      make.leading.equalTo(self.textField.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
    }
  }
}

// MARK: - PickerView

extension FavorPickerTextField: UIPickerViewDelegate, UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    self.dataSource.count
  }

  public func pickerView(
    _ pickerView: UIPickerView,
    numberOfRowsInComponent component: Int
  ) -> Int {
    self.dataSource[component].count
  }

  public func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 18)
    label.text = self.dataSource[component][row]
    return label
  }

  public func pickerView(
    _ pickerView: UIPickerView,
    widthForComponent component: Int
  ) -> CGFloat {
    guard self.width.count == self.dataSource.count else {
      fatalError("Given width and dataSource's size is different. That's illegal")
    }
    return self.width[component]
  }

  public func pickerView(
    _ pickerView: UIPickerView,
    didSelectRow row: Int,
    inComponent component: Int
  ) {
    let selectedRows = (0..<self.dataSource.count).map {
      pickerView.selectedRow(inComponent: $0)
    }

    var selectedValues: [String] = []
    selectedRows.enumerated().forEach { index, row in
      selectedValues.append(self.dataSource[index][row])
    }
    self.textField.text = String(format: self.customPickerStringFormat, arguments: selectedValues)
  }
}

// MARK: - Reactive

public extension Reactive where Base: FavorPickerTextField {
  var text: Binder<String> {
    Binder(base) { base, text in
      base.textField.text = text
    }
  }
}
