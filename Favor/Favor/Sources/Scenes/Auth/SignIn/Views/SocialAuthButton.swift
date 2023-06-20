//
//  SocialAuthButton.swift
//  Favor
//
//  Created by 이창준 on 6/21/23.
//

import UIKit

import FavorKit
import SnapKit

public final class SocialAuthButton: UIButton {

  // MARK: - Constants

  private enum Metric {
    static let socialSignInButtonSize: CGFloat = 56.0
  }

  // MARK: - Properties

  public var socialType: SocialAuthType!

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  public convenience init(_ socialType: SocialAuthType) {
    self.init(frame: .zero)
    self.socialType = socialType
    self.setupSocialAuthType(socialType)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func setupSocialAuthType(_ socialType: SocialAuthType) {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = socialType.backgroundColor
    config.baseForegroundColor = socialType.foregroundColor
    config.image = socialType.icon?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: socialType.iconSize(.large))
      .withTintColor(socialType.foregroundColor)
    self.configuration = config
    
    self.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.socialSignInButtonSize)
    }
    self.layer.cornerRadius = Metric.socialSignInButtonSize / 2
    self.clipsToBounds = true
  }
}
