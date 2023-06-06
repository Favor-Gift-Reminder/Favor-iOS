//
//  FavorBarButtonItem.swift
//  Favor
//
//  Created by 이창준 on 2023/03/12.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

public class FavorBarButtonItem: UIBarButtonItem {

  // MARK: - Constants

  private enum Metric {
    static let size: CGFloat = 44.0
  }

  // MARK: - UI Components

  fileprivate var button = UIButton()

  // MARK: - Initializer

  override init() {
    super.init()
  }

  /// - Parameters:
  ///   - icon: 아이콘 이미지
  public convenience init(_ icon: UIImage.FavorIcon) {
    self.init()
    self.button = self.makeButton(with: icon)

    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(_ title: String?) {
    self.init()
    self.button = self.makeButton(with: title)

    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func update(_ icon: UIImage.FavorIcon) {
    self.button = self.makeButton(with: icon)
  }

  public func update(_ title: String?) {
    self.button = self.makeButton(with: title)
  }
}

// MARK: - UI Setup

extension FavorBarButtonItem: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.customView = self.button
    self.button.isUserInteractionEnabled = true
  }

  public func setupConstraints() {
    self.customView?.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.size)
    }
  }
}

// MARK: - Privates

private extension FavorBarButtonItem {
  func makeButton(with icon: UIImage.FavorIcon) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(icon)
    config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 11, bottom: 11, trailing: 11)
    let button = UIButton(configuration: config)
    return button
  }

  func makeButton(with title: String?) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle(title, font: .favorFont(.bold, size: 18))
    config.contentInsets = .zero

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .disabled:
        config.baseForegroundColor = .favorColor(.line2)
      case .normal:
        config.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    button.contentMode = .center
    return button
  }
}
