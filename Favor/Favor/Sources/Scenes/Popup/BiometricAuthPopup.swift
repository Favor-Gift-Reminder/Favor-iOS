//
//  BiometricAuthPopup.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import DeviceKit
import FavorKit
import RxCocoa
import RxFlow
import SnapKit

public final class BiometricAuthPopup: BasePopup, Stepper {

  // MARK: - Constants

  private enum Metric {
    static let topInset: CGFloat = 56.0
    static let buttonHorizontalInset: CGFloat = 20.0
    static let buttonBottomInset: CGFloat = 24.0
    static let buttonWidth: CGFloat = 144.0
    static let buttonHeight: CGFloat = 48.0
  }

  private enum Typo {
    static let titleString: String = "생체 인증"
    static var subtitleString: String {
      let device = Device.current
      if device.isFaceIDCapable {
        return "빠른 이용을 위해\nFace ID를 사용하세요."
      } else if device.isTouchIDCapable {
        return "빠른 이용을 위해\nTouch ID를 사용하세요."
      } else {
        return ""
      }
    }
    static let rejectButtonTitle: String = "암호 사용하기"
    static var confirmButtonTitle: String {
      let device = Device.current
      if device.isFaceIDCapable {
        return "Face ID 사용하기"
      } else if device.isTouchIDCapable {
        return "Touch ID 사용하기"
      }
      return ""
    }
  }

  // MARK: - Properties

  public let steps = PublishRelay<Step>()

  private var biometricIconImage: UIImage? {
    let device = Device.current
    let configuration = UIImage.SymbolConfiguration(weight: .light)
    if device.isFaceIDCapable {
      return UIImage(systemName: "faceid", withConfiguration: configuration)
    } else if device.isTouchIDCapable {
      return UIImage(systemName: "touchid", withConfiguration: configuration)
    }
    return nil
  }

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    label.text = Typo.titleString
    return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.subtext)
    label.textAlignment = .center
    label.numberOfLines = 2
    label.text = Typo.subtitleString
    return label
  }()

  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView(image: self.biometricIconImage)
    imageView.tintColor = .favorColor(.main)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private lazy var rejectButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.button)
    config.baseForegroundColor = .favorColor(.subtext)
    config.updateAttributedTitle(Typo.rejectButtonTitle, font: .favorFont(.bold, size: 16))

    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 24.0
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(self.rejectButtonDidTap(_:)), for: .touchUpInside)
    return button
  }()

  private lazy var confirmButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.main)
    config.baseForegroundColor = .favorColor(.white)
    config.updateAttributedTitle(Typo.confirmButtonTitle, font: .favorFont(.bold, size: 16))

    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 24.0
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(self.confirmButtonDidTap(_:)), for: .touchUpInside)
    return button
  }()

  // MARK: - UI Setups

  public override func setupLayouts() {
    super.setupLayouts()

    [
      self.titleLabel,
      self.subtitleLabel,
      self.iconImageView,
      self.rejectButton,
      self.confirmButton
    ].forEach {
      self.containerView.addSubview($0)
    }
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metric.topInset)
      make.centerX.equalToSuperview()
    }

    self.subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16.0)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.iconImageView.snp.makeConstraints { make in
      make.top.equalTo(self.subtitleLabel.snp.bottom).offset(32.0)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(56.0)
    }

    self.rejectButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.buttonHorizontalInset)
      make.bottom.equalToSuperview().inset(Metric.buttonBottomInset)
      make.width.equalTo(Metric.buttonWidth)
      make.height.equalTo(Metric.buttonHeight)
    }

    self.confirmButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.buttonHorizontalInset)
      make.bottom.equalToSuperview().inset(Metric.buttonBottomInset)
      make.width.equalTo(Metric.buttonWidth)
      make.height.equalTo(Metric.buttonHeight)
    }
  }

  // MARK: - Functions

  @objc
  private func rejectButtonDidTap(_ sender: UIButton) {
    self.steps.accept(AppStep.biometricAuthPopupIsComplete(isConfirmed: false))
  }

  @objc
  private func confirmButtonDidTap(_ sender: UIButton) {
    self.steps.accept(AppStep.biometricAuthPopupIsComplete(isConfirmed: true))
  }
}
