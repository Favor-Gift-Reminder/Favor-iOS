//
//  GiftDetailPhotoHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import SnapKit

final class GiftDetailPhotoHeaderView: UIView {

  // MARK: - Constants

  private enum Metric {
    static let width: CGFloat = 200.0
    static let height: CGFloat = 44.0
  }

  // MARK: - Properties

  public var currentIndex: Int = 0 {
    didSet { self.updateLabel() }
  }

  public var total: Int = 0 {
    didSet { self.updateLabel() }
  }

  // MARK: - UI Components

  private let counterLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.white)
    label.textAlignment = .center
    label.text = "0/0"
    return label
  }()

  private let backButton: UIButton = {
    let button = UIButton()
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

  private func updateLabel() {
    self.counterLabel.text = "\(self.currentIndex + 1)/\(self.total)"
  }
}

// MARK: - UI Setups

extension GiftDetailPhotoHeaderView: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    self.addSubview(self.counterLabel)
  }

  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.width.equalTo(Metric.width)
      make.height.equalTo(Metric.height)
    }

    self.counterLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
