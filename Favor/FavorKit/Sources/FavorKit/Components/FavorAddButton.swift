//
//  FavorAddButton.swift
//  Favor
//
//  Created by 이창준 on 2023/04/26.
//

import UIKit

import SnapKit

public final class FavorAddButton: UIView {

  // MARK: - Properties

  public var iconSize: CGFloat = 48.0

  public var titleString: String = "추가하기" {
    didSet { self.updateTitle() }
  }

  // MARK: - UI Components

  private lazy var addIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.image = .favorIcon(.add)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 22)
      .withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    imageView.layer.cornerRadius = self.iconSize / 2
    imageView.clipsToBounds = true
    return imageView
  }()

  private lazy var button: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle(
      self.titleString,
      font: .favorFont(.regular, size: 16)
    )
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.icon)
    config.contentInsets = NSDirectionalEdgeInsets(
      top: .zero,
      leading: 64,
      bottom: .zero,
      trailing: .zero
    )

    let button = UIButton(configuration: config)
    button.contentHorizontalAlignment = .leading
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func updateTitle() {
    self.button.configuration?.updateAttributedTitle(
      self.titleString,
      font: .favorFont(.regular, size: 16)
    )
  }
}

// MARK: - UI Setups

extension FavorAddButton: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    [
      self.addIconImageView,
      self.button
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(self.iconSize)
    }

    self.addIconImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.directionalVerticalEdges.equalToSuperview()
      make.width.height.equalTo(self.iconSize)
    }

    self.button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
