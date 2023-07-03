//
//  NewLocalAuthPopup.swift
//  Favor
//
//  Created by 이창준 on 7/3/23.
//

import UIKit

import FavorKit
import SnapKit

public protocol NewLocalAuthPopupDelegate: AnyObject {
  func actionDidSelected(_ isAccepted: Bool)
}

public final class NewLocalAuthPopup: BasePopup {

  // MARK: - Constants

  private enum Metric {
    static let topInset: CGFloat = 56.0
    static let alertImageSize: CGFloat = 56.0
    static let titleLabelTopOffset: CGFloat = 24.0
    static let labelSpacing: CGFloat = 16.0
    static let buttonWidth: CGFloat = 144.0
    static let buttonHeight: CGFloat = 48.0
    static let buttonSpacing: CGFloat = 7.0
    static let bottomInset: CGFloat = 24.0
  }

  private enum Typo {
    static let title: String = "경고"
    static let cancelButtonTitle: String = "취소"
    static let confirmButtonTitle: String = "확인"
    static let description: String = """
    암호 분실 시 복구할 수 없습니다.
    신중하게 설정해 주세요!
    """
    static let highlightedDescription: String = "복구할 수 없습니다."
  }

  // MARK: - Properties

  public weak var delegate: NewLocalAuthPopupDelegate?

  // MARK: - UI Components

  private let alertImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.error)?.withTintColor(.favorColor(.main))
    return imageView
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
    label.textColor = .favorColor(.main)
    label.textAlignment = .center
    label.text = Typo.title
    return label
  }()

  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 2
    let attributedString = NSMutableAttributedString(string: Typo.description)
    let range = (Typo.description as NSString).range(of: Typo.highlightedDescription)
    attributedString.addAttribute(.foregroundColor, value: UIColor.favorColor(.main), range: range)
    label.attributedText = attributedString
    return label
  }()

  private lazy var rejectButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.button)
    config.baseForegroundColor = .favorColor(.subtext)
    config.updateAttributedTitle(Typo.cancelButtonTitle, font: .favorFont(.bold, size: 16))

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
    config.updateAttributedTitle(Typo.confirmButtonTitle, font: .favorFont(.bold, size: 16))

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

  // MARK: - Functions

  @objc
  private func handleRejectButtonTap(_ sender: UIButton) {
    self.delegate?.actionDidSelected(false)
  }

  @objc
  private func handleAccepttButtonTap(_ sender: UIButton) {
    self.delegate?.actionDidSelected(true)
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    super.setupLayouts()

    [
      self.alertImageView,
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

    self.alertImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metric.topInset)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(Metric.alertImageSize)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.alertImageView.snp.bottom).offset(Metric.titleLabelTopOffset)
      make.centerX.equalToSuperview()
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.labelSpacing)
      make.centerX.equalToSuperview()
    }

    self.buttonStackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(Metric.bottomInset)
      make.centerX.equalToSuperview()
    }

    [self.rejectButton, self.acceptButton].forEach {
      $0.snp.makeConstraints { make in
        make.width.equalTo(Metric.buttonWidth)
        make.height.equalTo(Metric.buttonHeight)
      }
    }
  }
}
