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
    static let biometricPopupHight: CGFloat = 335.0
  }

  private enum Typo {
    static let device = Device.current
    static var biometricPromptTitle: String {
      if device.isFaceIDCapable {
        return "Face ID"
      } else if device.isTouchIDCapable {
        return "Touch ID"
      } else {
        return "생체 인증"
      }
    }
    static var biometricPromptDescription: String {
      if device.isFaceIDCapable {
        return "빠른 이용을 위해 Face ID를 사용하세요."
      } else if device.isTouchIDCapable {
        return "빠른 이용을 위해 Touch ID를 사용하세요."
      } else {
        return "빠른 이용을 위해 생체 인증을 사용하세요."
      }
    }
    static let biometricPromptCancel: String = "암호 입력하기"
    static var biometricPromptAccept: String {
      if device.isFaceIDCapable {
        return "Face ID 사용하기"
      } else if device.isTouchIDCapable {
        return "Touch ID 사용하기"
      } else {
        return "생체 인증 사용하기"
      }
    }
    static var biometricFailTitle: String {
      if device.isFaceIDCapable {
        return "Face ID를 사용할 수 없습니다"
      } else if device.isTouchIDCapable {
        return "Touch ID를 사용할 수 없습니다"
      } else {
        return "생체 인증을 사용할 수 없습니다"
      }
    }
    static var biometricFailDescription: String {
      let biometric: String
      if device.isFaceIDCapable {
        biometric = "Face ID"
      } else if device.isTouchIDCapable {
        biometric = "Touch ID"
      } else {
        biometric = "생체 인증"
      }
      return "설정 > 페이버 에서 " + biometric + " 권한을 허용해주세요."
    }
    static let biometricFailCancel: String = "취소"
    static let biometricFailSetting: String = "설정"
  }

  public struct DescriptionMessage: Equatable {
    var description: String?
    var isError: Bool = false
  }

  // MARK: - Properties

  public var titleString: String? {
    didSet { self.titleLabel.text = self.titleString }
  }

  public var subtitleString: DescriptionMessage? {
    didSet {
      self.subtitleLabel.text = self.subtitleString?.description
      self.subtitleLabel.textColor = {
        self.subtitleString!.isError ? .favorColor(.main) : .favorColor(.explain)
      }()
    }
  }

  private var biometricImage: UIImage? {
    let device = Device.current
    if device.isFaceIDCapable {
      return UIImage(systemName: "faceid")
    } else if device.isTouchIDCapable {
      return UIImage(systemName: "touchid")
    } else {
      return nil
    }
  }

  private let authContext = LAContext()

  // MARK: - UI Components

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
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
    label.text = self.subtitleString?.description
    return label
  }()

  private let keypadTextField = FavorKeypadTextField()

  private lazy var numberKeypad: FavorNumberKeypad = {
    // Numbers
    let numbers: [FavorNumberKeypadCellModel] = (1...9).map { .keyString(String($0)) }

    // Biometric
    let isBiometricAuthEnabled = UserInfoStorage.isBiometricAuthEnabled ?? false
    let biometricImage: UIImage = self.biometricImage ?? UIImage()
    guard let location = reactor?.localAuthRequest else { return FavorNumberKeypad([]) }
    let biometricPad: FavorNumberKeypadCellModel
    switch location {
    case .authenticate, .askCurrent:
      biometricPad = {
        isBiometricAuthEnabled ? .keyImage(biometricImage) : .emptyKey
      }()
    case .askNew, .confirmNew:
      biometricPad = .emptyKey
    }

    // Bottoms
    let bottoms: [FavorNumberKeypadCellModel] = [
      biometricPad,
      .keyString("0"),
      .emptyKey
    ]

    let keypad = FavorNumberKeypad(numbers + bottoms)
    keypad.delegate = self
    return keypad
  }()

  // MARK: - Binding

  public func bind(reactor: LocalAuthViewReactor) {
    // Action
    self.rx.viewDidAppear
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        switch reactor.localAuthRequest {
        case .authenticate, .askCurrent:
          if UserInfoStorage.isBiometricAuthEnabled {
            owner.handleBiometricAuth()
          }
        case .askNew:
          if !UserInfoStorage.isLocalAuthEnabled {
            owner.presentNewLocalAuthAlertPopup()
          }
        default:
          break
        }
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.pulse { $0.$biometricAuthPromptPulse }
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.presentBiometricPopup()
      })
      .disposed(by: self.disposeBag)

    reactor.pulse { $0.$biometricAuthPulse }
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.handleBiometricAuth()
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.inputs }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, inputs in
        owner.keypadTextField.updateKeypadInputs(inputs)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.description }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, description in
        owner.subtitleString = description
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func handleBiometricPopupResult(_ isConfirmed: Bool) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.biometricPopupDidFinish(isConfirmed))
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.titleLabel,
      self.subtitleLabel,
      self.keypadTextField,
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

  /// 생체 인증 프롬프트를 띄웁니다.
  func presentBiometricPopup() {
    let biometricPopup = BiometricAuthPopup(Metric.biometricPopupHight)
    biometricPopup.delegate = self
    biometricPopup.modalPresentationStyle = .overFullScreen
    self.present(biometricPopup, animated: false)
  }

  /// 생체 인증을 시도합니다.
  func handleBiometricAuth() {
    var error: NSError?

    if self.authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      // 권한이 있다면 생체 인증 설정 여부를 확인합니다.
      let reason = "얼굴 대라"
      self.authContext.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: reason
      ) { [weak self] isSucceed, _ in
        DispatchQueue.main.async {
          if isSucceed {
            guard let reactor = self?.reactor else { return }
            reactor.action.onNext(.biometricAuthDidSucceed)
          }
        }
      }
    } else {
      // 권한이 없다면 권한 요청 알림 창을 띄웁니다.
      let ac = UIAlertController(
        title: Typo.biometricFailTitle,
        message: Typo.biometricFailDescription,
        preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: Typo.biometricFailCancel, style: .destructive))
      ac.addAction(UIAlertAction(title: Typo.biometricFailSetting, style: .default) { _ in
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      })
      self.present(ac, animated: true)
    }
  }

  func presentNewLocalAuthAlertPopup() {
    let popup = NewLocalAuthPopup(335.0)
    popup.modalPresentationStyle = .overFullScreen
    popup.delegate = self

    DispatchQueue.main.async {
      self.present(popup, animated: false)
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

// MARK: - BiometricAuth Popup

extension LocalAuthViewController: BiometricAuthPopupDelegate {
  public func biometricAuthUsageSelected(_ isConfirmed: Bool) {
    guard let biometricPopup = self.presentedViewController as? BiometricAuthPopup else {
      return
    }
    biometricPopup.dismissPopup {
      self.handleBiometricPopupResult(isConfirmed)
    }
  }
}

// MARK: - New Local Auth Popup

extension LocalAuthViewController: NewLocalAuthPopupDelegate {
  public func actionDidSelected(_ isAccepted: Bool) {
    guard let popup = self.presentedViewController as? NewLocalAuthPopup else { return }
    popup.dismissPopup()
    if !isAccepted {
      self.navigationController?.popViewController(animated: true)
    }
  }
}
