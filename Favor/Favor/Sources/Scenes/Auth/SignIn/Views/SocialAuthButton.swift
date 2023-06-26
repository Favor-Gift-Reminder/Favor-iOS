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

  public var authMethod: AuthMethod!

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  public convenience init(_ authMethod: AuthMethod) {
    self.init(frame: .zero)
    self.authMethod = authMethod
    self.setupSocialAuthType(authMethod)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func setupSocialAuthType(_ authMethod: AuthMethod) {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = authMethod.backgroundColor
    config.baseForegroundColor = authMethod.foregroundColor
    config.image = authMethod.icon?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: authMethod.iconSize(.large))
      .withTintColor(authMethod.foregroundColor)
    self.configuration = config
    
    self.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.socialSignInButtonSize)
    }
    self.layer.cornerRadius = Metric.socialSignInButtonSize / 2
    self.clipsToBounds = true
  }
}
