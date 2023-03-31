//
//  DatePickerTextField.swift
//  Favor
//
//  Created by 김응철 on 2023/03/27.
//

import UIKit

import FavorKit

final class FavorDatePickerTextField: UIView {
  
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
  
  private lazy var datePicker: UIDatePicker = {
    let dp = UIDatePicker()
    dp.datePickerMode = .date
    dp.preferredDatePickerStyle = .wheels
    dp.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
    dp.locale = .init(identifier: "ko_KR")
    return dp
  }()
  
  private lazy var toolBar: UIToolbar = {
    let tb = UIToolbar()
    let doneBtn = UIBarButtonItem(
      title: "완료",
      style: .plain,
      target: self,
      action: #selector(didTapDoneButton)
    )
    tb.sizeToFit()
    tb.backgroundColor = .favorColor(.white)
    tb.setItems([doneBtn], animated: false)
    return tb
  }()
  
  private lazy var textField: UITextField = {
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
    tf.inputView = self.datePicker
    tf.inputAccessoryView = self.toolBar
    return tf
  }()
  
  // MARK: - PROPERTIES
  
  var currentDateString: String? {
    didSet { self.downButton.isSelected = true }
  }
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - SELECTORS
  
  @objc
  private func didChangeDate() {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    let dateString = formatter.string(from: self.datePicker.date)
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
}

// MARK: - SETUP

extension FavorDatePickerTextField: BaseView {
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
      make.height.equalTo(19)
      make.width.equalTo(130)
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
