//
//  SplashVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import SnapKit

public final class SplashViewController: BaseViewController, Stepper {

  // MARK: - Constants

  private enum Metric {
    static let logoImageSize: CGFloat = 75.0
  }

  // MARK: - Properties

  public var steps = PublishRelay<Step>()

  // MARK: - UI Components

  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "SplashLogo")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()

    self.view.backgroundColor = .favorColor(.main)
  }

  public override func setupLayouts() {
    self.view.addSubview(self.logoImageView)
  }

  public override func setupConstraints() {
    self.logoImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(Metric.logoImageSize)
    }
  }
}

//    switch FTUXStorage.authState {
//    case .email: // Email 로그인
//                 // TODO: 자동 로그인
//      return self.navigateToDashboard()
//    case .apple: // Apple 로그인
//      os_log(.debug, "🔐 Signed in via 🍎 Apple: Navigating to tab bar flow.")
//      // TODO: `fetchAppleCredentialState` 사용해 애플 로그인 상태 확인 후 자동 로그인
//      return self.navigateToDashboard()
//    case .kakao: // 카카오 로그인
//      os_log(.debug, "🔐 Signed in via 🥥 Kakao: Navigating to tab bar flow.")
//      return .none
//    case .naver: // 네이버 로그인
//      os_log(.debug, "🔐 Signed in via 🌲 Naver: Navigating to tab bar flow.")
//      return .none
//    case .undefined:
//      os_log(.debug, "🔒 Not signed in to any services: Navigating to auth flow.")
//      return .none
//    }
