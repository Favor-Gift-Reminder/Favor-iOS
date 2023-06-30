//
//  LocalAuthVC.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import LocalAuthentication
import OSLog
import UIKit

import DeviceKit
import FavorKit
import ReactorKit
import SnapKit

public final class LocalAuthViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topInset: CGFloat = 32.0
    static let bottomInset: CGFloat = 20.0
    static let labelSpacing: CGFloat = 16.0
    static let keypadHorizontalInset: CGFloat = 48.0
  }

  private enum Typo {
    static var biometricFailTitle: String {
      let device = Device.current
      if device.isFaceIDCapable {
        return "Face ID를 사용할 수 없습니다"
      } else if device.isTouchIDCapable {
        return "Touch ID를 사용할 수 없습니다"
      } else {
        return "생체 인식을 사용할 수 없습니다"
      }
    }
    static var biometricFailDescription: String {
      let device = Device.current
      let biometric: String
      if device.isFaceIDCapable {
        biometric = "Face ID"
      } else if device.isTouchIDCapable {
        biometric = "Touch ID"
      } else {
        biometric = "생체 인식"
      }
      return "설정 > 페이버 에서 " + biometric + " 권한을 허용해주세요."
    }
    static let biometricFailCancel: String = "취소"
    static let biometricFailSetting: String = "설정"
  }

  // MARK: - Properties

  public var titleString: String = "암호 확인" {
    didSet { self.titleLabel.text = self.titleString }
  }

  public var subtitleString: String = "암호를 입력해주세요." {
    didSet { self.subtitleLabel.text = self.subtitleString }
  }

  private let authContext = LAContext()

  // MARK: - UI Components

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    label.text = self.titleString
    return label
  }()

  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    label.text = self.subtitleString
    return label
  }()

  private let keypadTextField = FavorKeypadTextField()

  private let biometricAuthButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.main)
    config.updateAttributedTitle("test", font: .favorFont(.regular, size: 14))

    let button = UIButton(configuration: config)
    button.isHidden = !Device.current.hasBiometricSensor
    return button
  }()

  private lazy var numberKeypad: FavorNumberKeypad = {
    let numbers: [FavorNumberKeypadCellModel] = (1...9).map { .keyString(String($0)) }
    let bottoms: [FavorNumberKeypadCellModel] = [.keyString(""), .keyString("0"), .keyImage(.favorIcon(.erase)!)]
    let keypad = FavorNumberKeypad(numbers + bottoms)
    keypad.delegate = self
    return keypad
  }()

  // MARK: - Binding

  public func bind(reactor: LocalAuthViewReactor) {
    // Action
    self.biometricAuthButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.handleLocalAuth()
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.inputs }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, inputs in
        owner.keypadTextField.updateKeypadInputs(inputs)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.titleLabel,
      self.subtitleLabel,
      self.keypadTextField,
      self.biometricAuthButton,
      self.numberKeypad
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(Metric.topInset)
      make.centerX.equalToSuperview()
    }

    self.subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.labelSpacing)
      make.centerX.equalToSuperview()
    }

    self.keypadTextField.snp.makeConstraints { make in
      make.top.equalTo(self.subtitleLabel.snp.bottom).offset(48.0)
      make.centerX.equalToSuperview()
    }

    self.biometricAuthButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.numberKeypad.snp.top).offset(-48.0)
      make.centerX.equalToSuperview()
    }

    self.numberKeypad.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(Metric.keypadHorizontalInset)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(Metric.bottomInset)
      make.height.equalTo(self.numpadHeight())
    }
  }
}

// MARK: - Privates

private extension LocalAuthViewController {
  func numpadHeight() -> CGFloat {
    let keypadWidth = self.view.bounds.width - (Metric.keypadHorizontalInset * 2)
    let keypadSpacings = self.numberKeypad.horizontalSpacing * 2
    let numpadSize = (keypadWidth - keypadSpacings) / 3
    let height = (numpadSize * 4) + (self.numberKeypad.verticalSpacing * 3)
    return height
  }

  func handleLocalAuth() {
    var error: NSError?
    if self.authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      let reason = "얼굴 대라"
      authContext.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: reason
      ) { [weak self] isSucceed, error in
        DispatchQueue.main.async {
          if isSucceed {
            os_log(.info, "Succeed")
          }
        }
      }
    } else {
      let ac = UIAlertController(
        title: Typo.biometricFailTitle,
        message: Typo.biometricFailDescription,
        preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: Typo.biometricFailCancel, style: .destructive))
      ac.addAction(UIAlertAction(title: Typo.biometricFailSetting, style: .default, handler: { _ in
        UIApplication.shared.open(
          URL(string: UIApplication.openSettingsURLString)!,
          completionHandler: nil
        )
      }))
      self.present(ac, animated: true)
    }
  }
}

// MARK: - NumberKeypad

extension LocalAuthViewController: FavorNumberKeypadDelegate {
  public func padSelected(_ selected: FavorNumberKeypadCellModel) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.keypadDidSelected(selected))
  }
}
