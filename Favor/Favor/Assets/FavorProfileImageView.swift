//
//  FavorProfileImageView.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import UIKit

import SnapKit
import Then

public final class FavorProfileImageView: UIView {
  
  private enum Metric {
    static let wholeSize: CGFloat = 120.0
    static let plusViewSize: CGFloat = 40.0
  }
  
  // MARK: - UI Components
  
  private let mainFriendView: UIButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.image = .favorIcon(.friend)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 60.0)
    config.baseBackgroundColor = .favorColor(.line3)
    config.baseForegroundColor = .favorColor(.white)
    $0.configuration = config
  }
  
  private let plusView: UIButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line2)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.add)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 24.0)
    config.background.cornerRadius = Metric.plusViewSize / 2
    $0.configuration = config
    $0.isUserInteractionEnabled = false
  }
  
  private let dimmedPhotoView: UIButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = Metric.wholeSize / 2
    config.baseBackgroundColor = .favorColor(.white).withAlphaComponent(0.3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.photo)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 28.0)
    $0.configuration = config
  }
  
  // MARK: - Properties
  
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
}

// MARK: - Setup

extension FavorProfileImageView: BaseView {
  public func setupStyles() {}

  public func setupLayouts() {
    [
      self.mainFriendView,
      self.plusView,
      self.dimmedPhotoView
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.wholeSize)
    }

    self.mainFriendView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.plusView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.plusViewSize)
      make.bottom.leading.equalToSuperview()
    }

    self.dimmedPhotoView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
