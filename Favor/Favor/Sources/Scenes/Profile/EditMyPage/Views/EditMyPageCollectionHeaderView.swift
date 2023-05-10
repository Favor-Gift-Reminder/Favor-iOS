//
//  EditMyPageCollectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class EditMyPageCollectionHeaderView: UICollectionReusableView, Reusable {

  // MARK: - Constants

  private enum Metric {
    static let backgroundImageHeight = 300.0
    static let profileImageSize = 120.0
  }

  // MARK: - UI Components

  private lazy var backgroundImageView: UIImageView = {
    let imageView = self.makeEditableButton()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .favorColor(.sub)
    imageView.clipsToBounds = true
    return imageView
  }()

  private lazy var profileImageView: UIImageView = {
    let imageView = self.makeEditableButton()
    imageView.contentMode = .center
    imageView.backgroundColor = .favorColor(.line3)
    imageView.layer.cornerRadius = Metric.profileImageSize / 2
    imageView.clipsToBounds = true
    imageView.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 60)
    return imageView
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

  public func bind(with title: String) {

  }
}

// MARK: - UI Setup

extension EditMyPageCollectionHeaderView: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    [
      self.backgroundImageView,
      self.profileImageView
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.backgroundImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(Metric.backgroundImageHeight)
    }

    self.profileImageView.snp.makeConstraints { make in
      make.centerX.equalTo(self.backgroundImageView.snp.centerX)
      make.centerY.equalTo(self.backgroundImageView.snp.bottom)
      make.width.height.equalTo(Metric.profileImageSize)
    }
  }
}

// MARK: - Privates

private extension EditMyPageCollectionHeaderView {
  func makeEditableButton() -> UIImageView {
    let imageView = UIImageView()

    // Blur
    let blurView = UIView()
    blurView.backgroundColor = .favorColor(.black)
    blurView.layer.opacity = 0.3

    // Button
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.gallery)?
      .withRenderingMode(.alwaysTemplate)
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 36)
    let button = UIButton(configuration: config)

    [
      blurView,
      button
    ].forEach {
      imageView.addSubview($0)
    }

    blurView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    return imageView
  }
}
