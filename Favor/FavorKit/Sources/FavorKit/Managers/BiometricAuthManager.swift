//
//  BiometricAuthManager.swift
//  Favor
//
//  Created by 이창준 on 7/3/23.
//

import LocalAuthentication
import UIKit

import DeviceKit

public final class BiometricAuthManager {

  // MARK: - Constants

  private enum Typo {
    static let device = Device.current
    static let reason: String = "Face ID를 사용합니다."
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

  // MARK: - Properties

  private let authContext = LAContext()

  // MARK: - Initializer

  public init() { }

  // MARK: - Functions

  public func handleBiometricAuth(
    target vc: UIViewController,
    onSuccess: (() -> Void)? = nil,
    onFailure: (() -> Void)? = nil
  ) {
    var error: NSError?

    if self.authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      // 권한이 있다면 생체 인증 설정 여부를 확인합니다.
      self.authContext.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: Typo.reason
      ) { isSucceed, _ in
        DispatchQueue.main.async {
          if isSucceed, let onSuccess {
            onSuccess()
          } else if !isSucceed, let onFailure {
            onFailure()
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
      vc.present(ac, animated: true)
    }
  }
}
