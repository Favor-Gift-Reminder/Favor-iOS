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

open class FavorTextFieldCell: BaseCollectionViewCell, Reusable {

  public var text: String? {
    self.textField.text
  }

  // MARK: - UI Components

  public let textField: UITextField = {
    let textField = UITextField()
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
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
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bind

  public func bind(placeholder: String) {
    self.textField.updateAttributedPlaceholder(placeholder, font: .favorFont(.regular, size: 16))
    self.textField.placeholder = placeholder
  }

  public func bind(text: String?) {
    self.textField.text = text
  }
}

// MARK: - UI Setups

extension FavorTextFieldCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.addSubview(self.textField)
  }

  public func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - Reactive

public extension Reactive where Base: FavorTextFieldCell {
  var text: ControlEvent<String?> {
    return ControlEvent(events: base.textField.rx.text)
  }
}
