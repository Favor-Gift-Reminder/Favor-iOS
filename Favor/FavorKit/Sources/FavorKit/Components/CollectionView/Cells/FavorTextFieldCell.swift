//
//  FavorTextFieldCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/01.
//

import UIKit

import Reusable
import SnapKit

open class FavorTextFieldCell: BaseCollectionViewCell, Reusable {

  // MARK: - UI Components

  private let textField: UITextField = {
    let textField = UITextField()
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
    self.textField.placeholder = placeholder
  }
}

// MARK: - UI Setups

extension FavorTextFieldCell: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    self.addSubview(self.textField)
  }

  public func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
