//
//  NewAlertPopup.swift
//  Favor
//
//  Created by 이창준 on 7/2/23.
//

import UIKit

import FavorKit
import SnapKit

public protocol AlertPopupDelegate: AnyObject {
  func actionDidSelected(_ isAccepted: Bool, from identifier: String)
}

public final class NewAlertPopup: BasePopup {

  // MARK: - Value Types

  public enum AlertType {
    case onlyTitle(title: String, ActionButtons)
    case titleWithDescription(title: String, description: Description, ActionButtons)

    public var popupHeight: CGFloat {
      switch self {
      case .onlyTitle:
        return 184.0
      case let .titleWithDescription(_, description, _):
        let numberOfLines = description.numberOfLines
        let descriptionHeight = CGFloat(integerLiteral: numberOfLines) * 20.0
        let descriptionSpacings = CGFloat(integerLiteral: numberOfLines - 1) * 4.0
        return descriptionHeight + descriptionSpacings + 94.0 + 104.0
      }
    }

    public var title: String {
      switch self {
      case let .onlyTitle(title, _), let .titleWithDescription(title, _, _):
        return title
      }
    }
  }

  public struct Description {
    let description: String
    let numberOfLines: Int
  }

  public struct ActionButtons {
    let reject: String
    let accept: String
  }

  // MARK: - Constants

  private enum Metric {
    static let topInset: CGFloat = 56.0
    static let labelSpacing: CGFloat = 16.0
    static let buttonWidth: CGFloat = 144.0
    static let buttonHeight: CGFloat = 48.0
    static let buttonSpacing: CGFloat = 7.0
    static let bottomInset: CGFloat = 24.0
  }

  // MARK: - Properties

  private var alertType: AlertType
  private let identifier: String
  public weak var delegate: AlertPopupDelegate?

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    return label
  }()

  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.subtext)
    label.textAlignment = .center
    return label
  }()

  private lazy var rejectButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.button)
    config.baseForegroundColor = .favorColor(.subtext)

    let button = UIButton(configuration: config)
    button.layer.cornerRadius = Metric.buttonHeight / 2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(self.handleRejectButtonTap(_:)), for: .touchUpInside)
    return button
  }()

  private lazy var acceptButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.main)
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    button.layer.cornerRadius = Metric.buttonHeight / 2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(self.handleAccepttButtonTap(_:)), for: .touchUpInside)
    return button
  }()

  private let buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = Metric.buttonSpacing
    return stackView
  }()

  // MARK: - Initializer

  public init(_ alertType: AlertType, identifier: String) {
    self.alertType = alertType
    self.identifier = identifier
    super.init(alertType.popupHeight)
    self.setupAlertPopup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions

  private func setupAlertPopup() {
    switch self.alertType {
    case let .onlyTitle(title, actionButtons):
      self.titleLabel.text = title
      self.descriptionLabel.isHidden = true
      self.rejectButton.configuration?.updateAttributedTitle(
        actionButtons.reject,
        font: .favorFont(.bold, size: 16)
      )
      self.acceptButton.configuration?.updateAttributedTitle(
        actionButtons.accept,
        font: .favorFont(.bold, size: 16)
      )
    case let .titleWithDescription(title, description, actionButtons):
      self.titleLabel.text = title
      self.descriptionLabel.isHidden = false
      self.descriptionLabel.text = description.description
      self.descriptionLabel.numberOfLines = description.numberOfLines
      self.rejectButton.configuration?.updateAttributedTitle(
        actionButtons.reject,
        font: .favorFont(.bold, size: 16)
      )
      self.acceptButton.configuration?.updateAttributedTitle(
        actionButtons.accept,
        font: .favorFont(.bold, size: 16)
      )
    }
  }

  @objc
  private func handleRejectButtonTap(_ sender: UIButton) {
    self.delegate?.actionDidSelected(false, from: self.identifier)
  }

  @objc
  private func handleAccepttButtonTap(_ sender: UIButton) {
    self.delegate?.actionDidSelected(true, from: self.identifier)
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    super.setupLayouts()

    [
      self.titleLabel,
      self.descriptionLabel,
      self.buttonStackView
    ].forEach {
      self.containerView.addSubview($0)
    }

    [
      self.rejectButton,
      self.acceptButton
    ].forEach {
      self.buttonStackView.addArrangedSubview($0)
    }
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metric.topInset)
      make.centerX.equalToSuperview()
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.labelSpacing)
      make.centerX.equalToSuperview()
    }

    self.buttonStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().inset(Metric.bottomInset)
    }

    [self.rejectButton, self.acceptButton].forEach {
      $0.snp.makeConstraints { make in
        make.width.equalTo(Metric.buttonWidth)
        make.height.equalTo(Metric.buttonHeight)
      }
    }
  }
}
