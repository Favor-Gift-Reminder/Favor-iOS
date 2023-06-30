//
//  FavorKeypadTextField.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import SnapKit

public final class FavorKeypadTextField: UIView {

  // MARK: - Properties

  private var inputs: [KeypadInput] = [] {
    didSet { self.updateKeypadTexts() }
  }

  // MARK: - UI Components

  private var keypadTexts: [FavorKeypadText] = [
    FavorKeypadText(), FavorKeypadText(), FavorKeypadText(), FavorKeypadText()
  ]

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    return stackView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func updateKeypadInputs(_ inputs: [KeypadInput]) {
    self.inputs = inputs
  }

  private func updateKeypadTexts() {
    zip(self.keypadTexts, self.inputs).forEach { (keypadText: FavorKeypadText, input: KeypadInput) in
      keypadText.updateText(with: input)
    }
  }
}

// MARK: - UI Setups

extension FavorKeypadTextField: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.addSubview(self.stackView)

    self.keypadTexts.forEach {
      self.stackView.addArrangedSubview($0)
    }
  }

  public func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
