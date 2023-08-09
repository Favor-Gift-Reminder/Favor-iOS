//
//  FavorTextFieldCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import Reusable
import RxCocoa
import RxSwift
import SnapKit

public protocol FavorTextFieldCellDelegate: AnyObject {
  func textField(textFieldCell cell: FavorTextFieldCell, didUpdate text: String?)
}

open class FavorTextFieldCell: BaseCollectionViewCell, Reusable {
  
  // MARK: - Properties
  
  public weak var delegate: FavorTextFieldCellDelegate?
  
  public var text: String? {
    self.textField.text
  }
  
  /// `textField`가 왼쪽을 기준으로 떨어져 있는 정도입니다.
  private var textFieldLeadingSpacing: Constraint?

  // MARK: - UI Components
  
  /// `@`가 적혀있는 `UILabel`
  private let atSignLabel: UILabel = {
    let label = UILabel()
    label.text = "@"
    label.textColor = .favorColor(.icon)
    label.font = .favorFont(.regular, size: 16.0)
    label.isHidden = true
    return label
  }()
  
  public let textField: UITextField = {
    let textField = UITextField()
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.clearButtonMode = .whileEditing
    textField.font = .favorFont(.regular, size: 16)
    textField.textColor = .favorColor(.icon)
    return textField
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions
  
  private func bind() {
    self.textField.rx.text
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, text in
        owner.delegate?.textField(textFieldCell: self, didUpdate: text)
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Bind
  
  public func bind(placeholder: String) {
    self.textField.updateAttributedPlaceholder(placeholder, font: .favorFont(.regular, size: 16))
    self.textField.placeholder = placeholder
    if placeholder == "ID" {
      self.atSignLabel.isHidden = false
      self.textFieldLeadingSpacing?.update(inset: 20.0)
    }
  }
  
  public func bind(text: String?) {
    self.textField.text = text
  }
  
  @discardableResult
  open override func becomeFirstResponder() -> Bool {
    self.textField.becomeFirstResponder()
  }
}

// MARK: - UI Setups

extension FavorTextFieldCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.atSignLabel,
      self.textField
    ].forEach {
      self.addSubview($0)
    }
  }
  
  public func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.top.trailing.bottom.equalToSuperview()
      self.textFieldLeadingSpacing = make.leading.equalToSuperview().constraint
    }
    
    self.atSignLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.textField)
      make.leading.equalToSuperview()
    }
  }
}
