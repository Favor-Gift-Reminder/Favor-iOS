//
//  TermAcceptAllView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/03.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol TermAcceptAllViewDelegate: AnyObject {
  func acceptAllDidSelected()
}

public final class TermAcceptAllView: UIView {

  // MARK: - Constants

  private enum Typo {
    static let agreeAllTitle: String = "약관 전체동의"
  }

  // MARK: - Properties

  public weak var delegate: TermAcceptAllViewDelegate?

  // MARK: - UI Components

  private let checkButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.image = .favorIcon(.uncheck)?
          .withRenderingMode(.alwaysTemplate)
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .selected:
        button.configuration?.image = .favorIcon(.checkFilled)?
          .withRenderingMode(.alwaysTemplate)
        button.configuration?.baseForegroundColor = .favorColor(.main)
      default:
        break
      }
    }
    return button
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.text = Typo.agreeAllTitle
    return label
  }()

  private lazy var button: UIButton = {
    let button = UIButton()
    button.addTarget(self, action: #selector(self.buttonDidTap), for: .touchUpInside)
    return button
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

  public func updateCheckButton(isAllAccepted: Bool) {
    self.checkButton.isSelected = isAllAccepted
  }

  @objc
  func buttonDidTap() {
    self.delegate?.acceptAllDidSelected()
  }
}

// MARK: - UI Setup

extension TermAcceptAllView: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.checkButton,
      self.titleLabel,
      self.button
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.checkButton.snp.makeConstraints { make in
      make.leading.directionalVerticalEdges.equalToSuperview()
      make.width.equalTo(self.checkButton.snp.height)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.checkButton.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview()
    }

    self.button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
